import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';

/// 초등 2학년 눈높이의 "COFIX 금리란?" 설명 화면.
/// 큰 이모지 그림 + 쉬운 비유로 풀어서 설명한다.
class CofixExplainerScreen extends StatelessWidget {
  const CofixExplainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Scaffold(
      appBar: AppBar(title: const Text('COFIX 금리란?')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _Hero(palette: palette),
          const SizedBox(height: AppGap.xl),
          _Step(
            pair: palette.allowance,
            emoji: '🏦',
            title: '은행도 돈을 빌려요',
            body: '은행은 사람들한테 돈을 빌려주죠? 그런데 은행도 그 돈을 '
                '다른 곳에서 빌려와요. 문구점 아저씨가 도매상에서 물건을 떼오는 것처럼요.',
          ),
          _Arrow(),
          _Step(
            pair: palette.savings,
            emoji: '🧮',
            title: '빌릴 때 내는 이자들의 평균',
            body: '여러 은행이 돈을 빌릴 때 내는 이자를 다 모아서 평균을 낸 값이 '
                '바로 COFIX(코픽스)예요. "은행이 돈을 구하는 값"인 셈이죠.',
          ),
          _Arrow(),
          _Step(
            pair: palette.special,
            emoji: '🍎',
            title: '돈의 "도매 가격"이에요',
            body: '사과 도매 가격이 오르면 가게 사과값도 오르죠? COFIX가 오르면 '
                '은행 돈값이 비싸진 거라, 대출 이자도 오르고 예금(저축) 이자도 올라요.',
          ),
          const SizedBox(height: AppGap.xl),
          _Callout(pair: palette.income),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final AppPalette palette;
  const _Hero({required this.palette});

  @override
  Widget build(BuildContext context) {
    final pair = palette.savings;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Column(
        children: [
          const Text('🏦  ➕  🏦  ➕  🏦', style: TextStyle(fontSize: AppText.numXl)),
          const SizedBox(height: AppGap.xs),
          const Text('⬇️', style: TextStyle(fontSize: AppText.numMd)),
          const SizedBox(height: AppGap.xs),
          Text('COFIX',
              style: TextStyle(
                  fontSize: AppText.numXl, fontWeight: FontWeight.w900, letterSpacing: 1, color: pair.fg)),
          const SizedBox(height: AppGap.snug),
          Text('은행들이 돈을 빌릴 때\n내는 이자의 평균값',
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
  const _Step({required this.pair, required this.emoji, required this.title, required this.body});

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

class _Arrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
            child: Icon(Icons.keyboard_arrow_down,
                size: 28, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}

class _Callout extends StatelessWidget {
  final PastelPair pair;
  const _Callout({required this.pair});

  @override
  Widget build(BuildContext context) {
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
              Text('그래서 우리 저축은?',
                  style: TextStyle(fontSize: AppText.titleLg, fontWeight: FontWeight.w800, color: pair.fg)),
            ],
          ),
          const SizedBox(height: AppGap.sm),
          Text('진짜 은행이 저축에 이자를 주는 것처럼, 우리 앱도 모아둔 돈에 이자를 줘요. '
              '그리고 부모님과의 약속을 잘 지키면 이자를 조금 더 받을 수 있어요!',
              style: TextStyle(fontSize: AppText.bodyLg, height: 1.5, color: pair.fg)),
        ],
      ),
    );
  }
}
