import 'dart:math';

import '../entities/card_entity.dart';
import '../entities/level_config.dart';
import '../repositories/level_repository.dart';

class GameService {
  final LevelRepository repository;

  const GameService(this.repository);

  List<CardEntity> generateCards(LevelConfig level) {
    final pairCount = level.pairCount;
    final totalCells = level.totalCells;
    final placeholdersCount = totalCells - pairCount * 2;

    const possibleSymbols = [
      '🐶', '🐱', '🐻', '🐼', '🐨', '🐯', '🦊', '🦁', '🐮', '🐷',
      '🐸', '🐵', '🐔', '🐧', '🦉', '🦄', '🦋', '🐴', '🐢', '🐍',
      '🐙', '🐬', '🦓', '🦒', '🦝', '🦨', '🦥', '🦘', '🦔', '🐞',
      '🐝', '🦩', '🐊', '🦅', '🐠', '🐺', '🦚', '🦦', '🦜', '🦭',
    ];

    final symbols = <String>[];
    for (var i = 0; i < pairCount; i++) {
      symbols.add(possibleSymbols[i % possibleSymbols.length]);
    }

    final cards = <CardEntity>[];
    var idCounter = 0;

    for (final symbol in symbols) {
      cards.add(CardEntity(id: idCounter++, symbol: symbol));
      cards.add(CardEntity(id: idCounter++, symbol: symbol));
    }

    for (var i = 0; i < placeholdersCount; i++) {
      cards.add(CardEntity(
        id: idCounter++,
        symbol: '',
        isPlaceholder: true,
        isMatched: true,
      ));
    }

    cards.shuffle(Random());
    return cards;
  }

  int calculateScore({
    required bool win,
    required LevelConfig level,
    required int remainingSeconds,
    required int movesUsed,
  }) {
    if (!win) return 0;

    final base = 1000 + level.id * 150;
    final timeBonus = remainingSeconds * 10;
    final efficiency = (level.maxMoves - movesUsed).clamp(0, 999) * 6;

    return (base + timeBonus + efficiency).clamp(0, 999999);
  }

  Future<List<LevelConfig>> getLevels() => repository.getLevels();

  Future<List<LevelConfig>> saveLevels(List<LevelConfig> levels) {
    return repository.saveLevels(levels);
  }
}
