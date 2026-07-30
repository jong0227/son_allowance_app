import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/economy_topics.dart';
import '../providers/topic_progress_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';

/// 경제상식 주제 하나를 보여주는 공용 설명 화면.
/// 주제 내용은 [EconomyTopic] 데이터로 정의돼 있어, 새 주제를 추가할 때
/// 화면을 새로 만들 필요 없이 데이터만 넣으면 된다.
/// 화면을 열면 "읽음"으로 기록돼 진행률에 반영된다.
class TopicExplainerScreen extends ConsumerStatefulWidget {
  final EconomyTopic topic;
  const TopicExplainerScreen({super.key, required this.topic});

  @override
  ConsumerState<TopicExplainerScreen> createState() => _TopicExplainerScreenState();
}

class _TopicExplainerScreenState extends ConsumerState<TopicExplainerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(readTopicsProvider.notifier).markRead(widget.topic.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final palette = appPalette(context);
    // 주제별로 색을 바꿔 지루하지 않게(고정 매핑이라 매번 같은 색).
    final pairs = [
      palette.savings,
      palette.allowance,
      palette.special,
      palette.income,
      palette.expense,
    ];
    final heroPair = pairs[topic.id.hashCode.abs() % pairs.length];

    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
            decoration:
                BoxDecoration(color: heroPair.bg, borderRadius: BorderRadius.circular(AppRadius.xl)),
            child: Column(
              children: [
                Text(topic.emoji, style: const TextStyle(fontSize: AppEmoji.lg)),
                const SizedBox(height: AppGap.sm),
                Text(topic.title,
                    style: TextStyle(
                        fontSize: AppText.numMd, fontWeight: FontWeight.w900, color: heroPair.fg)),
                const SizedBox(height: AppGap.snug),
                Text(topic.summary,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: AppText.bodyLg, height: 1.4, color: heroPair.fg)),
              ],
            ),
          ),
          const SizedBox(height: AppGap.xl),
          for (var i = 0; i < topic.sections.length; i++) ...[
            _SectionCard(
              section: topic.sections[i],
              pair: pairs[(i + 1) % pairs.length],
            ),
            if (i < topic.sections.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Center(
                    child: Icon(Icons.keyboard_arrow_down,
                        size: 26, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
          ],
          const SizedBox(height: AppGap.xl),
          Container(
            padding: const EdgeInsets.all(AppGap.lg),
            decoration: BoxDecoration(
              color: palette.income.bg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: palette.income.fg.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⭐', style: TextStyle(fontSize: AppText.numMd)),
                const SizedBox(width: AppGap.cozy),
                Expanded(
                  child: Text(topic.callout,
                      style: TextStyle(
                          fontSize: AppText.bodyLg, height: 1.5, color: palette.income.fg)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final TopicSection section;
  final PastelPair pair;
  const _SectionCard({required this.section, required this.pair});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppGap.lg),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.emoji, style: const TextStyle(fontSize: AppEmoji.sm)),
          const SizedBox(width: AppGap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.title,
                    style:
                        TextStyle(fontSize: AppText.titleLg, fontWeight: FontWeight.w800, color: pair.fg)),
                const SizedBox(height: AppGap.snug),
                Text(section.body,
                    style: TextStyle(fontSize: AppText.bodyLg, height: 1.5, color: pair.fg)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
