import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/main.dart';

void main() {
  testWidgets('LinguaTomo opens with its guided journey choice', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: LinguaTomoApp()));
    expect(find.text('LinguaTomo'), findsOneWidget);
    // The loading chase stays active until preparation finishes, then plays
    // a short catch finale before the app opens.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Welcome to LinguaTomo'), findsOneWidget);
    expect(find.text('Starter'), findsOneWidget);
    expect(find.text('Expert'), findsOneWidget);

    await tester.ensureVisible(find.text('Starter'));
    await tester.pump();
    await tester.tap(find.text('Starter'));
    await tester.pump();
    await tester.ensureVisible(find.text('Show my route'));
    await tester.pump();
    await tester.tap(find.text('Show my route'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Welcome home'), findsOneWidget);
    expect(find.text('START HERE · YOUR FIRST CAN-DO'), findsOneWidget);
    expect(find.text('Meet the characters'), findsNothing);

    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();

    expect(find.text('Your learning library'), findsOneWidget);
    expect(find.text('Grammar course atlas'), findsOneWidget);
  });
}
