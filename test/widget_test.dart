import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/main.dart';

void main() {
  testWidgets('LinguaTomo queues an early level choice and enters the app', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: LinguaTomoApp()));
    expect(find.text('LinguaTomo'), findsOneWidget);

    // The choice is available immediately, even while Leo is still walking.
    expect(find.text('Starter'), findsOneWidget);
    await tester.ensureVisible(find.text('Starter'));
    await tester.pump();
    await tester.tap(find.text('Starter'));
    await tester.pump();
    expect(find.textContaining('Starter selected'), findsOneWidget);

    // Once preparation completes, the queued choice enters the dashboard.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump(const Duration(milliseconds: 500));

    // The loading picker uses the provider-backed onboarding path, so the app
    // enters its dashboard directly instead of asking for the same level again.
    final inAppShell = find.textContaining('words learned');
    expect(inAppShell, findsAtLeastNWidgets(1));
    expect(find.text('Welcome to LinguaTomo'), findsNothing);
  });
}
