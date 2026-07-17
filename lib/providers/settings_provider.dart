import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// main() 에서 실제 SharedPreferences 인스턴스로 override 됨.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('main()에서 override 되어야 합니다.');
});

class AppSettings {
  final String? deviceOwner; // '아빠' | '엄마'
  final ThemeMode themeMode;
  final bool lockEnabled;
  final String? pinHash;
  final String? pinSalt;
  final bool notificationsEnabled;
  final bool weeklyReportEnabled;
  final DateTime? lastExportedAt;
  final DateTime? lastImportedAt;
  final String? familyCode; // 실시간 동기화(Firebase) 가족 코드. null이면 미연결

  final List<String> expenseCategories; // 지출 카테고리
  final List<String> incomeCategories; // 특별 수입 종류 (정기용돈 제외)
  final List<String> givers; // 특별 수입을 준 사람 (기타 제외 — 기타는 항상 선택 가능)

  const AppSettings({
    this.deviceOwner,
    this.themeMode = ThemeMode.system,
    this.lockEnabled = false,
    this.pinHash,
    this.pinSalt,
    this.notificationsEnabled = true,
    this.weeklyReportEnabled = false,
    this.lastExportedAt,
    this.lastImportedAt,
    this.familyCode,
    this.expenseCategories = defaultExpenseCategories,
    this.incomeCategories = defaultIncomeCategories,
    this.givers = defaultGivers,
  });

  static const defaultExpenseCategories = ['간식', '문구', '게임', '기타'];
  static const defaultIncomeCategories = ['설날(세뱃돈)', '추석', '생일', '기타보너스'];
  static const defaultGivers = ['엄마', '아빠', '멍멍할머니', '창원할아버지', '창원할머니'];

  AppSettings copyWith({
    String? deviceOwner,
    ThemeMode? themeMode,
    bool? lockEnabled,
    String? pinHash,
    String? pinSalt,
    bool? notificationsEnabled,
    bool? weeklyReportEnabled,
    DateTime? lastExportedAt,
    DateTime? lastImportedAt,
    String? familyCode,
    List<String>? expenseCategories,
    List<String>? incomeCategories,
    List<String>? givers,
  }) {
    return AppSettings(
      deviceOwner: deviceOwner ?? this.deviceOwner,
      themeMode: themeMode ?? this.themeMode,
      lockEnabled: lockEnabled ?? this.lockEnabled,
      pinHash: pinHash ?? this.pinHash,
      pinSalt: pinSalt ?? this.pinSalt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      weeklyReportEnabled: weeklyReportEnabled ?? this.weeklyReportEnabled,
      lastExportedAt: lastExportedAt ?? this.lastExportedAt,
      lastImportedAt: lastImportedAt ?? this.lastImportedAt,
      familyCode: familyCode ?? this.familyCode,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      incomeCategories: incomeCategories ?? this.incomeCategories,
      givers: givers ?? this.givers,
    );
  }

  /// familyCode를 명시적으로 null로 만든 새 인스턴스 (동기화 연결 해제용).
  /// copyWith는 ??-병합이라 null을 넘겨도 지워지지 않으므로 별도 제공.
  AppSettings withoutFamilyCode() => AppSettings(
        deviceOwner: deviceOwner,
        themeMode: themeMode,
        lockEnabled: lockEnabled,
        pinHash: pinHash,
        pinSalt: pinSalt,
        notificationsEnabled: notificationsEnabled,
        weeklyReportEnabled: weeklyReportEnabled,
        lastExportedAt: lastExportedAt,
        lastImportedAt: lastImportedAt,
        familyCode: null,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
        givers: givers,
      );
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences prefs;

  SettingsNotifier(this.prefs) : super(_load(prefs));

  static AppSettings _load(SharedPreferences prefs) {
    final themeStr = prefs.getString('themeMode');
    final theme = ThemeMode.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => ThemeMode.system,
    );
    final lastExportedStr = prefs.getString('lastExportedAt');
    final lastImportedStr = prefs.getString('lastImportedAt');
    List<String> listOr(String key, List<String> fallback) {
      final v = prefs.getStringList(key);
      return (v == null || v.isEmpty) ? fallback : v;
    }

