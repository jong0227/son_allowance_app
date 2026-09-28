import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/data/app_database.dart';
import 'package:son_allowance_app/providers/tier_provider.dart';
import 'package:son_allowance_app/widgets/tier_cinematic.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('티어 시드는 비어있을 때만 넣고, 재호출해도 중복되지 않는다', () async {
    await db.seedTiersIfEmpty();
    final first = await db.allTiersRaw();
    expect(first.where((t) => t.kind == 'savings').length, 31);
    expect(first.where((t) => t.kind == 'weekly').length, 11);
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

    // 55,000원 → 석탄(50000) 현재, 횃불(60000) 다음
    final p = tierFor(tiers, 55000);
    expect(p.current!.title, '석탄');
    expect(p.next!.title, '횃불');
    expect(p.remaining, 5000);
    expect(p.progress > 0 && p.progress < 1, true);

    // 0원 → 흙, 최상단 초과 → 다음 없음
    expect(tierFor(tiers, 0).current!.title, '흙');
    final top = tierFor(tiers, 99999999);
    expect(top.current!.title, '어떻게 여기까지 왔지?');
    expect(top.next, null);
    expect(top.progress, 1);
  });

  test('저축 티어는 순서대로 가격이 오르고, 순서·아이콘이 중복되지 않는다', () async {
    // 티어를 끼워넣거나 새로 추가할 때 가격/순서가 어긋나면 등급표 자체가 말이 안 된다.
    // (횃불을 중간에 넣으면서 뒤쪽 21개 순서를 전부 밀었던 적이 있어 테스트로 고정)
    await db.seedTiersIfEmpty();
    final sav = (await db.allTiersRaw()).where((t) => t.kind == 'savings').toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    expect(sav.map((t) => t.sortOrder).toSet().length, sav.length,
        reason: 'sortOrder가 겹치면 목록 순서가 뒤죽박죽이 된다');
    expect(sav.map((t) => t.id).toSet().length, sav.length, reason: 'id 중복');
    expect(sav.first.sortOrder, 1);
    // sortOrder는 1부터 빈칸 없이 이어져야 한다.
    for (var i = 0; i < sav.length; i++) {
      expect(sav[i].sortOrder, i + 1, reason: '${sav[i].title}의 순서가 비었거나 건너뛴다');
    }
    // 순서가 올라가면 가격도 반드시 올라가야 한다(같거나 낮으면 도달 불가 등급이 생긴다).
    for (var i = 1; i < sav.length; i++) {
      expect(sav[i].threshold, greaterThan(sav[i - 1].threshold),
          reason: '${sav[i].title}(${sav[i].threshold})이 '
              '${sav[i - 1].title}(${sav[i - 1].threshold})보다 크지 않다');
    }
  });

  test('새로 추가한 등급도 이스터에그 색이 서로 다르게 나온다', () async {
    // 색 표에 없는 티어는 id로 색을 만들어 낸다. 티어를 추가할 때 색 표를
    // 같이 안 고쳐도 회색 하나로 뭉개지지 않아야 한다.
    await db.seedTiersIfEmpty();
    final sav = (await db.allTiersRaw()).where((t) => t.kind == 'savings').toList();
    final newOnes = sav.where((t) => ['sav_29', 'sav_30', 'sav_31'].contains(t.id));
    expect(newOnes.length, 3);
    final colors = newOnes.map((t) => tierPalette(t).base.toARGB32()).toSet();
    expect(colors.length, 3, reason: '새 등급끼리 색이 겹치면 구분이 안 된다');
  });

  group('주간 저축률 등급(10% 단위)', () {
    Future<List<Tier>> weekly() async =>
        (await db.allTiersRaw()).where((t) => t.kind == 'weekly').toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    test('0%부터 100%까지 10% 단위로 빠짐없이 11단계', () async {
      await db.seedTiersIfEmpty();
      final wk = await weekly();
      expect(wk.map((t) => t.threshold).toList(),
          [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]);
      for (var i = 0; i < wk.length; i++) {
        expect(wk[i].sortOrder, i + 1, reason: '${wk[i].title} 순서가 비었다');
      }
      expect(wk.map((t) => t.id).toSet().length, wk.length, reason: 'id 중복');
      expect(wk.map((t) => t.title).toSet().length, wk.length, reason: '칭호 중복');
      expect(wk.map((t) => t.icon).toSet().length, wk.length, reason: '아이콘 중복');
    });

    test('원래 있던 5개는 같은 id·같은 기준 자리에 남는다(업데이트 전 폰과 동기화 대비)', () async {
      await db.seedTiersIfEmpty();
      final byId = {for (final t in await weekly()) t.id: t.threshold};
      expect(byId['wk_01'], 0);
      expect(byId['wk_02'], 40);
      expect(byId['wk_03'], 60);
      expect(byId['wk_04'], 80);
      expect(byId['wk_05'], 100);
    });

    test('각 저축률이 알맞은 등급에 들어간다', () async {
      await db.seedTiersIfEmpty();
      final wk = await weekly();
      expect(tierFor(wk, 0).current!.title, '일반 저축가');
      expect(tierFor(wk, 9).current!.title, '일반 저축가');
      expect(tierFor(wk, 39).current!.title, '햄스터 저축가');
      expect(tierFor(wk, 40).current!.title, '다람쥐 저축가');
      expect(tierFor(wk, 99).current!.title, '로켓 저축가');
      expect(tierFor(wk, 100).current!.title, '완벽 저축왕');
      expect(tierFor(wk, 100).next, null);
    });

    test('주간 등급은 무지갯빛 반짝임이 붙지 않는다', () async {
      await db.seedTiersIfEmpty();
      for (final t in await weekly()) {
        expect(tierPalette(t).shimmer, false, reason: '${t.title}이 반짝인다');
      }
    });
  });

  test('부모가 기준을 순서 뒤바뀌게 고쳐도 알맞은 등급을 고른다', () async {
    // 예전엔 목록을 sortOrder 순서대로만 훑다가 처음 넘지 못한 곳에서 멈춰서,
    // 중간 등급 기준을 낮추면 그 뒤 등급을 영영 못 받았다.
    await db.seedTiersIfEmpty();
    await db.updateTierFields('wk_03', threshold: 15, title: '저축 요정', icon: '⭐', reward: null);
    final wk = (await db.allTiersRaw()).where((t) => t.kind == 'weekly').toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    // 16%면 "저축 요정"(이제 15% 기준) — 옛 로직은 10% 알에서 멈췄다
    expect(tierFor(wk, 16).current!.title, '저축 요정');
    expect(tierFor(wk, 95).current!.title, '로켓 저축가');
  });

  test('기본값 재적용 시각은 릴리즈 날짜로 고정 — 옛 부모 수정본이 동기화로 되살아나지 않는다', () async {
    // 가족 동기화는 updatedAt이 더 최신인 쪽이 이긴다. 예전엔 재적용 시각이 항상
    // 2025-07-01이라, 2026년에 부모가 설정 화면에서 고쳐 둔 값(다른 폰에 남음)이
    // 동기화 때 새 기본값을 도로 덮어썼다.
    await db.seedTiersIfEmpty();
    await db.reseedTiers();
    final reseeded = (await db.allTiersRaw()).firstWhere((t) => t.id == 'wk_02');
    expect(reseeded.title, '다람쥐 저축가');
    expect(reseeded.updatedAt, AppDatabase.tierSeedTime,
        reason: 'now()를 쓰면 늦게 업데이트한 폰이 그사이 부모가 새로 고친 값을 덮어쓴다');

    // 이번 버전 전에 고쳐 둔 수정본(예: 2026년 3월)보다 반드시 최신이어야 한다.
    final editedEarlierThisYear = DateTime(2026, 3, 1);
    expect(AppDatabase.tierSeedTime.isAfter(editedEarlierThisYear), true);
  });

  group('이번 주 저축률 계산', () {
    // 2026-09-30(수). 이번 주 = 9/28(월) ~ 10/4(일)
    final now = DateTime(2026, 9, 30, 12);
    TransactionEntry tx(String flow, String category, int amount, DateTime date) =>
        TransactionEntry(
          id: '$category$amount${date.day}',
          childId: 'kid1',
          date: date,
          flow: flow,
          category: category,
          amount: amount,
          updatedAt: date,
          editedBy: '',
        );

    test('10원만 써도 100%(완벽 저축왕)가 되지 않는다 — 내림', () {
      final txs = [tx('expense', '간식', 10, DateTime(2026, 9, 29))];
      expect(weeklySavePercent(txs, 3000, now: now), 99);
    });

    test('경계에서 한 칸 위 등급으로 올려주지 않는다(39.6% → 39)', () {
      // 3000원 중 1812원 씀 → 1188/3000 = 39.6%
      final txs = [tx('expense', '간식', 1812, DateTime(2026, 9, 29))];
      expect(weeklySavePercent(txs, 3000, now: now), 39);
    });

    test('모의투자 손실은 이번 주 지출로 치지 않는다', () {
      final txs = [
        tx('expense', '간식', 1000, DateTime(2026, 9, 29)),
        tx('expense', AppDatabase.kInvestLoss, 900, DateTime(2026, 9, 30)),
      ];
      expect(weeklySpent(txs, now: now), 1000);
      expect(weeklySavePercent(txs, 3000, now: now), 66);
    });

    test('지난주·다음 주 지출과 수입은 세지 않는다', () {
      final txs = [
        tx('expense', '간식', 500, DateTime(2026, 9, 27, 23, 59)), // 지난주 일요일
        tx('expense', '간식', 500, DateTime(2026, 10, 5)), // 다음 주 월요일
        tx('income', AppDatabase.kRegularAllowance, 3000, DateTime(2026, 9, 28)),
      ];
      expect(weeklySpent(txs, now: now), 0);
      expect(weeklySavePercent(txs, 3000, now: now), 100);
    });

    test('용돈을 다 쓰거나 넘게 쓰면 0%, 용돈 설정이 0이면 0%', () {
      final over = [tx('expense', '간식', 5000, DateTime(2026, 9, 29))];
      expect(weeklySavePercent(over, 3000, now: now), 0);
      expect(weeklySavePercent(const [], 0, now: now), 0);
    });
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
