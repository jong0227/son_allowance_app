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
                BoxDecoration(color: heroPair.bg, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Text(topic.emoji, style: const TextStyle(fontSize: 46)),
                const SizedBox(height: 8),
                Text(topic.title,
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900, color: heroPair.fg)),
                const SizedBox(height: 6),
                Text(topic.summary,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.4, color: heroPair.fg)),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: palette.income.bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: palette.income.fg.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(topic.callout,
                      style: TextStyle(
                          fontSize: 14.5, height: 1.5, color: palette.income.fg)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(18)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.title,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: pair.fg)),
                const SizedBox(height: 6),
                Text(section.body,
                    style: TextStyle(fontSize: 14, height: 1.5, color: pair.fg)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
