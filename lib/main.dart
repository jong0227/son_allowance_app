import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  final prefs = await SharedPreferences.getInstance();
  await NotificationService.instance.init();
  // 가족 동기화(Firestore)용. google-services.json이 없으면(빌드 환경 문제 등)
  // 앱 자체는 계속 쓸 수 있어야 하므로 실패해도 무시하고 진행한다.
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const AllowanceApp(),
    ),
  );
}
