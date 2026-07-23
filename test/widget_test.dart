import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/main.dart';

void main() {
  testWidgets('LinguaTomo opens loading screen, user picks level, enters app', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: LinguaTomoApp()));
    expect(find.text('LinguaTomo'), findsOneWidget);

    // Loading chase stays active until preparation finishes, then plays
    // the catch finale. The screen now waits for user input.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump(const Duration(milliseconds: 900));

    // After catch: tier picker is still visible, status text updated.
    expect(find.text('Pick your level to begin!'), findsOneWidget);
    expect(find.text('Starter'), findsOneWidget);
    expect(find.text('Expert'), findsOneWidget);

    // Select a level and tap Start.
    await tester.ensureVisible(find.text('Starter'));
    await tester.pump();
    await tester.tap(find.text('Starter'));
    await tester.pump();
    await tester.ensureVisible(find.text('Start learning'));
    await tester.pump();
    await tester.tap(find.text('Start learning'));
    await tester.pump(const Duration(milliseconds: 300));

    // Loading screen dismissed. Depending on Hive state the app either
    // shows AppShell or WelcomeJourneyView. Both contain Leo.
    final inAppShell = find.textContaining('words learned');
    final inWelcome = find.text('Welcome to LinguaTomo');
    expect(
      inAppShell.evaluate().isNotEmpty || inWelcome.evaluate().isNotEmpty,
      isTrue,
      reason: 'Expected AppShell or WelcomeJourneyView after loading',
    );

    // If WelcomeJourneyView, pick a tier and continue into the app.
    if (inWelcome.evaluate().isNotEmpty) {
      await tester.ensureVisible(find.text('Starter'));
      await tester.pump();
      await tester.tap(find.text('Starter'));
      await tester.pump();
      await tester.ensureVisible(find.text('Start learning'));
      await tester.pump();
      await tester.tap(find.text('Start learning'));
      await tester.pump(const Duration(milliseconds: 300));
    }
  });
}
