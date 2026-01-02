import '../entities/level_config.dart';
import '../repositories/level_repository.dart';

class GetLevels {
  final LevelRepository repository;

  GetLevels(this.repository);

  Future<List<LevelConfig>> call() => repository.getLevels();
}
