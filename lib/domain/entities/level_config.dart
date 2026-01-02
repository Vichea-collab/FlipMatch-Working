class LevelConfig {
  final int id;
  final int rows;
  final int cols;
  final int timeLimitSeconds;
  final int maxMoves;

  const LevelConfig({
    required this.id,
    required this.rows,
    required this.cols,
    required this.timeLimitSeconds,
    required this.maxMoves,
  });

  int get totalCells => rows * cols;

  int get pairCount => totalCells ~/ 2;

  factory LevelConfig.fromJson(Map<String, dynamic> json) {
    return LevelConfig(
      id: json['id'] as int,
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      timeLimitSeconds: json['timeLimitSeconds'] as int,
      maxMoves: json['maxMoves'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rows': rows,
      'cols': cols,
      'timeLimitSeconds': timeLimitSeconds,
      'maxMoves': maxMoves,
    };
  }
}
