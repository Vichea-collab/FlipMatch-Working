import '../entities/level_config.dart';

class CalculateScore {
  const CalculateScore();

  int call({
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
}
