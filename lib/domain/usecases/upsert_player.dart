import '../entities/player.dart';
import '../repositories/player_repository.dart';

class UpsertPlayer {
  final PlayerRepository repository;

  UpsertPlayer(this.repository);

  Future<Player> call(String name) => repository.upsertPlayer(name);
}
