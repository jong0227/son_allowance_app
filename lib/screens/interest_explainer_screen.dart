import 'package:flutter/material.dart';
import '../services/interest_calc.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';

/// 초등 2학년 눈높이의 "이자가 뭐야?" 설명 화면.
/// 이자란 무엇인지 → 왜 주는지 → 어떻게 하면 더 받는지 3단으로 풀어서,
/// 마지막에 "약속 지키면 이자가 오른다"로 연결해 동기를 만든다.
class InterestExplainerScreen extends StatelessWidget {
  /// 지금 우리 아이의 실제 이자 상황(있으면 화면에 실제 숫자로 보여준다).
  final InterestBreakdown? breakdown;

  const InterestExplainerScreen({super.key, this.breakdown});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Scaffold(
      appBar: AppBar(title: const Text('이자가 뭐야?')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _Hero(pair: palette.savings),
          const SizedBox(height: AppGap.xl),
          _Step(
            pair: palette.allowance,
            emoji: '🌱',
            title: '이자 = 돈이 자라는 것',
            body: '돈을 쓰지 않고 모아두면, 고맙다고 조금씩 얹어주는 돈이 이자예요. '
                '씨앗을 심고 기다리면 열매가 열리는 것처럼, 돈도 두면 조금씩 자라요.',
          ),
          _Arrow(),
          _Step(
            pair: palette.special,
            emoji: '🏦',
            title: '은행은 왜 이자를 줄까?',
            body: '내가 맡긴 돈을 은행이 다른 사람에게 빌려주고 이자를 받아요. '
                '그 돈을 나눠주는 거예요. "돈을 맡겨줘서 고마워"의 표시죠.',
          ),
          _Arrow(),
          _Step(
            pair: palette.income,
            emoji: '💝',
            title: '우리집은 왜 이자를 줄까?',
            body: '서원이가 용돈을 아껴서 모으는 습관을 응원하려고요! '
                '진짜 은행 정기예금과 똑같은 이자를 주고, 약속을 지키면 조금 더 얹어줘요.',
          ),
          const SizedBox(height: AppGap.xl),
          Text('이자를 더 많이 받는 3가지 방법',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppGap.cozy),
          _Tip(
            pair: palette.savings,
            emoji: '📦',
            title: '1. 많이 모으기',
            body: '이자는 모아둔 돈에서 나와요. 많이 모을수록 이자도 커져요.',
          ),
          const SizedBox(height: AppGap.sm),
          _Tip(
            pair: palette.savings,
            emoji: '🤝',
            title: '2. 약속 지키기',
            body: '부모님과의 약속을 지키면 이자율이 조금씩 올라가요. '
                '약속 하나를 지킬 때마다 연 이자가 0.3%씩 더 붙어요!',
          ),
          const SizedBox(height: AppGap.sm),
          _Tip(
            pair: palette.savings,
            emoji: '⏳',
            title: '3. 오래 두기',
            body: '받은 이자에 또 이자가 붙어요. 안 쓰고 오래 둘수록 눈덩이처럼 커져요.',
          ),
          const SizedBox(height: AppGap.xl),
          _NowCard(pair: palette.income, breakdown: breakdown),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final PastelPair pair;
  const _Hero({required this.pair});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Column(
        children: [
          const Text('💰  ➡️  ⏳  ➡️  💰💰', style: TextStyle(fontSize: AppText.numLg)),
          const SizedBox(height: AppGap.cozy),
          Text('모아두면 자라요',
              style: TextStyle(
                  fontSize: AppText.numMd, fontWeight: FontWeight.w900, color: pair.fg)),
          const SizedBox(height: AppGap.snug),
          Text('안 쓰고 모아둔 돈에\n얹어주는 돈 = 이자',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppText.bodyLg, height: 1.4, color: pair.fg)),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final PastelPair pair;
  final String emoji;
  final String title;
  final String body;
  const _Step(
      {required this.pair, required this.emoji, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppGap.lg),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: AppEmoji.md)),
          const SizedBox(width: AppGap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontSize: AppText.titleLg, fontWeight: FontWeight.w800, color: pair.fg)),
                const SizedBox(height: AppGap.snug),
                Text(body, style: TextStyle(fontSize: AppText.bodyLg, height: 1.5, color: pair.fg)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final PastelPair pair;
  final String emoji;
  final String title;
  final String body;
  const _Tip(
      {required this.pair, required this.emoji, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppGap.md),
      decoration: BoxDecoration(
        color: pair.bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: pair.fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: AppText.numLg)),
          const SizedBox(width: AppGap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: AppText.bodyLg, fontWeight: FontWeight.w800, color: pair.fg)),
                const SizedBox(height: AppGap.xs),
                Text(body, style: TextStyle(fontSize: AppText.body, height: 1.45, color: pair.fg)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
            child: Icon(Icons.keyboard_arrow_down,
                size: 28, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}

/// 지금 우리 이자율과 은행 이자율을 나란히 보여주는 마무리 카드.
/// "은행의 N배" 대신 두 이자율을 그대로 보여줘 아이가 스스로 비교하게 한다.
class _NowCard extends StatelessWidget {
  final PastelPair pair;
  final InterestBreakdown? breakdown;
  const _NowCard({required this.pair, this.breakdown});

  @override
  Widget build(BuildContext context) {
    final b = breakdown;
    return Container(
      padding: const EdgeInsets.all(AppGap.lg),
      decoration: BoxDecoration(
        color: pair.bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: pair.fg.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: AppText.numMd)),
              const SizedBox(width: AppGap.sm),
              Text('지금 우리집 이자는?',
                  style: TextStyle(fontSize: AppText.titleLg, fontWeight: FontWeight.w800, color: pair.fg)),
            ],
          ),
          const SizedBox(height: AppGap.cozy),
          if (b != null) ...[
            _RateTable(pair: pair, b: b),
            const SizedBox(height: AppGap.cozy),
            Text('약속을 지키면 우리 이자율이 조금씩 올라가요 🚀',
                style: TextStyle(fontSize: AppText.body, height: 1.45, color: pair.fg)),
          ] else
            Text('약속을 지키고 돈을 모을수록 이자가 쑥쑥 올라가요 🚀',
                style: TextStyle(fontSize: AppText.bodyLg, height: 1.5, color: pair.fg)),
        ],
      ),
    );
  }
}

/// 우리 연이율 vs 은행 연이율 + 이번 회차 이자 금액을 보여주는 표.
class _RateTable extends StatelessWidget {
  final PastelPair pair;
  final InterestBreakdown b;
  const _RateTable({required this.pair, required this.b});

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: AppText.body, color: pair.fg.withValues(alpha: 0.8))),
              Text(value,
                  style: TextStyle(
                      fontSize: AppText.body,
                      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                      color: pair.fg)),
            ],
          ),
        );
    return Container(
      padding: const EdgeInsets.all(AppGap.md),
      decoration: BoxDecoration(
        color: pair.fg.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          row('우리 이자율 (연)', '${formatPercent(b.annualPercent)}%', bold: true),
          if (b.promiseBonusAnnualPercent > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                  '(기본 ${formatPercent(b.baseAnnualPercent)}% + 약속 ${formatPercent(b.promiseBonusAnnualPercent)}%p)',
                  style: TextStyle(fontSize: AppText.caption, color: pair.fg.withValues(alpha: 0.7))),
            ),
          if (b.hasBankRate) row('은행 정기예금 (연)', '${formatPercent(b.bankAnnualPercent)}%'),
          const Divider(height: 14),
          row('${b.periodName} 받는 이자', formatWon(b.amount), bold: true),
        ],
      ),
    );
  }
}
