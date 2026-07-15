import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 카테고리/태그용 파스텔 색 한 쌍 (배경 + 글자/아이콘).
class PastelPair {
  final Color bg;
  final Color fg;
  const PastelPair(this.bg, this.fg);
}

/// 앱 전역에서 쓰는 파스텔 시맨틱 색. 라이트/다크 각각 정의해 ThemeExtension으로 주입한다.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final PastelPair income; // 수입
  final PastelPair expense; // 지출
  final PastelPair savings; // 저축/이체
  final PastelPair special; // 특별수입
  final PastelPair allowance; // 정기용돈
  final List<PastelPair> tags; // 카테고리 태그 팔레트
  final Color heroFrom; // 잔액 히어로 카드 그라데이션 시작
  final Color heroTo; // 잔액 히어로 카드 그라데이션 끝
  final Color heroText; // 히어로 카드 위 텍스트

  const AppPalette({
    required this.income,
    required this.expense,
    required this.savings,
    required this.special,
    required this.allowance,
    required this.tags,
    required this.heroFrom,
    required this.heroTo,
    required this.heroText,
  });

  PastelPair tagFor(String key) {
    final idx = key.hashCode.abs() % tags.length;
    return tags[idx];
  }

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) => this;

  static const light = AppPalette(
    income: PastelPair(Color(0xFFE4F4EB), Color(0xFF2F8F5D)),
    expense: PastelPair(Color(0xFFFCEAE4), Color(0xFFD16B53)),
    savings: PastelPair(Color(0xFFE8F1FD), Color(0xFF4B7BD8)),
    special: PastelPair(Color(0xFFF1EAFB), Color(0xFF8663C9)),
    allowance: PastelPair(Color(0xFFFAF1D9), Color(0xFFBE8E2E)),
    tags: [
      PastelPair(Color(0xFFDCE7FB), Color(0xFF3E6DB5)),
      PastelPair(Color(0xFFFBE6D4), Color(0xFFB5713A)),
      PastelPair(Color(0xFFD9F0E0), Color(0xFF3B8B5E)),
      PastelPair(Color(0xFFEADFF7), Color(0xFF7E5AB8)),
      PastelPair(Color(0xFFFBDEE8), Color(0xFFB5527E)),
      PastelPair(Color(0xFFFBF0CF), Color(0xFF9C7A26)),
      PastelPair(Color(0xFFD5EFF0), Color(0xFF3A8A8F)),
      PastelPair(Color(0xFFF3E0D0), Color(0xFF9A6B4A)),
    ],
    heroFrom: Color(0xFFEDEFFF),
    heroTo: Color(0xFFF6EAFB),
    heroText: Color(0xFF3B3A57),
  );

  static const dark = AppPalette(
    income: PastelPair(Color(0xFF1E3128), Color(0xFF74C79B)),
    expense: PastelPair(Color(0xFF35211C), Color(0xFFE39684)),
    savings: PastelPair(Color(0xFF1E2A3F), Color(0xFF88ABF0)),
    special: PastelPair(Color(0xFF2A2440), Color(0xFFB79BEB)),
    allowance: PastelPair(Color(0xFF322A1A), Color(0xFFE0BC6A)),
    tags: [
      PastelPair(Color(0xFF25324A), Color(0xFF9BBAF0)),
      PastelPair(Color(0xFF3A2C1F), Color(0xFFE0B183)),
      PastelPair(Color(0xFF203528), Color(0xFF8CD3A8)),
      PastelPair(Color(0xFF2E2740), Color(0xFFC3A8EE)),
      PastelPair(Color(0xFF3A2530), Color(0xFFEDA0BF)),
      PastelPair(Color(0xFF352E1B), Color(0xFFE0C878)),
      PastelPair(Color(0xFF1E3436), Color(0xFF87CBCF)),
      PastelPair(Color(0xFF352A20), Color(0xFFD3A585)),
    ],
    heroFrom: Color(0xFF272A45),
    heroTo: Color(0xFF322A47),
    heroText: Color(0xFFE9E8F5),
  );
}

class NotionColors {
  NotionColors._();
  static const accent = Color(0xFF6E7BF2);
  static const accentDark = Color(0xFF97A0F7);
}

ThemeData buildLightTheme() => _buildTheme(brightness: Brightness.light);
ThemeData buildDarkTheme() => _buildTheme(brightness: Brightness.dark);

