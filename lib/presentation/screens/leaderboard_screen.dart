import 'package:flutter/material.dart';

import '../../app_dependencies.dart';
import '../../domain/entities/player.dart';
import '../../domain/usecases/delete_player.dart';
import '../../domain/usecases/get_all_players.dart';
import '../widgets/app_background.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Player> _players = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final usecase = GetAllPlayers(playerRepository);
    final players = await usecase();
    players.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    if (!mounted) return;
    setState(() {
      _players = players;
      _loading = false;
    });
  }

  Future<void> _removePlayer(Player player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove player'),
        content: Text('Remove ${player.name} from the leaderboard?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).maybePop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final deleteUsecase = DeletePlayer(playerRepository);
    await deleteUsecase(player.name);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caretaker Board'),
        backgroundColor: Colors.transparent,
      ),
      body: AppBackground(
        useSafeArea: false,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _players.isEmpty
                ? const Center(
                    child: Text(
                      'No rangers have rescued animals yet!',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.separated(
                    itemCount: _players.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = _players[index];
                      final rank = index + 1;
                      IconData icon;
                      Color color;
                      if (rank == 1) {
                        icon = Icons.emoji_events_rounded;
                        color = Colors.amber;
                      } else if (rank == 2) {
                        icon = Icons.emoji_events_rounded;
                        color = Colors.blueGrey;
                      } else if (rank == 3) {
                        icon = Icons.emoji_events_rounded;
                        color = Colors.deepOrangeAccent;
                      } else {
                        icon = Icons.pets_rounded;
                        color = cs.onSurface;
                      }

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.2),
                            child: Icon(icon, color: color),
                          ),
                          title: Text(
                            p.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Rescue score ${p.totalScore} · Highest habitat ${p.highestLevel}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                backgroundColor:
                                    cs.primaryContainer.withValues(alpha: 0.2),
                                label: Text('#$rank'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                tooltip: 'Remove player',
                                onPressed: () => _removePlayer(p),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
