import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────
/// 디자인 토큰
///
/// 화면에서 숫자를 직접 쓰지 말고 여기 이름을 쓴다. "본문 글씨를 키우자" 같은
/// 요구가 오면 이 파일 한 줄만 고치면 앱 전체가 따라온다.
/// (예전엔 fontSize가 34가지·라운드가 12가지로 흩어져 있어서, 같은 뜻의 글씨가
///  화면마다 12 / 12.5 / 13으로 미묘하게 달랐다. 부부가 각자 화면을 만들다 보니
///  더 벌어졌다.)
/// ─────────────────────────────────────────────────────────────

/// 글씨 크기. 용도로 고르고, 애매하면 한 단계 작은 쪽을 쓴다.
class AppText {
  AppText._();

  /// 아주 작은 보조(티어 배지 안 글씨, 차트 축 등)
  static const micro = 10.0;

  /// 보조 설명, 밑줄 링크, 각주
  static const caption = 11.0;

  /// 태그·칩·통계 타일 라벨
  static const label = 12.0;

  /// 본문 기본
  static const body = 13.0;

  /// 강조 본문, 카드 안 금액 한 줄
  static const bodyLg = 14.0;

  /// 카드 제목
  static const title = 15.0;

  /// 큰 카드 제목, 리스트 헤더
  static const titleLg = 16.0;

  /// 화면 제목, 다이얼로그 제목
  static const heading = 18.0;

  /// 숫자 강조 (작은 것부터)
  static const numSm = 20.0;
  static const numMd = 22.0;
  static const numLg = 24.0;
  static const numXl = 28.0;

  /// 히어로 숫자(축하 연출, 시뮬레이터 결과 등)
  static const numHero = 34.0;
}

/// 이모지를 일러스트처럼 크게 쓸 때. 글씨 스케일과 섞지 않는다
/// (이건 읽는 글자가 아니라 그림이라 위계 기준이 다르다).
class AppEmoji {
  AppEmoji._();

  static const sm = 32.0;
  static const md = 40.0;
  static const lg = 48.0;

  /// 티어 시네마틱처럼 화면을 꽉 채우는 연출용
  static const hero = 96.0;
}

/// 모서리 둥글기.
class AppRadius {
  AppRadius._();

  /// 진행바, 아주 작은 배지
  static const xs = 6.0;

  /// 칩, 세그먼트 버튼, 작은 블록
  static const sm = 10.0;

  /// 입력창, 버튼
  static const md = 12.0;

  /// 카드 기본
  static const lg = 16.0;

  /// 다이얼로그, 큰 시트
  static const xl = 20.0;
}

/// 간격. `SizedBox`와 `EdgeInsets.all`에 쓴다.
///
/// 4의 배수가 기본이지만, 촘촘한 카드 안에서 실제로 많이 쓰던 6(snug)·10(cozy)은
/// 남겨뒀다. 이 둘을 없애고 8/12로 흡수하려면 여기서 값만 바꾸면 앱 전체가 따라온다
/// (토큰으로 묶어둔 덕분에 300곳을 다시 고칠 필요가 없다).
///
/// ⚠️ `EdgeInsets.symmetric`·`only`·`fromLTRB`는 일부러 숫자를 그대로 둔다.
/// 이쪽은 "칩 안쪽 여백 가로 9 세로 4"처럼 그 컴포넌트에서만 의미 있는 미세조정이라,
/// 공통 스케일로 묶으면 오히려 뜻이 흐려진다.
class AppGap {
  AppGap._();

  static const xxs = 2.0;
  static const xs = 4.0;
  static const snug = 6.0;
  static const sm = 8.0;
  static const cozy = 10.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
}

