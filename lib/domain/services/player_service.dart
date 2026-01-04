import '../entities/player.dart';
import '../repositories/player_repository.dart';

class PlayerService {
  final PlayerRepository repository;

  PlayerService(this.repository);

  Future<Player> upsert(String name) => repository.upsertPlayer(name);

  Future<void> update(Player player) => repository.updatePlayer(player);

  Future<void> delete(String name) => repository.deletePlayer(name);

  Future<List<Player>> getAll() => repository.getAllPlayers();
}
