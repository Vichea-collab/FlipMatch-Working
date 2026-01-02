import 'dart:math';

import '../entities/card_entity.dart';
import '../entities/level_config.dart';

class GenerateCards {
  const GenerateCards();

  List<CardEntity> call(LevelConfig level) {
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
}
