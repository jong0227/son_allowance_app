/// 저축 이자 계산 결과.
///
/// 이자율은 "은행 정기예금(연 %)"에 맞추고, 약속을 지키면 연 이자율을 조금 더
/// 얹어준다. 아이가 스스로 "우리 이자 vs 은행 이자"를 비교할 수 있도록 두 값을
/// 함께 담는다.
class InterestBreakdown {
  final int balance;
  final int period; // 0=주간, 1=월간
  final double bankAnnualPercent; // 실제 은행 예금금리(연 %). 못 가져왔으면 0
  final double bankPeriodPercent; // 은행 금리를 1회분(주/월)로 환산한 %
  final double basePercent; // 우리집 기본 이자율(1회분 %) — 약속 보너스 제외
  /// 켜진 약속들의 이자 보너스 합(연 %p). 회차 이자율엔 연간 지급 횟수로 나눠 반영.
  final double promiseBonusAnnualPercent;

  const InterestBreakdown({
    required this.balance,
    required this.period,
    required this.bankAnnualPercent,
    required this.bankPeriodPercent,
    required this.basePercent,
    required this.promiseBonusAnnualPercent,
  });

  /// 약속 보너스를 1회분(주/월)로 환산한 %p.
  double get promiseBonusPeriodPercent =>
      promiseBonusAnnualPercent / periodsPerYear(period);

  /// 실제 적용 이자율(1회분 %) = 기본 + 약속 보너스(회차 환산).
  double get totalPercent => basePercent + promiseBonusPeriodPercent;

  /// 1년으로 환산한 전체 이자율(%). 화면에는 이 연이율을 대표로 보여준다.
  double get annualPercent => totalPercent * periodsPerYear(period);

  /// 약속 보너스를 뺀 기본 연이율(%). "약속 안 지켰을 때"의 이자율.
  double get baseAnnualPercent => basePercent * periodsPerYear(period);

  /// 이번 회차에 줄 이자(원).
  int get amount => balance <= 0 ? 0 : (balance * totalPercent / 100).round();

  /// 약속 보너스를 뺀 기본 이자(원). "약속 안 지켰을 때"의 이번 회차 이자.
  int get baseAmount => balance <= 0 ? 0 : (balance * basePercent / 100).round();

  /// 같은 돈을 진짜 은행에 맡겼다면 받았을 이번 회차 이자(원).
  int get bankAmount => balance <= 0 ? 0 : (balance * bankPeriodPercent / 100).round();

  bool get hasBankRate => bankAnnualPercent > 0 && bankPeriodPercent > 0;

  /// 은행의 몇 배인지(참고용). 은행 금리를 모르면 null.
  double? get multipleOfBank => hasBankRate ? totalPercent / bankPeriodPercent : null;

  String get periodName => period == 0 ? '이번 주' : '이번 달';
  String get periodUnit => period == 0 ? '주' : '월';
}

/// 1년에 이자를 몇 번 주는지. 주간=52, 월간=12.
int periodsPerYear(int period) => period == 0 ? 52 : 12;

/// 저축 이자를 계산한다.
///
/// [useBankRate]가 true이고 [bankAnnualPercent]를 알고 있으면
/// 기본 이자율 = (은행 연이율 ÷ 연간 지급횟수) × [multiplier] 로 잡는다.
/// (기본 배수는 1 → 은행 정기예금과 똑같은 이자율)
/// 은행 금리를 못 가져왔거나 은행연동을 끈 경우엔 [fixedPercent]를 그대로 쓴다.
///
/// [promiseBonusAnnualPercent]는 켜진 약속들의 이자 보너스 합(연 %p)이다.
InterestBreakdown computeInterest({
  required int balance,
  required int period,
  required bool useBankRate,
  required double multiplier,
  required double fixedPercent,
  required double promiseBonusAnnualPercent,
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
    promiseBonusAnnualPercent: promiseBonusAnnualPercent,
  );
}
