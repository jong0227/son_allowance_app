/// 저축 이자 계산 결과.
///
/// 아이에게 "은행이면 17원인데 우리집은 174원(은행의 10배!)"처럼 비교해서 보여주려고
/// 은행 기준 금액과 우리집 금액을 함께 담는다.
class InterestBreakdown {
  final int balance;
  final int period; // 0=주간, 1=월간
  final double bankAnnualPercent; // 실제 은행 예금금리(연 %). 못 가져왔으면 0
  final double bankPeriodPercent; // 은행 금리를 1회분(주/월)로 환산한 %
  final double basePercent; // 우리집 기본 이자율(1회분 %)
  final double promiseBonusPercent; // 켜진 약속들의 보너스 합(1회분 %p)

  const InterestBreakdown({
    required this.balance,
    required this.period,
    required this.bankAnnualPercent,
    required this.bankPeriodPercent,
    required this.basePercent,
    required this.promiseBonusPercent,
  });

  /// 실제 적용 이자율(1회분 %) = 기본 + 약속 보너스.
  double get totalPercent => basePercent + promiseBonusPercent;

  /// 이번 회차에 줄 이자(원).
  int get amount => balance <= 0 ? 0 : (balance * totalPercent / 100).round();

  /// 같은 돈을 진짜 은행에 맡겼다면 받았을 이자(원).
  int get bankAmount => balance <= 0 ? 0 : (balance * bankPeriodPercent / 100).round();

  bool get hasBankRate => bankAnnualPercent > 0 && bankPeriodPercent > 0;

  /// 은행의 몇 배인지. 은행 금리를 모르면 null.
  double? get multipleOfBank => hasBankRate ? totalPercent / bankPeriodPercent : null;

  String get periodName => period == 0 ? '이번 주' : '이번 달';
}

/// 1년에 이자를 몇 번 주는지. 주간=52, 월간=12.
int periodsPerYear(int period) => period == 0 ? 52 : 12;

/// 저축 이자를 계산한다.
///
/// [useBankRate]가 true이고 [bankAnnualPercent]를 알고 있으면
/// 기본 이자율 = (은행 연이율 ÷ 연간 지급횟수) × [multiplier] 로 잡는다.
/// 은행 금리를 못 가져왔거나 은행연동을 끈 경우엔 [fixedPercent]를 그대로 쓴다.
InterestBreakdown computeInterest({
  required int balance,
  required int period,
  required bool useBankRate,
  required double multiplier,
  required double fixedPercent,
  required double promiseBonusPercent,
  double? bankAnnualPercent,
}) {
  final perYear = periodsPerYear(period);
  final annual = bankAnnualPercent ?? 0;
  final bankPeriod = annual <= 0 ? 0.0 : annual / perYear;
  final base = (useBankRate && bankPeriod > 0) ? bankPeriod * multiplier : fixedPercent;
  return InterestBreakdown(
    balance: balance,
    period: period,
    bankAnnualPercent: annual,
    bankPeriodPercent: bankPeriod,
    basePercent: base,
    promiseBonusPercent: promiseBonusPercent,
  );
}
