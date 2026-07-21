import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/services/interest_calc.dart';

void main() {
  // 설계 기준: 잔액 35,000원 / 정기예금 연 2.57% / 주간 지급 / 은행의 6배
  //   은행 주간 = 2.57 ÷ 52 = 0.0494%  →  35,000원의 0.0494% = 17원
  //   우리집    = 0.0494 × 6 = 0.2965% →  35,000원의 0.2965% = 104원
  // 약속 하나(+0.1%p)는 은행 주간이율의 약 2배라 "약속 1개 = 은행 2배 추가"가 된다.
  const balance = 35000;
  const bankAnnual = 2.57;

  InterestBreakdown weekly({double bonus = 0}) => computeInterest(
        balance: balance,
        period: 0, // 주간
        useBankRate: true,
        multiplier: 6,
        fixedPercent: 1.0,
        promiseBonusPercent: bonus,
        bankAnnualPercent: bankAnnual,
      );

  test('약속 0개 - 은행의 6배, 주 약 100원', () {
    final b = weekly();
    expect(b.amount, 104);
    expect(b.bankAmount, 17);
    expect(b.multipleOfBank!, closeTo(6.0, 0.001));
  });

  test('약속을 지킬수록 은행 대비 배수가 2배씩 오른다', () {
    expect(weekly(bonus: 0.1).multipleOfBank!, closeTo(8.02, 0.05));
    expect(weekly(bonus: 0.2).multipleOfBank!, closeTo(10.05, 0.05));
    expect(weekly(bonus: 0.3).multipleOfBank!, closeTo(12.07, 0.05));
  });

  test('약속 보너스가 금액에 반영된다', () {
    expect(weekly(bonus: 0.1).amount, 139);
    expect(weekly(bonus: 0.2).amount, 174);
    expect(weekly(bonus: 0.3).amount, 209);
  });

  test('은행 금리를 못 받아오면 고정 이율로 폴백한다', () {
    final b = computeInterest(
      balance: balance,
      period: 0,
      useBankRate: true,
      multiplier: 6,
      fixedPercent: 1.0,
      promiseBonusPercent: 0,
      bankAnnualPercent: null,
    );
    expect(b.hasBankRate, isFalse);
    expect(b.multipleOfBank, isNull);
    expect(b.amount, 350); // 35,000원의 1%
  });

  test('은행연동을 끄면 고정 이율을 쓴다', () {
    final b = computeInterest(
      balance: balance,
      period: 0,
      useBankRate: false,
      multiplier: 6,
      fixedPercent: 0.5,
      promiseBonusPercent: 0,
      bankAnnualPercent: bankAnnual,
    );
    expect(b.amount, 175); // 35,000원의 0.5%
  });

  test('월간 지급은 12로 나눈다', () {
    final b = computeInterest(
      balance: balance,
      period: 1, // 월간
      useBankRate: true,
      multiplier: 6,
      fixedPercent: 1.0,
      promiseBonusPercent: 0,
      bankAnnualPercent: bankAnnual,
    );
    // 2.57 ÷ 12 × 6 = 1.285% → 35,000원의 1.285% = 450원
    expect(b.amount, 450);
    expect(b.multipleOfBank!, closeTo(6.0, 0.001));
  });

  test('주간 지급의 주/월/년 환산 이자율이 정확하다', () {
    final b = weekly(); // 1회분(주간) 0.2965%
    expect(b.weeklyPercent, closeTo(b.totalPercent, 0.0001));
    expect(b.monthlyPercent, closeTo(b.totalPercent * 52 / 12, 0.0001));
    expect(b.annualPercent, closeTo(b.totalPercent * 52, 0.0001));
  });

  test('월간 지급의 주/월/년 환산 이자율이 정확하다', () {
    final b = computeInterest(
      balance: balance,
      period: 1, // 월간
      useBankRate: true,
      multiplier: 6,
      fixedPercent: 1.0,
      promiseBonusPercent: 0,
      bankAnnualPercent: bankAnnual,
    );
    expect(b.monthlyPercent, closeTo(b.totalPercent, 0.0001));
    expect(b.weeklyPercent, closeTo(b.totalPercent * 12 / 52, 0.0001));
    expect(b.annualPercent, closeTo(b.totalPercent * 12, 0.0001));
  });

  test('잔액이 0이면 이자도 0', () {
    final b = computeInterest(
      balance: 0,
      period: 0,
      useBankRate: true,
      multiplier: 6,
      fixedPercent: 1.0,
      promiseBonusPercent: 0.3,
      bankAnnualPercent: bankAnnual,
    );
    expect(b.amount, 0);
  });
}
