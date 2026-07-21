import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/services/interest_calc.dart';

void main() {
  // 새 기준: 이자율 = 은행 정기예금(연 2.57%) × 배수 1 = 연 2.57%.
  // 약속은 1개당 연 +0.3%p (연이율에 더해짐).
  //   잔액 35,000원 / 주간 지급이면 회당(주) 이자율 = 2.57 ÷ 52 = 0.0494%
  //   → 35,000원의 0.0494% ≈ 17원
  const balance = 35000;
  const bankAnnual = 2.57;

  InterestBreakdown weekly({double bonusAnnual = 0}) => computeInterest(
        balance: balance,
        period: 0, // 주간
        useBankRate: true,
        multiplier: 1,
        fixedPercent: 1.0,
        promiseBonusAnnualPercent: bonusAnnual,
        bankAnnualPercent: bankAnnual,
      );

  test('약속 0개 - 은행과 동일한 연 2.57%', () {
    final b = weekly();
    expect(b.annualPercent, closeTo(2.57, 0.0001));
    expect(b.baseAnnualPercent, closeTo(2.57, 0.0001));
    expect(b.amount, 17); // 주간 이자
    expect(b.bankAmount, 17);
  });

  test('약속을 지키면 연이율이 1개당 +0.3%p씩 오른다', () {
    expect(weekly(bonusAnnual: 0.3).annualPercent, closeTo(2.87, 0.0001));
    expect(weekly(bonusAnnual: 0.9).annualPercent, closeTo(3.47, 0.0001));
  });

  test('약속 보너스는 연 단위라 회차 이자율에 52로 나눠 반영된다', () {
    final b = weekly(bonusAnnual: 0.52); // 연 +0.52%p → 주 +0.01%p
    expect(b.promiseBonusPeriodPercent, closeTo(0.01, 0.0001));
    expect(b.totalPercent, closeTo(b.basePercent + 0.01, 0.0001));
  });

  test('약속 보너스가 이자 금액에도 반영된다', () {
    // 잔액을 크게 잡아 반올림 영향을 줄인다.
    final b = computeInterest(
      balance: 1000000,
      period: 0,
      useBankRate: true,
      multiplier: 1,
      fixedPercent: 1.0,
      promiseBonusAnnualPercent: 5.2, // 연 +5.2%p = 주 +0.1%p → 1,000,000의 0.1% = 1,000원
      bankAnnualPercent: bankAnnual,
    );
    expect(b.amount - b.baseAmount, 1000);
  });

  test('은행 금리를 못 받아오면 고정 이율로 폴백한다', () {
    final b = computeInterest(
      balance: balance,
      period: 0,
      useBankRate: true,
      multiplier: 1,
      fixedPercent: 1.0,
      promiseBonusAnnualPercent: 0,
      bankAnnualPercent: null,
    );
    expect(b.hasBankRate, isFalse);
    expect(b.amount, 350); // 35,000원의 1%
  });

  test('은행연동을 끄면 고정 이율(회차 %)을 쓴다', () {
    final b = computeInterest(
      balance: balance,
      period: 0,
      useBankRate: false,
      multiplier: 1,
      fixedPercent: 0.5,
      promiseBonusAnnualPercent: 0,
      bankAnnualPercent: bankAnnual,
    );
    expect(b.amount, 175); // 35,000원의 0.5%
  });

  test('월간 지급은 연이율을 12로 나눈다', () {
    final b = computeInterest(
      balance: 1000000,
      period: 1, // 월간
      useBankRate: true,
      multiplier: 1,
      fixedPercent: 1.0,
      promiseBonusAnnualPercent: 0,
      bankAnnualPercent: 12.0, // 연 12% → 월 1%
    );
    expect(b.annualPercent, closeTo(12.0, 0.0001));
    expect(b.amount, 10000); // 1,000,000의 1%
  });

  test('잔액이 0이면 이자도 0', () {
    final b = weekly(bonusAnnual: 0.9);
    expect(b.amount, isNot(0));
    final zero = computeInterest(
      balance: 0,
      period: 0,
      useBankRate: true,
      multiplier: 1,
      fixedPercent: 1.0,
      promiseBonusAnnualPercent: 0.9,
      bankAnnualPercent: bankAnnual,
    );
    expect(zero.amount, 0);
  });
}
