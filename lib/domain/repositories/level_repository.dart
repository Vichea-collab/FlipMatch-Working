import '../entities/level_config.dart';

abstract class LevelRepository {
  Future<List<LevelConfig>> getLevels();
  Future<List<LevelConfig>> saveLevels(List<LevelConfig> levels);
}
