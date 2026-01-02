import '../entities/player.dart';

abstract class PlayerRepository {
  Future<List<Player>> getAllPlayers();
  Future<Player> upsertPlayer(String name);
  Future<void> updatePlayer(Player player);
  Future<void> deletePlayer(String name);
}
