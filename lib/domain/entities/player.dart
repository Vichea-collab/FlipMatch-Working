class Player {
  final String name;
  final int totalScore;
  final int highestLevel;

  const Player({
    required this.name,
    required this.totalScore,
    required this.highestLevel,
  });

  Player copyWith({
    int? totalScore,
    int? highestLevel,
  }) {
    return Player(
      name: name,
      totalScore: totalScore ?? this.totalScore,
      highestLevel: highestLevel ?? this.highestLevel,
    );
  }
}
