import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/widgets/leo_sprite.dart';

/// `LeoLoadingScreen` is the very first thing every launch shows. A learner
/// who already finished onboarding must never be asked to pick a level
/// again — the screen should play its splash and dismiss itself the moment
/// preparation finishes, with no picker in sight.
void main() {
  testWidgets(
    'a returning learner is never asked to choose a level again',
    (tester) async {
      var finished = false;
      var ready = false;
      late StateSetter setReady;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              setReady = setState;
              return LeoLoadingScreen(
                reduceMotion: true,
                ready: ready,
                needsLevelChoice: false,
                onFinished: () => finished = true,
              );
            },
          ),
        ),
      );
      await tester.pump();

      // No tier picker for a returning learner, at any point during loading.
      expect(find.text('Choose your level'), findsNothing);
      expect(find.text('Pick your level to begin!'), findsNothing);
      expect(find.textContaining('Welcome back'), findsOneWidget);
      expect(finished, isFalse);

      // Preparation finishes; the screen must dismiss itself without any tap.
      setReady(() => ready = true);
      await tester.pump();

      expect(find.text('Choose your level'), findsNothing);
      expect(finished, isTrue);
    },
  );

  testWidgets('a first-time learner must still choose a level', (
    tester,
  ) async {
    var finishedCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: LeoLoadingScreen(
          reduceMotion: true,
          ready: true,
          needsLevelChoice: true,
          onFinished: () => finishedCount++,
        ),
      ),
    );
    await tester.pump();

    // Ready, but nothing chosen yet — must wait for a tier tap.
    expect(find.text('Choose your level'), findsOneWidget);
    expect(finishedCount, 0);

    await tester.tap(find.text('Starter'));
    await tester.pump();

    expect(finishedCount, 1);
  });
}
