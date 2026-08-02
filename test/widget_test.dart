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

    // Selecting a level enters the route immediately.
    await tester.ensureVisible(find.text('Starter'));
    await tester.pump();
    await tester.tap(find.text('Starter'));
    await tester.pump(const Duration(milliseconds: 500));

    // The loading picker uses the provider-backed onboarding path, so the app
    // enters its dashboard directly instead of asking for the same level again.
    final inAppShell = find.textContaining('words learned');
    expect(inAppShell, findsAtLeastNWidgets(1));
    expect(find.text('Welcome to LinguaTomo'), findsNothing);
  });
}
