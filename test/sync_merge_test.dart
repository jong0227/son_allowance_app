import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/data/app_database.dart';
import 'package:son_allowance_app/services/export_import_service.dart';

/// 두 기기(아빠/엄마)가 각자 온보딩으로 서로 다른 id의 "내 아이" 프로필을
/// 만든 뒤, 가족 동기화로 합쳐지는 전체 흐름을 재현한다.
/// 실제 버그 리포트: "총액은 맞는데 내역 목록엔 아무것도 안 보인다"의
/// 원인이 데이터 병합 로직인지, 화면 쪽인지 가려내기 위한 테스트.
void main() {
  const io = ExportImportService();

  test('참여 후 양쪽 기기 모두 같은 childId 아래 모든 내역이 합쳐진다', () async {
    final dadDb = AppDatabase.forTesting(NativeDatabase.memory());
    final momDb = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await dadDb.close();
      await momDb.close();
    });

    // 1) 아빠 폰: 온보딩으로 아이 프로필 생성 + 기존 잔액 2300원짜리 수입 내역
    await dadDb.upsertChild(ChildrenCompanion.insert(
      id: 'child-dad',
      name: '아들',
      weeklyAllowanceDefault: const Value(10000),
    ));
    final dadChild = (await dadDb.allChildrenRaw()).first;
    await dadDb.upsertTransaction(TransactionEntriesCompanion.insert(
      id: 'tx-initial',
      childId: dadChild.id,
      date: DateTime.now(),
      flow: 'income',
      category: '이월잔액',
      amount: 2300,
      updatedAt: Value(DateTime.now()),
    ));

    // 2) 엄마 폰: 독립적으로 온보딩 (다른 id로 "내 아이" 프로필 생성, 아직 내역 없음)
    await momDb.upsertChild(ChildrenCompanion.insert(
      id: 'child-mom',
      name: '아들',
      weeklyAllowanceDefault: const Value(10000),
    ));

    // 3) 엄마가 아빠의 코드로 참여: 아빠 데이터를 통째로 받아 병합 후 중복 프로필 정리
    final dadBlob = await io.serializeAll(dadDb, '아빠');
    final joinPreview = await io.previewImportData(dadBlob, momDb);
    await io.applyImport(joinPreview, momDb);
    final momPrimaryId = await momDb.reconcileToSingleChild('엄마');

    // 정리 후 엄마 DB에는 (데이터가 있던) 아빠의 child가 살아남아야 한다.
    expect(momPrimaryId, dadChild.id);
    final momAliveChildren =
        (await momDb.allChildrenRaw()).where((c) => c.deletedAt == null).toList();
    expect(momAliveChildren.length, 1, reason: '중복 프로필이 남아있으면 안 됨');

    // 4) 엄마가 간식 1200원 지출 등록 (합쳐진 child id로)
    await momDb.upsertTransaction(TransactionEntriesCompanion.insert(
      id: 'tx-snack',
      childId: momPrimaryId!,
      date: DateTime.now(),
      flow: 'expense',
      category: '간식',
      amount: 1200,
      updatedAt: Value(DateTime.now()),
    ));

    final momSummary = await momDb.computeSummary(momPrimaryId);
    expect(momSummary['balance'], 1100);

    // 5) 엄마 → 아빠로 다시 병합 (실시간 동기화가 엄마 쪽 전체를 push, 아빠가 수신)
    final momBlob = await io.serializeAll(momDb, '엄마');
    final dadPreview = await io.previewImportData(momBlob, dadDb);
    await io.applyImport(dadPreview, dadDb);
    await dadDb.reconcileToSingleChild('아빠');

    // 6) 검증: 아빠 쪽에서도 같은 child id로 두 내역이 다 보여야 한다
    final dadTxs = await dadDb.allTransactionsRaw();
    final aliveDadTxs = dadTxs.where((t) => t.deletedAt == null).toList();
    expect(aliveDadTxs.map((t) => t.id).toSet(), {'tx-initial', 'tx-snack'});
    expect(aliveDadTxs.every((t) => t.childId == dadChild.id), true);

    final dadSummary = await dadDb.computeSummary(dadChild.id);
    expect(dadSummary['balance'], 1100);
  });
}
