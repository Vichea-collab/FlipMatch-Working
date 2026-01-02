import '../../domain/entities/player.dart';
import '../../domain/repositories/player_repository.dart';
import '../datasources/player_local_data_source.dart';
import '../models/player_model.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final PlayerLocalDataSource _localDataSource = PlayerLocalDataSourceImpl();

  @override
  Future<List<Player>> getAllPlayers() async {
    final players = await _localDataSource.getAllPlayers();
    return players
        .map(
          (p) => Player(
            name: p.name,
            totalScore: p.totalScore,
            highestLevel: p.highestLevel,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<Player> upsertPlayer(String name) async {
    final players = await _localDataSource.getAllPlayers();
    final index =
        players.indexWhere((p) => p.name.toLowerCase() == name.toLowerCase());

    if (index != -1) {
      return players[index];
    }

    final newPlayer = PlayerModel(
      name: name,
      totalScore: 0,
      highestLevel: 0,
    );
    players.add(newPlayer);
    await _localDataSource.saveAllPlayers(players);
    return newPlayer;
  }

  @override
  Future<void> updatePlayer(Player player) async {
    final players = await _localDataSource.getAllPlayers();
    final index =
        players.indexWhere((p) => p.name.toLowerCase() == player.name.toLowerCase());

    final updated = PlayerModel(
      name: player.name,
      totalScore: player.totalScore,
      highestLevel: player.highestLevel,
    );

    if (index != -1) {
      players[index] = updated;
    } else {
      players.add(updated);
    }

    await _localDataSource.saveAllPlayers(players);
  }

  @override
  Future<void> deletePlayer(String name) {
    return _localDataSource.deletePlayer(name);
  }
}
