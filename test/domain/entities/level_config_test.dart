import 'package:flutter_test/flutter_test.dart';
import 'package:memory_pair_game/domain/entities/level_config.dart';

void main() {
  group('LevelConfig', () {
    test('computes derived counts', () {
      const config = LevelConfig(
        id: 1,
        rows: 3,
        cols: 4,
        timeLimitSeconds: 60,
        maxMoves: 20,
      );

      expect(config.totalCells, 12);
      expect(config.pairCount, 6);
    });

    test('serializes to and from json consistently', () {
      const config = LevelConfig(
        id: 7,
        rows: 5,
        cols: 5,
        timeLimitSeconds: 90,
        maxMoves: 40,
      );

      final map = config.toJson();
      final roundTripped = LevelConfig.fromJson(map);

      expect(roundTripped.id, config.id);
      expect(roundTripped.rows, config.rows);
      expect(roundTripped.cols, config.cols);
      expect(roundTripped.timeLimitSeconds, config.timeLimitSeconds);
      expect(roundTripped.maxMoves, config.maxMoves);
    });
  });
}
