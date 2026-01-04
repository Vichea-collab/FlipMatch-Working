import 'package:flutter_test/flutter_test.dart';
import 'package:memory_pair_game/domain/entities/player.dart';
import 'package:memory_pair_game/domain/repositories/player_repository.dart';
import 'package:memory_pair_game/domain/services/player_service.dart';

void main() {
  group('PlayerService', () {
    late _FakePlayerRepository repository;
    late PlayerService service;

    setUp(() {
      repository = _FakePlayerRepository();
      service = PlayerService(repository);
    });

    test('upsert delegates to repository and returns stored player', () async {
      final player = await service.upsert('Sam');

      expect(repository.upsertCalls, 1);
      expect(player.name, 'Sam');
      expect(player.totalScore, 0);
      expect(player.highestLevel, 0);
    });

    test('update writes new values when player exists', () async {
      repository = _FakePlayerRepository([
        const Player(name: 'Casey', totalScore: 50, highestLevel: 1),
      ]);
      service = PlayerService(repository);

      const updated = Player(name: 'Casey', totalScore: 300, highestLevel: 4);
      await service.update(updated);

      expect(repository.updateCalls, 1);
      final players = await repository.getAllPlayers();
      expect(players.single.totalScore, 300);
      expect(players.single.highestLevel, 4);
    });

    test('delete forwards to repository', () async {
      repository = _FakePlayerRepository([
        const Player(name: 'Rex', totalScore: 10, highestLevel: 1),
      ]);
      service = PlayerService(repository);

      await service.delete('Rex');

      expect(repository.deleteCalls, 1);
      final players = await repository.getAllPlayers();
      expect(players, isEmpty);
    });

    test('getAll returns repository data', () async {
      repository = _FakePlayerRepository([
        const Player(name: 'A', totalScore: 5, highestLevel: 1),
        const Player(name: 'B', totalScore: 10, highestLevel: 2),
      ]);
      service = PlayerService(repository);

      final players = await service.getAll();

      expect(repository.getAllCalls, 1);
      expect(players.map((p) => p.name), containsAll(['A', 'B']));
    });
  });
}

class _FakePlayerRepository implements PlayerRepository {
  final List<Player> _store;
  int upsertCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  int getAllCalls = 0;

  _FakePlayerRepository([List<Player>? initial])
      : _store = List<Player>.from(initial ?? const []);

  @override
  Future<Player> upsertPlayer(String name) async {
    upsertCalls++;
    for (final player in _store) {
      if (player.name.toLowerCase() == name.toLowerCase()) {
        return player;
      }
    }
    final created = Player(name: name, totalScore: 0, highestLevel: 0);
    _store.add(created);
    return created;
  }

  @override
  Future<void> updatePlayer(Player player) async {
    updateCalls++;
    final index = _store.indexWhere(
      (p) => p.name.toLowerCase() == player.name.toLowerCase(),
    );
    if (index == -1) {
      _store.add(player);
    } else {
      _store[index] = player;
    }
  }

  @override
  Future<void> deletePlayer(String name) async {
    deleteCalls++;
    _store.removeWhere(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
    );
  }

  @override
  Future<List<Player>> getAllPlayers() async {
    getAllCalls++;
    return List<Player>.from(_store);
  }
}
