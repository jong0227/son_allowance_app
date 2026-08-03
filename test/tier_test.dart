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
