import 'package:flutter/material.dart';

import '../../app_dependencies.dart';
import '../../domain/entities/player.dart';
import '../../domain/services/player_service.dart';
import '../widgets/app_background.dart';
import '../widgets/menu_button.dart';
import 'leaderboard_screen.dart';
import 'level_select_screen.dart';
import 'name_entry_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final Player player;

  const MainMenuScreen({super.key, required this.player});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  late Player _player;
  bool _refreshing = false;
  late final PlayerService _playerService;

  @override
  void initState() {
    super.initState();
    _player = widget.player;
    _playerService = PlayerService(playerRepository);
  }

  Future<void> _refreshPlayer() async {
    setState(() => _refreshing = true);
    final refreshed = await _playerService.upsert(_player.name);
    if (!mounted) return;
    setState(() {
      _player = refreshed;
      _refreshing = false;
    });
  }

  Future<void> _openLevels(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LevelSelectScreen(
          playerName: _player.name,
        ),
      ),
    );
    if (!mounted) return;
    await _refreshPlayer();
  }

  Future<void> _openLeaderboard(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LeaderboardScreen(),
      ),
    );
    if (!mounted) return;
    await _refreshPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back, Ranger',
              style: TextStyle(color: Colors.white70),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _player.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ),
                if (_refreshing)
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.white.withValues(alpha: 0.15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  children: [
                    _StatChip(
                      icon: Icons.scoreboard_rounded,
                      label: 'Total score',
                      value: _player.totalScore.toString(),
                    ),
                    const SizedBox(width: 16),
                    _StatChip(
                      icon: Icons.flag_rounded,
                      label: 'Highest level',
                      value: _player.highestLevel.toString(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MenuButton(
                      icon: Icons.play_arrow_rounded,
                      label: 'Explore habitats',
                      subtitle: 'Rescue pairs of critters level by level',
                      onTap: () {
                        if (_refreshing) return;
                        _openLevels(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    MenuButton(
                      icon: Icons.leaderboard_rounded,
                      label: 'Caretaker board',
                      subtitle: 'See who saved the most animals',
                      onTap: () {
                        if (_refreshing) return;
                        _openLeaderboard(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    MenuButton(
                      icon: Icons.person_2_rounded,
                      label: 'Switch ranger',
                      subtitle: 'Play with another caretaker profile',
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const NameEntryScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              'Tip: Chain perfect matches to become top caretaker!',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withValues(alpha: 0.08),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon == Icons.scoreboard_rounded ? Icons.pets_rounded : icon,
                color: Colors.white),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
