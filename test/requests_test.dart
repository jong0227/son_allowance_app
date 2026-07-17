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
