import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_dependencies.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/entities/level_config.dart';
import '../../domain/entities/player.dart';
import '../../domain/services/game_service.dart';
import '../../domain/services/player_service.dart';
import '../widgets/app_background.dart';
import '../widgets/card_tile.dart';

class GameScreen extends StatefulWidget {
  final String playerName;
  final LevelConfig levelConfig;
  final List<LevelConfig> allLevels;

  const GameScreen({
    super.key,
    required this.playerName,
    required this.levelConfig,
    required this.allLevels,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<CardEntity> _cards;
  Timer? _timer;
  int _remainingSeconds = 0;
  int _moves = 0;
  bool _boardLocked = false;
  CardEntity? _firstFlipped;
  int _matchedPairs = 0;

  Player? _player;
  bool _initializing = true;

  late final GameService _gameService;
  late final PlayerService _playerService;

  @override
  void initState() {
    super.initState();
    _gameService = GameService(levelRepository);
    _playerService = PlayerService(playerRepository);
    _setup();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _setup() async {
    final player = await _playerService.upsert(widget.playerName);

    _cards = _gameService.generateCards(widget.levelConfig);
    _remainingSeconds = widget.levelConfig.timeLimitSeconds;
    _moves = 0;
    _matchedPairs = 0;
    _firstFlipped = null;
    _boardLocked = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _remainingSeconds = 0;
          timer.cancel();
          _handleGameEnd(win: false);
        }
      });
    });

    if (!mounted) return;
    setState(() {
      _player = player;
      _initializing = false;
    });
  }

  void _onCardTap(int index) {
    final card = _cards[index];
    if (_boardLocked || card.isPlaceholder || card.isMatched || card.isRevealed) {
      return;
    }

    setState(() {
      _cards[index] = card.copyWith(isRevealed: true);
    });

    if (_firstFlipped == null) {
      _firstFlipped = _cards[index];
      return;
    }

    _moves++;
    final first = _firstFlipped!;
    _firstFlipped = null;

    if (first.symbol == card.symbol && !first.isPlaceholder) {
      setState(() {
        _cards = _cards.map((c) {
          if (c.id == first.id || c.id == card.id) {
            return c.copyWith(isMatched: true, isRevealed: true);
          }
          return c;
        }).toList();
        _matchedPairs++;
      });

      if (_matchedPairs >= widget.levelConfig.pairCount) {
        _timer?.cancel();
        _handleGameEnd(win: true);
      }
    } else {
      _boardLocked = true;
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _cards = _cards.map((c) {
            if (c.id == first.id || c.id == card.id) {
              return c.copyWith(isRevealed: false);
            }
            return c;
          }).toList();
          _boardLocked = false;
        });
      });
    }

    if (_moves >= widget.levelConfig.maxMoves &&
        _matchedPairs < widget.levelConfig.pairCount) {
      _timer?.cancel();
      _handleGameEnd(win: false);
    }
  }

  Future<void> _handleGameEnd({required bool win}) async {
    if (_player == null) return;

    final nextLevel = _getNextLevel();
    final score = _gameService.calculateScore(
      win: win,
      level: widget.levelConfig,
      remainingSeconds: _remainingSeconds,
      movesUsed: _moves,
    );

    final previousHighest = _player!.highestLevel;
    Player updated = _player!;

    if (win) {
      final newTotal = _player!.totalScore + score;
      final newHighest = max(_player!.highestLevel, widget.levelConfig.id);
      updated = _player!.copyWith(
        totalScore: newTotal,
        highestLevel: newHighest,
      );

      await _playerService.update(updated);
    }

    _player = updated;

    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: cs.surface.withValues(alpha: 0.95),
          title: Row(
            children: [
              Icon(
                win
                    ? Icons.celebration_rounded
                    : Icons.sentiment_dissatisfied_rounded,
                color: win ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Text(win ? 'Habitat Secured!' : 'Habitat Lost'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (win) ...[
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Moves: $_moves / ${widget.levelConfig.maxMoves}'),
                Text('Time left: $_remainingSeconds s'),
              ] else ...[
                Text('Moves: $_moves / ${widget.levelConfig.maxMoves}'),
                Text(
                    'Pairs matched: $_matchedPairs / ${widget.levelConfig.pairCount}'),
              ],
              const SizedBox(height: 12),
              if (win && widget.levelConfig.id > previousHighest)
                const Text('New habitat unlocked for the animals! 🐾'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Exit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartLevel();
              },
              child: const Text('Retry'),
            ),
            if (win && nextLevel != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _goToNextLevel(nextLevel);
                },
                child: const Text('Next Level'),
              ),
          ],
        );
      },
    );
  }

  void _restartLevel() {
    setState(() {
      _initializing = true;
    });
    _setup();
  }

  LevelConfig? _getNextLevel() {
    final currentIndex =
        widget.allLevels.indexWhere((l) => l.id == widget.levelConfig.id);
    if (currentIndex == -1 || currentIndex + 1 >= widget.allLevels.length) {
      return null;
    }
    return widget.allLevels[currentIndex + 1];
  }

  void _goToNextLevel(LevelConfig nextLevel) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          playerName: widget.playerName,
          levelConfig: nextLevel,
          allLevels: widget.allLevels,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habitat ${widget.levelConfig.id}'),
        backgroundColor: Colors.transparent,
      ),
      body: AppBackground(
        useSafeArea: false,
        padding: const EdgeInsets.all(12),
        child: _initializing
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHud(context),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final rows = widget.levelConfig.rows;
                        final cols = widget.levelConfig.cols;
                        const spacing = 8.0;
                        final cardWidth =
                            (constraints.maxWidth - (cols - 1) * spacing) /
                                cols;
                        final cardHeight =
                            (constraints.maxHeight - (rows - 1) * spacing) /
                                rows;
                        final size = min(cardWidth, cardHeight);

                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                          ),
                          itemCount: _cards.length,
                          itemBuilder: (context, index) {
                            final card = _cards[index];
                            return CardTile(
                              card: card,
                              size: size,
                              onTap: () => _onCardTap(index),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _restartLevel,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Restart'),
                      ),
                      Text(
                        _player == null ? '' : 'Playing as ${_player!.name}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHud(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timeColor =
        _remainingSeconds < widget.levelConfig.timeLimitSeconds * 0.25
            ? Colors.redAccent
            : Colors.greenAccent;

    final totalSeconds = widget.levelConfig.timeLimitSeconds.toDouble();
    final timeProgress = totalSeconds == 0
        ? 0.0
        : (_remainingSeconds / totalSeconds).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _HudStat(
                  icon: Icons.timer_rounded,
                  label: 'Time',
                  value: '${_remainingSeconds}s',
                  color: timeColor,
                ),
                const SizedBox(width: 12),
                _HudStat(
                  icon: Icons.touch_app_rounded,
                  label: 'Moves',
                  value: '$_moves / ${widget.levelConfig.maxMoves}',
                  color: cs.primary,
                ),
                const SizedBox(width: 12),
                _HudStat(
                  icon: Icons.favorite_rounded,
                  label: 'Critters',
                  value: '$_matchedPairs / ${widget.levelConfig.pairCount}',
                  color: Colors.pinkAccent,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: timeProgress,
                backgroundColor: cs.surfaceContainerHighest,
                color: timeColor,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _HudStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withValues(alpha: 0.12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color.withValues(alpha: 0.9)),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
