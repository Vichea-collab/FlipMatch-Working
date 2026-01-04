import 'package:flutter_test/flutter_test.dart';

import 'package:memory_pair_game/domain/entities/level_config.dart';
import 'package:memory_pair_game/domain/repositories/level_repository.dart';
import 'package:memory_pair_game/domain/services/game_service.dart';

void main() {
  late GameService service;

  setUp(() {
    service = GameService(_FakeLevelRepository());
  });

  test('generateCards creates paired cards with expected counts', () {
    const level = LevelConfig(
      id: 1,
      rows: 3,
      cols: 4, // 12 cells => 6 pairs, no placeholders
      timeLimitSeconds: 60,
      maxMoves: 20,
    );

    final cards = service.generateCards(level);

    expect(cards, hasLength(level.totalCells));

    final placeholders = cards.where((c) => c.isPlaceholder).toList();
    expect(placeholders, isEmpty);

    final nonPlaceholders = cards.where((c) => !c.isPlaceholder).toList();
    expect(nonPlaceholders.length, equals(level.pairCount * 2));

    // Each symbol should appear exactly twice.
    final counts = <String, int>{};
    for (final card in nonPlaceholders) {
      counts.update(card.symbol, (value) => value + 1, ifAbsent: () => 1);
    }
    expect(counts.values.every((count) => count == 2), isTrue);
  });

  test('generateCards adds placeholders for odd grids', () {
    const level = LevelConfig(
      id: 2,
      rows: 3,
      cols: 3, // 9 cells => 4 pairs + 1 placeholder
      timeLimitSeconds: 45,
      maxMoves: 15,
    );

    final cards = service.generateCards(level);

    expect(cards, hasLength(level.totalCells));

    final placeholders = cards.where((c) => c.isPlaceholder).toList();
    expect(placeholders, hasLength(1));
    expect(placeholders.every((c) => c.isMatched && c.symbol.isEmpty), isTrue);

    final nonPlaceholders = cards.where((c) => !c.isPlaceholder).toList();
    expect(nonPlaceholders.length, equals(level.pairCount * 2));

    final counts = <String, int>{};
    for (final card in nonPlaceholders) {
      counts.update(card.symbol, (value) => value + 1, ifAbsent: () => 1);
    }
    expect(counts.values.every((count) => count == 2), isTrue);
  });

  test('calculateScore returns 0 on loss', () {
    const level = LevelConfig(
      id: 3,
      rows: 4,
      cols: 4,
      timeLimitSeconds: 50,
      maxMoves: 25,
    );

    final score = service.calculateScore(
      win: false,
      level: level,
      remainingSeconds: 10,
      movesUsed: 5,
    );

    expect(score, equals(0));
  });

  test('calculateScore uses base + time bonus + efficiency on win', () {
    const level = LevelConfig(
      id: 3,
      rows: 4,
      cols: 4,
      timeLimitSeconds: 50,
      maxMoves: 20,
    );

    // base = 1000 + (3 * 150) = 1450
    // time bonus = 15 * 10 = 150
    // efficiency = (20 - 10) * 6 = 60
    // total = 1660
    final score = service.calculateScore(
      win: true,
      level: level,
      remainingSeconds: 15,
      movesUsed: 10,
    );

    expect(score, equals(1660));
  });
}

class _FakeLevelRepository implements LevelRepository {
  @override
  Future<List<LevelConfig>> getLevels() async => [];

  @override
  Future<List<LevelConfig>> saveLevels(List<LevelConfig> levels) async => levels;
}
