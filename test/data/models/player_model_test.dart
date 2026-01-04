import 'package:flutter_test/flutter_test.dart';
import 'package:memory_pair_game/data/models/player_model.dart';

void main() {
  group('PlayerModel', () {
    test('converts to and from json', () {
      const model = PlayerModel(
        name: 'Ava',
        totalScore: 4200,
        highestLevel: 5,
      );

      final map = model.toJson();
      final restored = PlayerModel.fromJson(map);

      expect(restored.name, model.name);
      expect(restored.totalScore, model.totalScore);
      expect(restored.highestLevel, model.highestLevel);
    });

    test('copyWithModel overrides selected fields', () {
      const model = PlayerModel(
        name: 'Jay',
        totalScore: 100,
        highestLevel: 1,
      );

      final updated = model.copyWithModel(
        totalScore: 350,
        highestLevel: 3,
      );

      expect(updated.name, model.name);
      expect(updated.totalScore, 350);
      expect(updated.highestLevel, 3);
    });
  });
}
