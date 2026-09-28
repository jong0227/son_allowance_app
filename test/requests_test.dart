import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/data/app_database.dart';
import 'package:son_allowance_app/services/export_import_service.dart';

/// 자녀 요청 → 부모 승인 흐름 검증.
void main() {
  late AppDatabase db;

  Future<Child> makeChild() async {
    await db.upsertChild(ChildrenCompanion.insert(
      id: 'kid1',
      name: '테스트',
      weeklyAllowanceDefault: const Value(3000),
      bonusAmount: const Value(500),
    ));
    return (await db.allChildrenRaw()).first;
  }

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('보너스 요청 → 승인하면 보너스 수입 내역이 생기고 요청은 approved', () async {
    final child = await makeChild();
    expect(await db.requestBonus(child, '아들'), true);
    // 중복 요청은 막힌다
    expect(await db.requestBonus(child, '아들'), false);

    final pending = (await db.allRequestsRaw()).where((r) => r.status == 'pending').toList();
    expect(pending.length, 1);

    await db.approveRequest(pending.first, '아빠');

    final txs = (await db.allTransactionsRaw()).where((t) => t.deletedAt == null).toList();
    expect(txs.length, 1);
    expect(txs.first.category, '절약보너스');
    expect(txs.first.amount, 500);

    final req = (await db.allRequestsRaw()).first;
    expect(req.status, 'approved');
    expect(req.resolvedBy, '아빠');
  });

  test('위시리스트 요청 → 승인하면 저축 목표가 생긴다', () async {
    final child = await makeChild();
    await db.requestWishlist(child, '레고 세트', 45000, '아들');
    final req = (await db.allRequestsRaw()).first;

    await db.approveRequest(req, '엄마');

    final goals = (await db.allGoalsRaw()).where((g) => g.deletedAt == null).toList();
    expect(goals.length, 1);
    expect(goals.first.title, '레고 세트');
    expect(goals.first.targetAmount, 45000);
    expect((await db.allRequestsRaw()).first.status, 'approved');
  });

  test('주식 요청 → 부모가 구매 결과 입력하면 주식이체 내역이 종목정보와 함께 생긴다', () async {
    final child = await makeChild();
    await db.requestStock(child, '삼성전자', '005930.KS', 100000, '아들');
    final req = (await db.allRequestsRaw()).firstWhere((r) => r.type == 'stock');
    expect(req.title, '삼성전자');
    expect(req.memo, '005930.KS');
    expect(req.amount, 100000);

    await db.fulfillStockRequest(req,
        actualAmount: 98000, shares: 2, memo: '1주 49,000원', resolvedBy: '아빠');

    final transfers = (await db.allStockTransfersRaw()).where((t) => t.deletedAt == null).toList();
    expect(transfers.length, 1);
    expect(transfers.first.companyName, '삼성전자');
    expect(transfers.first.ticker, '005930.KS');
    expect(transfers.first.shares, 2);
    expect(transfers.first.amount, 98000);

    final after = (await db.allRequestsRaw()).firstWhere((r) => r.type == 'stock');
    expect(after.status, 'approved');
    // 이체액이 누적 이체(주식계좌)에 반영된다
    expect((await db.computeSummary(child.id))['totalTransfer'], 98000);
  });

  test('같은 보너스 요청을 두 번 승인해도 보너스는 한 번만 들어간다', () async {
    final child = await makeChild();
    await db.requestBonus(child, '아들');
    final req = (await db.allRequestsRaw()).first;
    // 승인 버튼 연타 / 화면에 남은 옛 요청 객체로 다시 승인
    await db.approveRequest(req, '아빠');
    await db.approveRequest(req, '아빠');
    final bonuses = (await db.allTransactionsRaw())
        .where((t) => t.deletedAt == null && t.category == '절약보너스');
    expect(bonuses.length, 1);
  });

  test('엄마·아빠가 각자 폰에서 동시에 승인해도 동기화 후 보너스는 한 번', () async {
    const io = ExportImportService();
    final child = await makeChild();
    await db.requestBonus(child, '아들');
    // 아빠 폰 → 엄마 폰으로 요청이 동기화된 상태
    final mom = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(mom.close);
    await io.applyImport(await io.previewImportData(await io.serializeAll(db, '아빠'), mom), mom);

    // 동기화되기 전에 둘 다 승인
    await db.approveRequest((await db.allRequestsRaw()).first, '아빠');
    await mom.approveRequest((await mom.allRequestsRaw()).first, '엄마');

    // 엄마 폰 변경이 아빠 폰으로 합쳐짐
    await io.applyImport(await io.previewImportData(await io.serializeAll(mom, '엄마'), db), db);
    final bonuses = (await db.allTransactionsRaw())
        .where((t) => t.deletedAt == null && t.category == '절약보너스');
    expect(bonuses.length, 1, reason: '같은 요청의 보너스가 두 번 들어가면 안 된다');
  });

  test('이번 주 보너스를 이미 줬으면 아이 요청을 승인해도 또 주지 않는다', () async {
    final child = await makeChild();
    await db.requestBonus(child, '아들');
    // 부모가 홈 카드에서 먼저 보너스 지급
    expect(await db.giveSavingsBonus(child, '아빠'), true);
    await db.approveRequest((await db.allRequestsRaw()).first, '아빠');

    final bonuses = (await db.allTransactionsRaw())
        .where((t) => t.deletedAt == null && t.category == '절약보너스');
    expect(bonuses.length, 1);
    // 요청 자체는 처리된 것으로 정리된다(대기 목록에 계속 남지 않게)
    expect((await db.allRequestsRaw()).first.status, 'approved');
  });

  test('거절된 요청은 나중에 승인 버튼을 눌러도 반영되지 않는다', () async {
    final child = await makeChild();
    await db.requestBonus(child, '아들');
    final req = (await db.allRequestsRaw()).first;
    await db.rejectRequest(req, '엄마');
    await db.approveRequest(req, '아빠'); // 다른 폰에 남은 옛 "대기" 화면에서 누름
    expect((await db.allTransactionsRaw()).where((t) => t.deletedAt == null).length, 0);
    expect((await db.allRequestsRaw()).first.status, 'rejected');
  });

  test('한 폰은 홈 카드로, 다른 폰은 아이 요청 승인으로 보너스를 줘도 동기화 후 한 번', () async {
    const io = ExportImportService();
    final child = await makeChild();
    await db.requestBonus(child, '아들');
    final mom = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(mom.close);
    await io.applyImport(await io.previewImportData(await io.serializeAll(db, '아빠'), mom), mom);

    await db.giveSavingsBonus(child, '아빠'); // 아빠: 홈 카드
    await mom.approveRequest((await mom.allRequestsRaw()).first, '엄마'); // 엄마: 요청 승인

    await io.applyImport(await io.previewImportData(await io.serializeAll(mom, '엄마'), db), db);
    final bonuses = (await db.allTransactionsRaw())
        .where((t) => t.deletedAt == null && t.category == '절약보너스');
    expect(bonuses.length, 1);
  });

  test('위시리스트 요청을 두 번 승인해도 목표는 하나', () async {
    final child = await makeChild();
    await db.requestWishlist(child, '레고 세트', 45000, '아들');
    final req = (await db.allRequestsRaw()).first;
    await db.approveRequest(req, '엄마');
    await db.approveRequest(req, '엄마');
    expect((await db.allGoalsRaw()).where((g) => g.deletedAt == null).length, 1);
  });

  test('주식 요청을 두 번 처리해도 주식계좌로 한 번만 빠진다', () async {
    final child = await makeChild();
    await db.requestStock(child, '삼성전자', '005930.KS', 100000, '아들');
    final req = (await db.allRequestsRaw()).firstWhere((r) => r.type == 'stock');
    await db.fulfillStockRequest(req, actualAmount: 98000, resolvedBy: '아빠');
    await db.fulfillStockRequest(req, actualAmount: 98000, resolvedBy: '아빠');
    expect((await db.computeSummary(child.id))['totalTransfer'], 98000);
  });

  test('거절하면 내역/목표가 생기지 않고 요청은 rejected', () async {
    final child = await makeChild();
    await db.requestBonus(child, '아들');
    final req = (await db.allRequestsRaw()).first;
    await db.rejectRequest(req, '아빠');

    expect((await db.allTransactionsRaw()).where((t) => t.deletedAt == null).length, 0);
    expect((await db.allRequestsRaw()).first.status, 'rejected');
  });

  test('요청 데이터가 동기화 직렬화에 포함된다', () async {
    const io = ExportImportService();
    final child = await makeChild();
    await db.requestBonus(child, '아들');
    // 다른 기기로 병합
    final other = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(other.close);
    final blob = await io.serializeAll(db, '아들');
    final preview = await io.previewImportData(blob, other);
    await io.applyImport(preview, other);
    final reqs = (await other.allRequestsRaw()).where((r) => r.deletedAt == null).toList();
    expect(reqs.length, 1);
    expect(reqs.first.type, 'bonus');
  });
}
