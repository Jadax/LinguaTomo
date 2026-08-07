import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/data/word_bank.dart';
import 'package:linguatomo/views/word_lesson_view.dart';

/// `_words` briefly held `late final` while `_retryFailed` reassigned it,
/// which throws `LateInitializationError` at runtime on every single lesson
/// that falls below the pass gate — a core, frequently-hit path (and, for a
/// one-word lesson, any wrong answer at all). This drives that exact path.
void main() {
  testWidgets('failing a one-word lesson retries without crashing', (
    tester,
  ) async {
    final word = wordBankById['s_01']!;

    // flutter test's default surface (800x600) is wider than tall, unlike
    // any real phone; use a representative portrait size instead.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: WordLessonView(words: [word])),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.ensureVisible(find.byType(FilledButton));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Deliberately answer wrong: tap whichever option is not the answer.
    final optionTexts = tester
        .widgetList<Text>(
          find.descendant(of: find.byType(InkWell), matching: find.byType(Text)),
        )
        .map((t) => t.data)
        .toList();
    final wrongIndex = optionTexts.indexWhere((t) => t != word.english);
    expect(wrongIndex, greaterThanOrEqualTo(0));
    final wrongOption = find.byType(InkWell).at(wrongIndex);
    await tester.ensureVisible(wrongOption);
    await tester.pump();
    await tester.tap(wrongOption);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.ensureVisible(find.text('See results'));
    await tester.pump();
    await tester.tap(find.text('See results'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // A single wrong answer is below the pass gate for a one-word lesson.
    expect(find.text('Keep going!'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Try again'));
    await tester.pump();
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // This is the exact call that used to throw LateInitializationError.
    expect(tester.takeException(), isNull);
    expect(find.text("Got it!"), findsOneWidget);
  });
}
