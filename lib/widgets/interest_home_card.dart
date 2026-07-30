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
import 'promises_home_card.dart';
import 'ui_kit.dart';

/// 홈의 "이번 주 저축 이자" 카드.
/// - 아직 안 받았으면: 큰 카드(연이율 + 이번 주 이자 + 받기 버튼).
/// - 이미 받았으면: 작은 카드로 접히고, 누르면 펼쳐진다(이자율은 잔액 카드에도
///   나오므로 평소엔 작게 둔다).
///
/// 부모님과의 약속 카드를 이 카드가 데리고 있는다. 약속은 이자율을 올려주는
/// 장치라 따로 떨어져 있으면 왜 있는지 알기 어렵고, 이자를 접었는데 약속만
/// 덩그러니 남아 있으면 어색하다. 그래서 접으면 같이 접힌다.
///
/// 다만 이자 기능이 꺼져 있거나 이자가 0원이라 이 카드를 못 그리는 상황에서는
/// 약속 카드를 단독으로 보여준다. 약속은 아이가 댓글을 남기는 곳이라
/// 이자 사정 때문에 통째로 사라지면 안 된다.
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
    final promises = ref.watch(promisesProvider(child.id)).valueOrNull ?? const [];
    final hasPromises = promises.isNotEmpty;

    if (!child.interestEnabled) return _promisesOnly(hasPromises);
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
    if (b.amount <= 0) return _promisesOnly(hasPromises);
    final pair = appPalette(context).savings;

    // 이미 받았다면 "실제로 받은 금액"을 보여준다. b.amount는 지금 잔액으로 다시
    // 계산한 값이라, 받은 뒤에 용돈이 들어오면 받지도 않은 큰 금액이 표시된다
    // (87원 받았는데 341원 받았다고 나오던 버그).
    final granted = ref
        .watch(grantedInterestProvider(
            (childId: child.id, period: child.interestPeriod)))
        .valueOrNull;
    final shownAmount = given ? (granted ?? b.amount) : b.amount;

    // 받은 뒤 + 접힘 상태: 작은 한 줄 카드. 약속도 이 안에 같이 접힌다.
    // 약속이 있으면 연이율 대신 약속 개수를 보여준다. 연이율은 잔액 카드에도
    // 있지만 약속이 여기 숨어 있다는 건 이 줄에만 표시할 수 있어서다.
    if (given && !_open) {
      return Padding(
        padding: const EdgeInsets.only(top: AppGap.md),
        child: MiniBar(
          pair: pair,
          text: hasPromises
              ? '${b.periodName} 이자 ${formatWon(shownAmount)} 받음 · 약속 ${promises.length}개'
              : '${b.periodName} 이자 ${formatWon(shownAmount)} 받음 · 연 ${formatPercent(b.annualPercent)}%',
          onTap: () => setState(() => _open = true),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppGap.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
        padding: const EdgeInsets.all(AppGap.lg),
        decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 제목 + (받았으면 접기 화살표 / 아니면 "이자가 뭐야?")
            Row(
              children: [
                Icon(given ? Icons.check_circle : Icons.savings_outlined,
                    color: pair.fg, size: 22),
                const SizedBox(width: AppGap.sm),
                Expanded(
                  child: Text(given ? '${b.periodName} 이자 받음' : '${b.periodName} 저축 이자',
                      style: TextStyle(
                          color: pair.fg, fontWeight: FontWeight.w800, fontSize: AppText.title)),
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
            const SizedBox(height: AppGap.cozy),
            // 연이율(크게) + 은행 정기예금 이율(작게, 오른쪽) 한 줄
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('연 ${formatPercent(b.annualPercent)}%',
                    style: TextStyle(
                        color: pair.fg,
                        fontSize: AppText.numLg,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5)),
                const Spacer(),
                if (b.hasBankRate)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text('은행예금이자는 연 ${formatPercent(b.bankAnnualPercent)}%',
                        style: TextStyle(
                            color: pair.fg.withValues(alpha: 0.85), fontSize: AppText.label)),
                  ),
              ],
            ),
            if (bonus > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('약속 보너스 연 +${formatPercent(bonus)}%p 포함',
                    style: TextStyle(
                        color: pair.fg.withValues(alpha: 0.85), fontSize: AppText.caption)),
              ),
            const SizedBox(height: AppGap.cozy),
            // 이번 주 이자 금액(왼쪽) + 받기 버튼 / 받음+이자설명(오른쪽)
            Row(
              children: [
                Expanded(
                  child: Text(
                      given
                          ? '${b.periodName} 이자 ${formatWon(shownAmount)} 받음'
                          : '${b.periodName} 이자 ${formatWon(shownAmount)}',
                      style: TextStyle(
                          color: pair.fg, fontSize: AppText.bodyLg, fontWeight: FontWeight.w700)),
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
            const SizedBox(height: AppGap.cozy),
            Align(
              alignment: Alignment.centerRight,
              child: _link(context, '이자지급이력보기', () => _openHistory(context)),
            ),
              ],
            ),
          ),
          // 약속은 이자율을 올려주는 장치라 이자 카드 바로 아래 붙인다.
          if (hasPromises) ...[
            const SizedBox(height: AppGap.md),
            PromisesHomeCard(child: child),
          ],
        ],
      ),
    );
  }

  /// 이자 카드를 못 그리는 상황(이자 기능 off / 이자 0원)에서 약속만 보여준다.
  Widget _promisesOnly(bool hasPromises) {
    if (!hasPromises) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppGap.md),
      child: PromisesHomeCard(child: child),
    );
  }

  Widget _link(BuildContext context, String text, VoidCallback onTap) {
    final pair = appPalette(context).savings;
    return InkWell(
      onTap: onTap,
      child: Text(text,
          style: TextStyle(
              color: pair.fg, fontSize: AppText.caption, decoration: TextDecoration.underline)),
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

