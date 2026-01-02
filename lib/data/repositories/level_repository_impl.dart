import '../../domain/entities/level_config.dart';
import '../../domain/repositories/level_repository.dart';
import '../datasources/level_local_data_source.dart';

class LevelRepositoryImpl implements LevelRepository {
  final LevelLocalDataSource _localDataSource = LevelLocalDataSourceImpl();

  @override
  Future<List<LevelConfig>> getLevels() {
    return _localDataSource.fetchLevels();
  }

  @override
  Future<List<LevelConfig>> saveLevels(List<LevelConfig> levels) async {
    await _localDataSource.saveLevels(levels);
    return _localDataSource.fetchLevels();
  }
}
