import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_allowance_app/app.dart';
import 'package:son_allowance_app/providers/settings_provider.dart';

void main() {
  testWidgets('앱이 온보딩 화면으로 정상 시작된다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const AllowanceApp(),
      ),
    );
    await tester.pump();

    expect(find.text('처음 설정'), findsOneWidget);
  });
}
