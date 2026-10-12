import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_allowance_app/data/app_database.dart';
import 'package:son_allowance_app/providers/settings_provider.dart';
import 'package:son_allowance_app/theme/app_theme.dart';
import 'package:son_allowance_app/widgets/tier_widgets.dart';

/// 앱 상단 제목줄(아바타 + "이름의 용돈" + 누적 배지 + 주간 배지)이 좁은 폰에서도
/// 넘치지 않는지. 칭호가 길면 제목줄이 화면 밖으로 넘쳐 노란 경고 줄무늬가 떴다.
void main() {
  Tier tier(String id, String kind, String title, String icon) => Tier(
        id: id,
        kind: kind,
        sortOrder: 1,
        threshold: 0,
        title: title,
        icon: icon,
        updatedAt: DateTime(2026),
      );

  Future<void> pumpTitleRow(WidgetTester tester, double width, Tier a, Tier b) async {
    // TierIcon이 "내가 넣은 아이콘" 경로를 SharedPreferences에서 읽는다.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              // main_shell의 titleWidget과 같은 구성
              child: Row(
                children: [
                  const SizedBox(width: 36, height: 36),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text('이서원의 용돈', overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 6),
                  TierBadge(tier: a),
                  const SizedBox(width: 4),
                  TierBadge(tier: b),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  testWidgets('가장 긴 칭호 두 개가 붙어도 좁은 폰(360dp) 제목줄이 넘치지 않는다', (tester) async {
    // 제목줄 폭 ≈ 화면 360 - 좌우 여백
    await pumpTitleRow(
      tester,
      300,
      tier('sav_30', 'savings', '대애애바아악부우우자아아', '💰'),
      tier('wk_08', 'weekly', '햄스터 저축가', '🐹'),
    );
    // 넘치면 RenderFlex overflow 예외가 여기서 잡힌다
    expect(tester.takeException(), isNull);
  });

  testWidgets('짧은 칭호는 잘리지 않고 그대로 보인다', (tester) async {
    await pumpTitleRow(
      tester,
      300,
      tier('sav_06', 'savings', '석탄', '⬛'),
      tier('wk_03', 'weekly', '저축 요정', '⭐'),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('석탄'), findsOneWidget);
    expect(find.text('저축 요정'), findsOneWidget);
  });

  // 홈의 부자 등급 / 주간 저축률 카드(반 폭씩 나란히). 내 점수와 "다음 등급이 몇 점부터"를
  // 크게 보여주게 바꾸면서, 좁은 폰·큰 글씨·가장 긴 칭호에서도 안 넘치는지 확인한다.
  group('홈 티어 카드', () {
    Tier t(String id, String kind, int sortOrder, int threshold, String title) => Tier(
          id: id,
          kind: kind,
          sortOrder: sortOrder,
          threshold: threshold,
          title: title,
          icon: '⭐',
          updatedAt: DateTime(2026),
        );

    final savings = [
      t('sav_09', 'savings', 10, 90000, '돌'),
      t('sav_10', 'savings', 11, 100000, '구리'),
      t('sav_30', 'savings', 30, 15000000, '대애애바아악부우우자아아'),
      t('sav_31', 'savings', 31, 20000000, '어떻게 여기까지 왔지?'),
    ];
    final weekly = [
      t('wk_10', 'weekly', 8, 70, '부엉이 저축가'),
      t('wk_04', 'weekly', 9, 80, '부자 후보자'),
    ];

    Future<void> pumpCards(WidgetTester tester,
        {required double screenWidth, required int score, double textScale = 1}) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: screenWidth - 32, // overview_screen 좌우 여백
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child: TierSummaryCard(label: '부자 등급', tiers: savings, value: score)),
                        const SizedBox(width: 4),
                        Expanded(
                            child: TierSummaryCard(
                                label: '주간 저축률', tiers: weekly, value: 73, isPercent: true)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
    }

    testWidgets('내 점수와 다음 등급이 몇 점부터인지 카드에 보인다', (tester) async {
      await pumpCards(tester, screenWidth: 360, score: 95000);
      expect(tester.takeException(), isNull);
      expect(find.text('95,000원'), findsOneWidget, reason: '내 저축 점수');
      expect(find.text('구리'), findsOneWidget, reason: '다음 등급 이름');
      expect(find.text('100,000원부터'), findsOneWidget, reason: '다음 등급 시작 점수');
      expect(find.text('5,000원 남음'), findsOneWidget);
      expect(find.text('73%'), findsOneWidget, reason: '이번 주 저축률');
      expect(find.text('80%부터'), findsOneWidget);
    });

    for (final (w, scale) in [(320.0, 1.0), (360.0, 1.3), (320.0, 1.3)]) {
      testWidgets('좁은 폰 ${w.toInt()}dp · 글씨 $scale배 · 가장 긴 칭호·큰 점수에서도 넘치지 않는다',
          (tester) async {
        // 다음 등급이 "어떻게 여기까지 왔지?"(20,000,000원)인 경우
        await pumpCards(tester, screenWidth: w, score: 15432100, textScale: scale);
        expect(tester.takeException(), isNull);
        // 최고 등급
        await pumpCards(tester, screenWidth: w, score: 21000000, textScale: scale);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
