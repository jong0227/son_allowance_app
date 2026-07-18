import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/data/app_database.dart';
import 'package:son_allowance_app/providers/tier_provider.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('티어 시드는 비어있을 때만 넣고, 재호출해도 중복되지 않는다', () async {
    await db.seedTiersIfEmpty();
    final first = await db.allTiersRaw();
    expect(first.where((t) => t.kind == 'savings').length, 16);
    expect(first.where((t) => t.kind == 'weekly').length, 5);
    // 시드는 고정 과거 시각(2020)이라 부모 수정이 항상 우선
    expect(first.first.updatedAt.year, 2020);

    await db.seedTiersIfEmpty();
    final second = await db.allTiersRaw();
    expect(second.length, first.length, reason: '중복 시드 안 됨');
  });

  test('tierFor: 저축액에 맞는 현재/다음 티어를 고른다', () async {
    await db.seedTiersIfEmpty();
    final tiers = (await db.allTiersRaw()).where((t) => t.kind == 'savings').toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    // 12,000원 → 조약돌(10000) 현재, 석탄(20000) 다음
    final p = tierFor(tiers, 12000);
    expect(p.current!.title, '조약돌');
    expect(p.next!.title, '석탄');
    expect(p.remaining, 8000);
    expect(p.progress > 0 && p.progress < 1, true);

    // 0원 → 흙, 최상단 초과 → 다음 없음
    expect(tierFor(tiers, 0).current!.title, '흙');
    final top = tierFor(tiers, 99999999);
    expect(top.current!.title, '엔드 크리스탈');
    expect(top.next, null);
    expect(top.progress, 1);
  });

  test('티어 수정 시각이 갱신되어 동기화 우선권을 갖는다', () async {
    await db.seedTiersIfEmpty();
    await db.updateTierFields('sav_11',
        threshold: 250000, title: '다이아 갑부', icon: '💎', reward: '레고 대형 세트');
    final t = (await db.allTiersRaw()).firstWhere((e) => e.id == 'sav_11');
    expect(t.title, '다이아 갑부');
    expect(t.threshold, 250000);
    expect(t.updatedAt.year, greaterThan(2020));
  });
}
