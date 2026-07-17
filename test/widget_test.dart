import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_allowance_app/app.dart';
import 'package:son_allowance_app/data/app_database.dart';
import 'package:son_allowance_app/providers/database_provider.dart';
import 'package:son_allowance_app/providers/settings_provider.dart';

void main() {
  testWidgets('앱이 온보딩 화면으로 정상 시작된다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    // 실제 DB는 path_provider가 필요해 테스트에서 열 수 없으므로 인메모리 DB로 교체
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
        ],
        child: const AllowanceApp(),
      ),
    );
    // 자녀 목록 스트림이 첫 값을 낼 때까지 잠시 대기
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('처음 설정'), findsOneWidget);

    // drift 스트림이 dispose 시 예약하는 타이머를 흘려보내 "pending timer" 실패 방지
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