ThemeData _buildTheme({required Brightness brightness}) {
  final isDark = brightness == Brightness.dark;

  final bg = isDark ? const Color(0xFF161719) : const Color(0xFFFAF9F7);
  final surface = isDark ? const Color(0xFF1F2123) : Colors.white;
  final surfaceMuted = isDark ? const Color(0xFF26282B) : const Color(0xFFF3F1ED);
  final border = isDark ? const Color(0xFF2E3033) : const Color(0xFFECEAE5);
  final textPrimary = isDark ? const Color(0xFFE8E7E4) : const Color(0xFF2B2A28);
  final textSecondary = isDark ? const Color(0xFF97938D) : const Color(0xFF8B8681);
  final accent = isDark ? NotionColors.accentDark : NotionColors.accent;
  final palette = isDark ? AppPalette.dark : AppPalette.light;

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: accent,
    onPrimary: Colors.white,
    secondary: accent,
    onSecondary: Colors.white,
    error: palette.expense.fg,
    onError: Colors.white,
    surface: surface,
    onSurface: textPrimary,
    onSurfaceVariant: textSecondary,
    surfaceContainerHighest: surfaceMuted,
    outline: border,
    primaryContainer: palette.savings.bg,
    onPrimaryContainer: palette.savings.fg,
    secondaryContainer: palette.savings.bg,
    onSecondaryContainer: palette.savings.fg,
    tertiaryContainer: palette.allowance.bg,
    onTertiaryContainer: palette.allowance.fg,
  );

  // 세련된 위계: 큰 숫자는 굵고 자간 좁게, 본문은 살짝 여유있게.
  final base = GoogleFonts.notoSansKrTextTheme();
  final textTheme = base.apply(bodyColor: textPrimary, displayColor: textPrimary).copyWith(
        displaySmall: base.displaySmall?.copyWith(
            fontWeight: FontWeight.w800, letterSpacing: -1.0, height: 1.05, color: textPrimary),
        headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.1, color: textPrimary),
        headlineSmall: base.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700, letterSpacing: -0.5, color: textPrimary),
        titleLarge: base.titleLarge?.copyWith(
            fontWeight: FontWeight.w700, letterSpacing: -0.4, color: textPrimary),
        titleMedium: base.titleMedium?.copyWith(
            fontWeight: FontWeight.w600, letterSpacing: -0.2, color: textPrimary),
        titleSmall: base.titleSmall?.copyWith(
            fontWeight: FontWeight.w600, letterSpacing: -0.1, color: textPrimary),
        bodyLarge: base.bodyLarge?.copyWith(letterSpacing: -0.1, height: 1.4, color: textPrimary),
        bodyMedium: base.bodyMedium?.copyWith(letterSpacing: -0.1, height: 1.4, color: textPrimary),
        bodySmall: base.bodySmall?.copyWith(letterSpacing: 0, height: 1.35, color: textSecondary),
        labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.1),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bg,
    canvasColor: bg,
    dividerColor: border,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    extensions: [palette],
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleSpacing: 16,
      titleTextStyle: GoogleFonts.notoSansKr(
          color: textPrimary, fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.4),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: textSecondary,
      titleTextStyle: GoogleFonts.notoSansKr(
          color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      subtitleTextStyle:
          GoogleFonts.notoSansKr(color: textSecondary, fontSize: 12.5, letterSpacing: -0.1),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent, width: 1.6),
      ),
      labelStyle: TextStyle(color: textSecondary, letterSpacing: -0.2),
      floatingLabelStyle: TextStyle(color: accent, letterSpacing: -0.2),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: textSecondary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 2,
      extendedTextStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: accent.withValues(alpha: 0.16),
      elevation: 0,
      height: 66,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11.5,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: -0.2,
          color: selected ? accent : textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? accent : textSecondary, size: 24);
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: surface,
      indicatorColor: accent.withValues(alpha: 0.16),
      selectedIconTheme: IconThemeData(color: accent),
      unselectedIconTheme: IconThemeData(color: textSecondary),
      selectedLabelTextStyle:
          TextStyle(color: accent, fontWeight: FontWeight.w700, letterSpacing: -0.2),
      unselectedLabelTextStyle: TextStyle(color: textSecondary, letterSpacing: -0.2),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
            GoogleFonts.notoSansKr(fontWeight: FontWeight.w600, letterSpacing: -0.2)),
        shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        side: WidgetStatePropertyAll(BorderSide(color: border)),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent.withValues(alpha: 0.16);
          return surface;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return textSecondary;
        }),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceMuted,
      side: BorderSide(color: border),
      labelStyle: GoogleFonts.notoSansKr(
          fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.notoSansKr(
          color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.4),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accent;
        return Colors.transparent;
      }),
      side: BorderSide(color: textSecondary.withValues(alpha: 0.6), width: 1.6),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accent;
        return border;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return accent;
        return border;
      }),
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
  );
}
