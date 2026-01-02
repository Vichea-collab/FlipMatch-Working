import '../entities/level_config.dart';
import '../repositories/level_repository.dart';

class SaveLevels {
  final LevelRepository repository;

  SaveLevels(this.repository);

  Future<List<LevelConfig>> call(List<LevelConfig> levels) {
    return repository.saveLevels(levels);
  }
}
