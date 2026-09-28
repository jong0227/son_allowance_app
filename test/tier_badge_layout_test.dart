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
}
