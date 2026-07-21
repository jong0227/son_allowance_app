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
          const SizedBox(height: 20),
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
                '그래서 엄마아빠는 진짜 은행보다 훨씬 많이 준답니다.',
          ),
          const SizedBox(height: 22),
          Text('이자를 더 많이 받는 3가지 방법',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _Tip(
            pair: palette.savings,
            emoji: '📦',
            title: '1. 많이 모으기',
            body: '이자는 모아둔 돈에서 나와요. 많이 모을수록 이자도 커져요.',
          ),
          const SizedBox(height: 8),
          _Tip(
            pair: palette.savings,
            emoji: '🤝',
            title: '2. 약속 지키기',
            body: '부모님과의 약속을 지키면 이자율이 올라가요. '
                '약속 하나를 지킬 때마다 은행보다 2배씩 더 받을 수 있어요!',
          ),
          const SizedBox(height: 8),
          _Tip(
            pair: palette.savings,
            emoji: '⏳',
            title: '3. 오래 두기',
            body: '받은 이자에 또 이자가 붙어요. 안 쓰고 오래 둘수록 눈덩이처럼 커져요.',
          ),
          const SizedBox(height: 22),
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
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Text('💰  ➡️  ⏳  ➡️  💰💰', style: TextStyle(fontSize: 26)),
          const SizedBox(height: 10),
          Text('모아두면 자라요',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: pair.fg)),
          const SizedBox(height: 6),
          Text('안 쓰고 모아둔 돈에\n얹어주는 돈 = 이자',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.4, color: pair.fg)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(18)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 38)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: pair.fg)),
                const SizedBox(height: 6),
                Text(body, style: TextStyle(fontSize: 14, height: 1.5, color: pair.fg)),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: pair.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: pair.fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: pair.fg)),
                const SizedBox(height: 3),
                Text(body, style: TextStyle(fontSize: 13.5, height: 1.45, color: pair.fg)),
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

/// 지금 실제로 은행보다 몇 배 받고 있는지 보여주는 마무리 카드.
class _NowCard extends StatelessWidget {
  final PastelPair pair;
  final InterestBreakdown? breakdown;
  const _NowCard({required this.pair, this.breakdown});

  @override
  Widget build(BuildContext context) {
    final b = breakdown;
    final multiple = b?.multipleOfBank;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: pair.bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: pair.fg.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text('지금 우리집 이자는?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: pair.fg)),
            ],
          ),
          const SizedBox(height: 10),
          if (b != null && multiple != null) ...[
            Text('은행에 맡기면 ${formatWon(b.bankAmount)}',
                style: TextStyle(fontSize: 14, color: pair.fg)),
            Text('우리집은 ${formatWon(b.amount)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: pair.fg)),
            const SizedBox(height: 6),
            Text('은행의 ${formatPercent(multiple)}배!',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: pair.fg)),
            const SizedBox(height: 8),
            Text('약속을 더 지키면 이 배수가 더 올라가요 🚀',
                style: TextStyle(fontSize: 13.5, height: 1.45, color: pair.fg)),
          ] else
            Text('약속을 지키고 돈을 모을수록 이자가 쑥쑥 올라가요 🚀',
                style: TextStyle(fontSize: 14, height: 1.5, color: pair.fg)),
        ],
      ),
    );
  }
}
