import '../entities/player.dart';
import '../repositories/player_repository.dart';

class GetAllPlayers {
  final PlayerRepository repository;

  GetAllPlayers(this.repository);

  Future<List<Player>> call() => repository.getAllPlayers();
}
