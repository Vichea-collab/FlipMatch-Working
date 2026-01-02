import '../../domain/entities/player.dart';

class PlayerModel extends Player {
  const PlayerModel({
    required super.name,
    required super.totalScore,
    required super.highestLevel,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      name: json['name'] as String,
      totalScore: json['totalScore'] as int,
      highestLevel: json['highestLevel'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalScore': totalScore,
      'highestLevel': highestLevel,
    };
  }

  PlayerModel copyWithModel({
    int? totalScore,
    int? highestLevel,
  }) {
    return PlayerModel(
      name: name,
      totalScore: totalScore ?? this.totalScore,
      highestLevel: highestLevel ?? this.highestLevel,
    );
  }
}