    return AppSettings(
      deviceOwner: prefs.getString('deviceOwner'),
      themeMode: theme,
      lockEnabled: prefs.getBool('lockEnabled') ?? false,
      pinHash: prefs.getString('pinHash'),
      pinSalt: prefs.getString('pinSalt'),
      notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
      weeklyReportEnabled: prefs.getBool('weeklyReportEnabled') ?? false,
      lastExportedAt: lastExportedStr != null ? DateTime.tryParse(lastExportedStr) : null,
      lastImportedAt: lastImportedStr != null ? DateTime.tryParse(lastImportedStr) : null,
      familyCode: prefs.getString('familyCode'),
      expenseCategories:
          listOr('expenseCategories', AppSettings.defaultExpenseCategories),
      incomeCategories: listOr('incomeCategories', AppSettings.defaultIncomeCategories),
      givers: listOr('givers', AppSettings.defaultGivers),
    );
  }

  Future<void> setDeviceOwner(String owner) async {
    await prefs.setString('deviceOwner', owner);
    state = state.copyWith(deviceOwner: owner);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await prefs.setString('themeMode', mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await prefs.setBool('notificationsEnabled', enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> setWeeklyReportEnabled(bool enabled) async {
    await prefs.setBool('weeklyReportEnabled', enabled);
    state = state.copyWith(weeklyReportEnabled: enabled);
  }

  // ----- 카테고리 목록(지출/수입/받은사람) 편집 -----
  // kind: 'expense' | 'income' | 'giver'
  String _prefKey(String kind) => switch (kind) {
        'expense' => 'expenseCategories',
        'income' => 'incomeCategories',
        _ => 'givers',
      };

  List<String> _listOf(String kind) => switch (kind) {
        'expense' => state.expenseCategories,
        'income' => state.incomeCategories,
        _ => state.givers,
      };

  AppSettings _withList(String kind, List<String> list) => switch (kind) {
        'expense' => state.copyWith(expenseCategories: list),
        'income' => state.copyWith(incomeCategories: list),
        _ => state.copyWith(givers: list),
      };

  Future<void> addCategory(String kind, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _listOf(kind).contains(trimmed)) return;
    final updated = [..._listOf(kind), trimmed];
    await prefs.setStringList(_prefKey(kind), updated);
    state = _withList(kind, updated);
  }

  Future<void> removeCategory(String kind, String name) async {
    final updated = _listOf(kind).where((c) => c != name).toList();
    if (updated.isEmpty) return; // 최소 1개는 유지
    await prefs.setStringList(_prefKey(kind), updated);
    state = _withList(kind, updated);
  }

  /// Import 시 상대방 기기의 카테고리 목록을 현재 목록과 합집합으로 병합.
  Future<void> mergeCategoryLists({
    List<String>? expense,
    List<String>? income,
    List<String>? givers,
  }) async {
    List<String> union(List<String> a, List<String>? b) {
      if (b == null) return a;
      final seen = {...a};
      final result = [...a];
      for (final x in b) {
        if (x.trim().isNotEmpty && !seen.contains(x)) {
          seen.add(x);
          result.add(x);
        }
      }
      return result;
    }

    final e = union(state.expenseCategories, expense);
    final i = union(state.incomeCategories, income);
    final g = union(state.givers, givers);
    await prefs.setStringList('expenseCategories', e);
    await prefs.setStringList('incomeCategories', i);
    await prefs.setStringList('givers', g);
    state = state.copyWith(expenseCategories: e, incomeCategories: i, givers: g);
  }

  Future<void> setPin(String pin) async {
    final salt = _randomSalt();
    final hash = _hashPin(pin, salt);
    await prefs.setString('pinSalt', salt);
    await prefs.setString('pinHash', hash);
    await prefs.setBool('lockEnabled', true);
    state = state.copyWith(pinSalt: salt, pinHash: hash, lockEnabled: true);
  }

  Future<void> disableLock() async {
    await prefs.setBool('lockEnabled', false);
    state = state.copyWith(lockEnabled: false);
  }

  bool verifyPin(String pin) {
    if (state.pinHash == null || state.pinSalt == null) return false;
    return _hashPin(pin, state.pinSalt!) == state.pinHash;
  }

  Future<void> recordExport() async {
    final now = DateTime.now();
    await prefs.setString('lastExportedAt', now.toIso8601String());
    state = state.copyWith(lastExportedAt: now);
  }

  Future<void> recordImport() async {
    final now = DateTime.now();
    await prefs.setString('lastImportedAt', now.toIso8601String());
    state = state.copyWith(lastImportedAt: now);
  }

  Future<void> setFamilyCode(String code) async {
    await prefs.setString('familyCode', code);
    state = state.copyWith(familyCode: code);
  }

  Future<void> clearFamilyCode() async {
    await prefs.remove('familyCode');
    state = state.withoutFamilyCode();
  }

  String _randomSalt() {
    final rnd = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => rnd.nextInt(256)));
  }

  String _hashPin(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(sharedPreferencesProvider));
});
