import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/data/curriculum_data.dart';

void main() {
  final japanese = RegExp(r'[\u3040-\u30ff\u3400-\u9fff]');

  test('missions form a valid ordered beginner-to-professional route', () {
    expect(missions, isNotEmpty);
    expect(
      missions.map((mission) => mission.id).toSet(),
      hasLength(missions.length),
    );

    final seen = <String>{};
    var previousStage = -1;
    for (final mission in missions) {
      expect(mission.stage.index, greaterThanOrEqualTo(previousStage));
      expect(
        mission.correctOption,
        inInclusiveRange(0, mission.options.length - 1),
      );
      expect(mission.options, hasLength(greaterThanOrEqualTo(3)));
      expect(japanese.hasMatch(mission.phrase), isTrue, reason: mission.id);
      expect(mission.reading.trim(), isNotEmpty, reason: mission.id);
      expect(mission.translation.trim(), isNotEmpty, reason: mission.id);
      expect(mission.canDo.startsWith('I can '), isTrue, reason: mission.id);
      expect(mission.phrase.contains('�'), isFalse, reason: mission.id);
      if (mission.prerequisite != null) {
        expect(seen, contains(mission.prerequisite), reason: mission.id);
      }
      previousStage = mission.stage.index;
      seen.add(mission.id);
    }
  });

  test('postcards contain distinct, usable Japanese study sets', () {
    expect(
      postcards.map((postcard) => postcard.id).toSet(),
      hasLength(postcards.length),
    );
    for (final postcard in postcards) {
      expect(postcard.words, hasLength(3), reason: postcard.id);
      expect(japanese.hasMatch(postcard.phrase), isTrue, reason: postcard.id);
      expect(
        postcard.words.every(japanese.hasMatch),
        isTrue,
        reason: postcard.id,
      );
      expect(postcard.translation.trim(), isNotEmpty, reason: postcard.id);
      expect(postcard.cultureNote.trim(), isNotEmpty, reason: postcard.id);
    }
  });
}
