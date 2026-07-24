import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/rates_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/category_history_screen.dart';
import '../screens/interest_explainer_screen.dart';
import '../services/interest_calc.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'interest_celebration.dart';
import 'ui_kit.dart';

/// 홈의 "이번 주 저축 이자" 카드.
/// - 아직 안 받았으면: 큰 카드(연이율 + 이번 주 이자 + 받기 버튼).
/// - 이미 받았으면: 작은 카드로 접히고, 누르면 펼쳐진다(이자율은 잔액·약속 카드에도
///   나오므로 평소엔 작게 둔다).
class InterestHomeCard extends ConsumerStatefulWidget {
  final Child child;
  const InterestHomeCard({super.key, required this.child});

  @override
  ConsumerState<InterestHomeCard> createState() => _InterestHomeCardState();
}

class _InterestHomeCardState extends ConsumerState<InterestHomeCard> {
  bool _open = false;

  Child get child => widget.child;

  @override
  Widget build(BuildContext context) {
    if (!child.interestEnabled) return const SizedBox.shrink();
    final given = ref
            .watch(interestGivenProvider((childId: child.id, period: child.interestPeriod)))
            .valueOrNull ??
        false;
    final bonus = ref.watch(promiseBonusProvider(child.id)).valueOrNull ?? 0.0;
    final bankRate = ref.watch(depositRateProvider).valueOrNull;
    final balance = ref.watch(summaryProvider(child.id)).valueOrNull?['balance'] ?? 0;
    final b = computeInterest(
      balance: balance,
      period: child.interestPeriod,
      useBankRate: child.interestUseBankRate,
      multiplier: child.interestMultiplier,
      fixedPercent: child.interestPercent,
      promiseBonusAnnualPercent: bonus,
      bankAnnualPercent: bankRate,
    );
    if (b.amount <= 0) return const SizedBox.shrink();
    final pair = appPalette(context).savings;

    // 받은 뒤 + 접힘 상태: 작은 한 줄 카드.
    if (given && !_open) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: _MiniBar(
          pair: pair,
          text: '${b.periodName} 이자 ${formatWon(b.amount)} 받음 · 연 ${formatPercent(b.annualPercent)}%',
          onTap: () => setState(() => _open = true),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 제목 + (받았으면 접기 화살표 / 아니면 "이자가 뭐야?")
            Row(
              children: [
                Icon(given ? Icons.check_circle : Icons.savings_outlined,
                    color: pair.fg, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(given ? '${b.periodName} 이자 받음' : '${b.periodName} 저축 이자',
                      style: TextStyle(
                          color: pair.fg, fontWeight: FontWeight.w800, fontSize: 15)),
                ),
                if (given)
                  InkWell(
                    onTap: () => setState(() => _open = false),
                    child: Icon(Icons.expand_less,
                        color: pair.fg.withValues(alpha: 0.8), size: 20),
                  )
                else
                  _link(context, '이자가 뭐야?',
                      () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => InterestExplainerScreen(breakdown: b)))),
              ],
            ),
            const SizedBox(height: 10),
            // 연이율(크게) + 은행 정기예금 이율(작게, 오른쪽) 한 줄
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('연 ${formatPercent(b.annualPercent)}%',
                    style: TextStyle(
                        color: pair.fg,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5)),
                const Spacer(),
                if (b.hasBankRate)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text('은행예금이자는 연 ${formatPercent(b.bankAnnualPercent)}%',
                        style: TextStyle(
                            color: pair.fg.withValues(alpha: 0.85), fontSize: 12)),
                  ),
              ],
            ),
            if (bonus > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('약속 보너스 연 +${formatPercent(bonus)}%p 포함',
                    style: TextStyle(
                        color: pair.fg.withValues(alpha: 0.85), fontSize: 11.5)),
              ),
            const SizedBox(height: 10),
            // 이번 주 이자 금액(왼쪽) + 받기 버튼 / 받음+이자설명(오른쪽)
            Row(
              children: [
                Expanded(
                  child: Text(
                      given
                          ? '${b.periodName} 이자 ${formatWon(b.amount)} 받음'
                          : '${b.periodName} 이자 ${formatWon(b.amount)}',
                      style: TextStyle(
                          color: pair.fg, fontSize: 14, fontWeight: FontWeight.w700)),
                ),
                if (given)
                  _link(context, '이자가 뭐야?',
                      () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => InterestExplainerScreen(breakdown: b))))
                else
                  FilledButton(
                    onPressed: () => _giveInterest(bankRate),
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                    child: Text('+${formatWon(b.amount)} 받기'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: _link(context, '이자지급이력보기', () => _openHistory(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _link(BuildContext context, String text, VoidCallback onTap) {
    final pair = appPalette(context).savings;
    return InkWell(
      onTap: onTap,
      child: Text(text,
          style: TextStyle(
              color: pair.fg, fontSize: 11.5, decoration: TextDecoration.underline)),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CategoryHistoryScreen(
        childId: child.id,
        category: AppDatabase.kInterest,
        title: '저축 이자 지급 이력',
        icon: Icons.savings_outlined,
      ),
    ));
  }

  Future<void> _giveInterest(double? bankRate) async {
    final owner = ref.read(settingsProvider).deviceOwner ?? '';
    final granted = await ref
        .read(databaseProvider)
        .giveInterest(child, owner, bankAnnualPercent: bankRate);
    if (granted != null && mounted) {
      await showInterestCelebration(context, breakdown: granted);
    }
  }
}

/// 접힌 상태의 작은 한 줄 카드.
class _MiniBar extends StatelessWidget {
  final PastelPair pair;
  final String text;
  final VoidCallback onTap;
  const _MiniBar({required this.pair, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: pair.bg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 19, color: pair.fg),
              const SizedBox(width: 10),
              Expanded(
                child: Text(text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: pair.fg)),
              ),
              Icon(Icons.expand_more, size: 18, color: pair.fg.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
