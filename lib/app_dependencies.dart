import 'data/repositories/level_repository_impl.dart';
import 'data/repositories/player_repository_impl.dart';
import 'domain/repositories/level_repository.dart';
import 'domain/repositories/player_repository.dart';

final PlayerRepository playerRepository = PlayerRepositoryImpl();
final LevelRepository levelRepository = LevelRepositoryImpl();
