import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/providers/market_provider.dart';
import 'package:son_allowance_app/screens/exchange_calculator_screen.dart';
import 'package:son_allowance_app/theme/app_theme.dart';

/// 환율 계산기 화면 테스트. 네트워크를 타지 않도록 fxRatesProvider를 고정값으로 덮어쓴다.
void main() {
  Future<void> pump(WidgetTester tester, Map<String, double> rates) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        fxRatesProvider.overrideWith((ref) async => rates),
      ],
      // appPalette가 앱 테마 확장을 요구하므로 실제 테마를 써야 한다.
      child: MaterialApp(
        theme: buildLightTheme(),
        home: const ExchangeCalculatorScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  // 1달러 = 1400원, 1엔 = 9원으로 두고 계산이 맞는지 본다.
  const rates = {'USD': 1400.0, 'JPY': 9.0, 'EUR': 1600.0, 'CNY': 200.0};

  testWidgets('원화를 입력하면 외화가 환율대로 계산된다', (tester) async {
    await pump(tester, rates);
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, '14000');
    await tester.pump();
    // 14000원 / 1400 = 10달러
    expect(tester.widget<TextField>(fields.last).controller!.text, '10');
  });

  testWidgets('외화를 입력하면 원화가 환율대로 계산된다', (tester) async {
    await pump(tester, rates);
    final fields = find.byType(TextField);
    await tester.enterText(fields.last, '3');
    await tester.pump();
    // 3달러 * 1400 = 4200원
    expect(tester.widget<TextField>(fields.first).controller!.text, '4200');
  });

  testWidgets('소수점을 두 번 찍어도 입력이 깨지지 않는다', (tester) async {
    await pump(tester, rates);
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, '1.5');
    await tester.pump();
    // 소수점을 하나 더 붙이려 하면 무시되고 직전 값이 유지되어야 한다
    await tester.enterText(fields.first, '1.5.2');
    await tester.pump();
    expect(tester.widget<TextField>(fields.first).controller!.text, '1.5',
        reason: '소수점 2개짜리 입력은 거부되어야 한다');
    // 반대쪽 칸도 살아있어야 한다(예전엔 파싱 실패로 소리 없이 비워졌다)
    expect(tester.widget<TextField>(fields.last).controller!.text, isNotEmpty,
        reason: '반대쪽 칸이 비워지면 안 된다');
  });

  testWidgets('고른 통화(달러)만 못 받아와도 화면이 먹통이 되지 않는다', (tester) async {
    // 달러만 빠진 상황 — 기본 선택이 USD라 예전엔 아무 반응 없는 화면이 됐다
    await pump(tester, const {'JPY': 9.0, 'EUR': 1600.0});
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, '900');
    await tester.pump();
    // 받아온 통화(엔)로 자동으로 옮겨가 계산이 되어야 한다: 900원 / 9 = 100엔
    expect(tester.widget<TextField>(fields.last).controller!.text, '100',
        reason: '받아온 통화로 자동 전환되어 계산이 되어야 한다');
  });

  testWidgets('환율을 하나도 못 받아오면 다시 시도 안내를 보여준다', (tester) async {
    await pump(tester, const {});
    expect(find.text('다시 시도'), findsOneWidget);
  });
}