/// 글씨 굵기는 Flutter의 FontWeight를 그대로 쓰되, 아래 네 가지만 사용한다.
/// (`FontWeight.bold` 같은 별칭은 w700과 같은 값인데 이름만 달라 헷갈리므로 쓰지 않는다)
///
///   w600 — 라벨, 보조 강조
///   w700 — 제목, 버튼
///   w800 — 카드 제목, 통계값
///   w900 — 히어로 숫자 전용(잔액, 축하 연출)
///
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

  /// 여러 항목을 한 화면에서 함께 비교할 때(파이차트/범례/선택 칩 등) 서로
  /// 겹치지 않는 색을 배정한다. 이름을 정렬한 뒤 색상환을 항목 수만큼 "균등
  /// 분할"해서 배정하므로, 항목이 몇 개 안 될 때(예: 4개)도 서로 최대한 멀리
  /// 떨어진 색을 받아 확실히 구분된다. 예를 들어 항목이 4개면 정확히 90˚씩
  /// 떨어진 색을 받는다.
  /// (예전엔 hashCode 기반이라 "간식"·"기타"가 겹쳤고, 그다음엔 색상환을
  /// 연속 슬롯으로 순서대로만 채워서 항목이 적을 때 우연히 가까운 색을
  /// 받는 경우가 있었다 — 이번엔 항목 수에 맞춰 원을 나누므로 그런 우연이
  /// 생기지 않는다)
  Map<String, PastelPair> tagsFor(Iterable<String> keys) {
    final sorted = keys.toSet().toList()..sort();
    final n = sorted.length;
    final total = tags.length;
    if (n == 0) return const {};
    final map = <String, PastelPair>{};
    for (var i = 0; i < n; i++) {
      // n이 total 이하면 (i * total) ~/ n 이 0..total-1 사이에서 서로 다른
      // 값으로 고르게 퍼진다(원을 n등분). n이 total을 넘으면 어쩔 수 없이
      // 순환해서 재사용한다(카테고리가 아주 많아질 때의 예외 상황).
      final idx = n <= total ? (i * total) ~/ n : i % total;
      map[sorted[i]] = tags[idx];
    }
    assert(
        n > total || map.values.toSet().length == n,
        'tagsFor: 색이 겹쳤어요 (n=$n, total=$total) — 원 등분 계산을 다시 확인하세요');
    return map;
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
    // 16색상환에 고르게 분산 배치(22.5˚ 간격) — 카테고리가 늘어나도 인접한
    // 두 색이 서로 확실히 구분되도록 색상환을 균등 분할했다.
    tags: [
      PastelPair(Color(0xFFF5DBDB), Color(0xFF8E2929)), // 빨강
      PastelPair(Color(0xFFF5E5DB), Color(0xFF8E4F29)), // 주황
      PastelPair(Color(0xFFF5EEDB), Color(0xFF8E7529)), // 호박
      PastelPair(Color(0xFFF2F5DB), Color(0xFF828E29)), // 올리브
      PastelPair(Color(0xFFE8F5DB), Color(0xFF5C8E29)), // 연두
      PastelPair(Color(0xFFDFF5DB), Color(0xFF368E29)), // 초록
      PastelPair(Color(0xFFDBF5E2), Color(0xFF298E43)), // 에메랄드
      PastelPair(Color(0xFFDBF5EB), Color(0xFF298E68)), // 스프링그린
      PastelPair(Color(0xFFDBF5F5), Color(0xFF298E8E)), // 청록
      PastelPair(Color(0xFFDBEBF5), Color(0xFF29688E)), // 하늘
      PastelPair(Color(0xFFDBE2F5), Color(0xFF29438E)), // 파랑
      PastelPair(Color(0xFFDFDBF5), Color(0xFF36298E)), // 남색
      PastelPair(Color(0xFFE8DBF5), Color(0xFF5C298E)), // 보라
      PastelPair(Color(0xFFF2DBF5), Color(0xFF82298E)), // 자주
      PastelPair(Color(0xFFF5DBEE), Color(0xFF8E2975)), // 마젠타
      PastelPair(Color(0xFFF5DBE5), Color(0xFF8E294F)), // 로즈
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
    // light와 같은 16색상환, 어두운 배경/밝은 글자로 반전.
    tags: [
      PastelPair(Color(0xFF471F1F), Color(0xFFE19898)), // 빨강
      PastelPair(Color(0xFF472E1F), Color(0xFFE1B498)), // 주황
      PastelPair(Color(0xFF473D1F), Color(0xFFE1CF98)), // 호박
      PastelPair(Color(0xFF42471F), Color(0xFFD8E198)), // 올리브
      PastelPair(Color(0xFF33471F), Color(0xFFBDE198)), // 연두
      PastelPair(Color(0xFF24471F), Color(0xFFA1E198)), // 초록
      PastelPair(Color(0xFF1F4729), Color(0xFF98E1AA)), // 에메랄드
      PastelPair(Color(0xFF1F4738), Color(0xFF98E1C6)), // 스프링그린
      PastelPair(Color(0xFF1F4747), Color(0xFF98E1E1)), // 청록
      PastelPair(Color(0xFF1F3847), Color(0xFF98C6E1)), // 하늘
      PastelPair(Color(0xFF1F2947), Color(0xFF98AAE1)), // 파랑
      PastelPair(Color(0xFF241F47), Color(0xFFA198E1)), // 남색
      PastelPair(Color(0xFF331F47), Color(0xFFBD98E1)), // 보라
      PastelPair(Color(0xFF421F47), Color(0xFFD898E1)), // 자주
      PastelPair(Color(0xFF471F3D), Color(0xFFE198CF)), // 마젠타
      PastelPair(Color(0xFF471F2E), Color(0xFFE198B4)), // 로즈
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
  final surfaceMuted = isDark
      ? const Color(0xFF26282B)
      : const Color(0xFFF3F1ED);
  final border = isDark ? const Color(0xFF2E3033) : const Color(0xFFECEAE5);
  final textPrimary = isDark
      ? const Color(0xFFE8E7E4)
      : const Color(0xFF2B2A28);
  final textSecondary = isDark
      ? const Color(0xFF97938D)
      : const Color(0xFF8B8681);
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
  final textTheme = base
      .apply(bodyColor: textPrimary, displayColor: textPrimary)
      .copyWith(
        displaySmall: base.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          height: 1.05,
          color: textPrimary,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          height: 1.1,
          color: textPrimary,
        ),
        headlineSmall: base.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: textPrimary,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: textPrimary,
        ),
        titleMedium: base.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: textPrimary,
        ),
        titleSmall: base.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          color: textPrimary,
        ),
        bodyLarge: base.bodyLarge?.copyWith(
          letterSpacing: -0.1,
          height: 1.4,
          color: textPrimary,
        ),
        bodyMedium: base.bodyMedium?.copyWith(
          letterSpacing: -0.1,
          height: 1.4,
          color: textPrimary,
        ),
        bodySmall: base.bodySmall?.copyWith(
          letterSpacing: 0,
          height: 1.35,
          color: textSecondary,
        ),
        labelLarge: base.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
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
        color: textPrimary,
        fontSize: AppText.heading,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: border),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: textSecondary,
      titleTextStyle: GoogleFonts.notoSansKr(
        color: textPrimary,
        fontSize: AppText.title,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      subtitleTextStyle: GoogleFonts.notoSansKr(
        color: textSecondary,
        fontSize: AppText.label,
        letterSpacing: -0.1,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          fontSize: AppText.title,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: textSecondary,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 2,
      extendedTextStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
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
          fontSize: AppText.caption,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: -0.2,
          color: selected ? accent : textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? accent : textSecondary,
          size: 24,
        );
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: surface,
      indicatorColor: accent.withValues(alpha: 0.16),
      selectedIconTheme: IconThemeData(color: accent),
      unselectedIconTheme: IconThemeData(color: textSecondary),
      selectedLabelTextStyle: TextStyle(
        color: accent,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: textSecondary,
        letterSpacing: -0.2,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.notoSansKr(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
        side: WidgetStatePropertyAll(BorderSide(color: border)),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accent.withValues(alpha: 0.16);
          }
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
        fontSize: AppText.body,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: textPrimary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      titleTextStyle: GoogleFonts.notoSansKr(
        color: textPrimary,
        fontSize: AppText.heading,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
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
