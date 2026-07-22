import 'package:flutter_test/flutter_test.dart';
import 'package:linguatomo/data/grammar_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the complete attributed N5 to N1 grammar corpus', () async {
    final catalogue = await const GrammarRepository().load();

    expect(catalogue.points, hasLength(828));
    expect(catalogue.countFor('N5'), 136);
    expect(catalogue.countFor('N4'), 124);
    expect(catalogue.countFor('N3'), 132);
    expect(catalogue.countFor('N2'), 191);
    expect(catalogue.countFor('N1'), 245);
    expect(
      catalogue.points.every((point) => point.examples.isNotEmpty),
      isTrue,
    );
  });
}
