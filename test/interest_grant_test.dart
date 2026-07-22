import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/data/app_database.dart';

/// 이자 내역 id를 "자녀 + 주기 시작일"로 고정한 뒤 생긴 문제를 막는 회귀 테스트.
/// 같은 행을 덮어쓰기 때문에, 지급을 취소(소프트 삭제)한 뒤 다시 주면
/// 삭제 표시를 지워주지 않으면 내역에 영영 안 보이게 된다.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<Child> makeChild() async {
    await db.upsertChild(ChildrenCompanion.insert(
      id: 'kid1',
      name: '테스트',
      weeklyAllowanceDefault: const Value(3000),
      interestEnabled: const Value(true),
      interestUseBankRate: const Value(false), // 네트워크 없이 고정 이율로 계산
      interestPercent: const Value(1.0),
      interestPeriod: const Value(0), // 주간
    ));
    // 이자가 붙으려면 잔액이 있어야 한다
    await db.upsertTransaction(TransactionEntriesCompanion.insert(
      id: 'tx_income',
      childId: 'kid1',
      date: DateTime.now(),
      flow: 'income',
      category: '용돈',
      amount: 35000,
    ));
    return (await db.allChildrenRaw()).first;
  }

  Future<List<TransactionEntry>> visibleInterest() async {
    final all = await db.allTransactionsRaw();
    return all
        .where((t) => t.category == AppDatabase.kInterest && t.deletedAt == null)
        .toList();
  }

  test('이자를 지급하면 내역이 생긴다', () async {
    final child = await makeChild();
    final b = await db.giveInterest(child, '아빠');

    expect(b, isNotNull);
    expect(b!.amount, 350); // 35,000원의 1%
    expect((await visibleInterest()).length, 1);
  });

  test('같은 주기에 두 번 주면 두 번째는 무시된다', () async {
    final child = await makeChild();
    expect(await db.giveInterest(child, '아빠'), isNotNull);
    expect(await db.giveInterest(child, '엄마'), isNull);
    expect((await visibleInterest()).length, 1);
  });

  test('지급을 취소했다가 다시 주면 내역이 되살아난다', () async {
    final child = await makeChild();
    await db.giveInterest(child, '아빠');
    final txId = (await visibleInterest()).first.id;

    // 부모가 내역에서 이자를 지움(지급 취소)
    await db.softDeleteTransaction(txId, '아빠');
    expect(await visibleInterest(), isEmpty);
    expect(await db.interestGivenThisPeriod('kid1', 0), isFalse);

    // 다시 주면 같은 id를 덮어쓰는데, 삭제 표시가 지워져 다시 보여야 한다
    final again = await db.giveInterest(child, '아빠');
    expect(again, isNotNull);
    expect((await visibleInterest()).length, 1,
        reason: '삭제 표시가 남으면 다시 줘도 내역에 안 보인다');
  });

  test('아이 프로필이 직전 주기에 없었으면 소급 지급하지 않는다', () async {
    final child = await makeChild(); // createdAt = 지금
    expect(await db.autoGrantMissedInterest(child, '아빠'), isNull);
  });
}
