import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_allowance_app/data/app_database.dart';
import 'package:son_allowance_app/data/quiz_bank.dart';
import 'package:son_allowance_app/providers/database_provider.dart';
import 'package:son_allowance_app/providers/quiz_provider.dart';
import 'package:son_allowance_app/providers/settings_provider.dart';
import 'package:son_allowance_app/screens/quiz_screen.dart';
import 'package:son_allowance_app/theme/app_theme.dart';

void main() {
  Future<(AppDatabase, Child)> setUpDb() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.upsertChild(ChildrenCompanion.insert(id: 'kid1', name: '테스트'));
    return (db, (await db.allChildrenRaw()).first);
  }

  Future<void> pumpQuiz(WidgetTester tester, AppDatabase db, Child child) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
      child: MaterialApp(theme: buildLightTheme(), home: QuizScreen(child: child)),
    ));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
  }

  /// 지금 화면에 떠 있는 문제(문제 문장으로 찾는다).
  QuizQuestion shownQuestion(WidgetTester tester) =>
      kQuizBank.firstWhere((q) => find.text(q.question).evaluate().isNotEmpty);

  Future<void> disposeQuiz(WidgetTester tester) async {
    // drift 스트림이 dispose 때 거는 타이머를 흘려보낸다.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  }

  group('보기 순서', () {
    test('정답 위치가 한쪽에 몰리지 않는다', () {
      final counts = <int, int>{};
      for (final q in kQuizBank) {
        final pos = q.displayOrder.indexOf(q.answerIndex);
        counts[pos] = (counts[pos] ?? 0) + 1;
      }
      // 보기가 3~4개라 위치 0은 대략 1/3 이하여야 한다(예전엔 100%).
      expect(counts[0]! / kQuizBank.length, lessThan(0.45), reason: '$counts');
      expect(counts[1] ?? 0, greaterThan(kQuizBank.length ~/ 5), reason: '$counts');
      expect(counts[2] ?? 0, greaterThan(kQuizBank.length ~/ 5), reason: '$counts');
    });

    test('같은 문제는 언제 열어도 같은 순서(기록 화면과 일치)', () {
      for (final q in kQuizBank) {
        expect(q.displayOrder, q.displayOrder);
        expect([...q.displayOrder]..sort(), List.generate(q.options.length, (i) => i));
      }
    });
  });

  group('문제은행', () {
    test('id가 겹치지 않고 정답 번호가 보기 범위 안', () {
      final ids = <String>{};
      for (final q in kQuizBank) {
        expect(ids.add(q.id), true, reason: '중복 id ${q.id}');
        expect(q.answerIndex, inInclusiveRange(0, q.options.length - 1));
        expect(q.options.toSet().length, q.options.length, reason: '${q.id} 보기 중복');
      }
    });

    test('시사(최신 뉴스) 문제를 먼저 낸다', () {
      final state = QuizState(attempts: const [], weekStart: AppDatabase.weekStartOf(DateTime.now()));
      final timely = kQuizBank.where((q) => q.timely).length;
      expect(timely, greaterThan(0));
      expect(state.unused.take(timely).every((q) => q.timely), true);
    });
  });

  group('퀴즈 화면', () {
    testWidgets('정답을 고르면 축하 카드와 해설이 남아 있고, 다음 문제는 버튼을 눌러야 나온다', (tester) async {
      final (db, child) = await setUpDb();
      addTearDown(db.close);
      await pumpQuiz(tester, db, child);

      final q = shownQuestion(tester);
      await tester.tap(find.text(q.answerText));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();

      expect(find.text('정답이에요!'), findsOneWidget);
      expect(find.text(q.explanation), findsOneWidget);
      expect(find.text(q.question), findsOneWidget, reason: '답하자마자 다음 문제로 넘어가면 안 된다');

      await tester.ensureVisible(find.text('다음 문제'));
      await tester.tap(find.text('다음 문제'));
      await tester.pump();
      expect(find.text(q.question), findsNothing);
      expect(find.text('2 / $kQuizPerWeek 문제'), findsOneWidget);
      await disposeQuiz(tester);
    });

    testWidgets('세 번째 문제를 맞혀도 결과 화면 전에 축하 카드를 보여준다', (tester) async {
      final (db, child) = await setUpDb();
      addTearDown(db.close);
      await pumpQuiz(tester, db, child);

      for (var i = 0; i < kQuizPerWeek; i++) {
        final q = shownQuestion(tester);
        await tester.tap(find.text(q.answerText));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump();
        expect(find.text('정답이에요!'), findsOneWidget, reason: '${i + 1}번째 문제');
        final next = find.text(i == kQuizPerWeek - 1 ? '결과 보기' : '다음 문제');
        await tester.ensureVisible(next);
        await tester.tap(next);
        await tester.pump();
      }
      expect(find.text('이번 주 퀴즈 끝!'), findsOneWidget);
      await disposeQuiz(tester);
    });

    testWidgets('틀린 뒤 다시 풀 때는 정답 위치가 바뀐다', (tester) async {
      final (db, child) = await setUpDb();
      addTearDown(db.close);
      await pumpQuiz(tester, db, child);

      final q = shownQuestion(tester);
      double answerY() => tester.getTopLeft(find.text(q.answerText)).dy;
      final before = answerY();
      final wrong = q.options.firstWhere((o) => o != q.answerText);
      await tester.tap(find.text(wrong));
      await tester.pump();
      // 해설 읽는 시간 기다리기
      await tester.pump(const Duration(seconds: 6));
      final retry = find.textContaining('다시 풀기');
      await tester.ensureVisible(retry);
      await tester.tap(retry);
      await tester.pump();
      await tester.scrollUntilVisible(find.text(q.answerText), -100);
      expect(answerY(), isNot(before));
      await disposeQuiz(tester);
    });
  });

  test('같은 문제 결과를 두 번 기록해도 보상은 한 번', () async {
    final (db, child) = await setUpDb();
    addTearDown(db.close);
    for (var i = 0; i < 2; i++) {
      await db.recordQuizAnswer(
          childId: child.id, questionId: 'q_sav_01', correct: true, firstTry: true, reward: 10, editedBy: '아들');
    }
    expect((await db.allQuizAttemptsRaw()).length, 1);
    final rewards = (await db.allTransactionsRaw()).where((t) => t.category == AppDatabase.kQuizReward);
    expect(rewards.length, 1);
  });
}
