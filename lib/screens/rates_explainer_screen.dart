import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';

/// 초등 저학년 눈높이의 "금리란?" 설명 화면.
/// 오늘의 금리에 나오는 세 가지 — 기준금리 / 정기예금 1년 / COFIX — 를 한 번에 풀어준다.
class RatesExplainerScreen extends StatelessWidget {
  const RatesExplainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Scaffold(
      appBar: AppBar(title: const Text('금리란?')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _Hero(pair: palette.savings),
          const SizedBox(height: 20),
          Text('오늘의 금리에 나오는 3가지',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _Step(
            pair: palette.allowance,
            emoji: '🏛️',
            title: '기준금리',
            body: '한국은행(나라의 은행)이 정하는 "대표 금리"예요. '
                '모든 금리의 출발점이라, 기준금리가 오르면 예금·대출 이자도 따라 올라요.',
          ),
          _Arrow(),
          _Step(
            pair: palette.income,
            emoji: '🐷',
            title: '정기예금 1년',
            body: '은행에 돈을 1년 동안 맡기면 주는 이자예요. '
                '서원이 저축 이자도 바로 이 금리에 맞춰서 준답니다.',
          ),
          _Arrow(),
          _Step(
            pair: palette.special,
            emoji: '🏦',
            title: 'COFIX(코픽스)',
            body: '여러 은행이 돈을 빌려올 때 내는 이자의 평균값이에요. '
                '"은행이 돈을 구하는 값"이라, 이게 오르면 대출 이자가 올라요. (대출의 기준)',
          ),
          const SizedBox(height: 20),
          _Callout(pair: palette.savings),
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
          const Text('💰  ↔️  🏦', style: TextStyle(fontSize: 30)),
          const SizedBox(height: 10),
          Text('금리 = 돈을 빌리고\n빌려줄 때의 값',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20, height: 1.35, fontWeight: FontWeight.w900, color: pair.fg)),
          const SizedBox(height: 6),
          Text('돈에도 "값"이 있어요. 그 값이 바로 금리예요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, height: 1.4, color: pair.fg)),
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
      margin: const EdgeInsets.only(bottom: 2),
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

class _Arrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
            child: Icon(Icons.keyboard_arrow_down,
                size: 26, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}

class _Callout extends StatelessWidget {
  final PastelPair pair;
  const _Callout({required this.pair});

  @override
  Widget build(BuildContext context) {
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
              Text('그래서 우리 저축은?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: pair.fg)),
            ],
          ),
          const SizedBox(height: 8),
          Text('우리 저축 이자는 "정기예금 1년" 금리에 맞춰져 있어요. '
              '진짜 은행 금리가 오르내리면 서원이 이자도 같이 움직인답니다!',
              style: TextStyle(fontSize: 14, height: 1.5, color: pair.fg)),
        ],
      ),
    );
  }
}
