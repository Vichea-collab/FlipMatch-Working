import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_dependencies.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/level_config.dart';
import '../../domain/usecases/get_levels.dart';
import '../../domain/usecases/save_levels.dart';
import '../../domain/usecases/upsert_player.dart';
import '../widgets/app_background.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  final String playerName;

  const LevelSelectScreen({super.key, required this.playerName});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  Player? _player;
  List<LevelConfig> _levels = const [];
  bool _loading = true;
  bool _saving = false;
  LevelConfig? _lastRemovedLevel;
  int? _lastRemovedIndex;

  @override
  void initState() {
    super.initState();
    _loadPlayer(showSpinner: true);
  }

  Future<void> _loadPlayer({bool showSpinner = false}) async {
    if (showSpinner && mounted) {
      setState(() {
        _loading = true;
      });
    }

    final playerUsecase = UpsertPlayer(playerRepository);
    final levelUsecase = GetLevels(levelRepository);

    final results = await Future.wait([
      playerUsecase(widget.playerName),
      levelUsecase(),
    ]);

    if (!mounted) return;
    setState(() {
      _player = results[0] as Player;
      _levels = List<LevelConfig>.from(results[1] as List<LevelConfig>);
      _loading = false;
    });
  }

  Future<void> _persistLevels(List<LevelConfig> updated) async {
    final saveUsecase = SaveLevels(levelRepository);
    setState(() {
      _saving = true;
      _levels = List<LevelConfig>.from(updated)
        ..sort((a, b) => a.id.compareTo(b.id));
    });
    final saved = await saveUsecase(_levels);
    if (!mounted) return;
    setState(() {
      _levels = List<LevelConfig>.from(saved)
        ..sort((a, b) => a.id.compareTo(b.id));
      _saving = false;
    });
  }

  Future<void> _removeLevel(LevelConfig level, int index) async {
    final updated = List<LevelConfig>.from(_levels)..removeAt(index);
    _lastRemovedLevel = level;
    _lastRemovedIndex = index;
    await _persistLevels(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Habitat ${level.id} removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _undoRemoval(),
        ),
      ),
    );
  }

  Future<void> _undoRemoval() async {
    final level = _lastRemovedLevel;
    final index = _lastRemovedIndex;
    if (level == null || index == null) return;

    final updated = List<LevelConfig>.from(_levels);
    final insertIndex = index.clamp(0, updated.length);
    updated.insert(insertIndex, level);
    _lastRemovedLevel = null;
    _lastRemovedIndex = null;
    await _persistLevels(updated);
  }

  Future<void> _showAddLevelDialog() async {
    final formKey = GlobalKey<FormState>();
    final rowsController = TextEditingController();
    final colsController = TextEditingController();
    final timeController = TextEditingController();
    final movesController = TextEditingController();
    String? gridError;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Habitat'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: rowsController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.black87),
                            decoration: const InputDecoration(labelText: 'Rows'),
                            validator: (value) {
                              final rows = int.tryParse(value ?? '');
                              if (rows == null || rows <= 0) {
                                return 'Enter rows';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: colsController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.black87),
                            decoration: const InputDecoration(labelText: 'Cols'),
                            validator: (value) {
                              final cols = int.tryParse(value ?? '');
                              if (cols == null || cols <= 0) {
                                return 'Enter cols';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: timeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black87),
                      decoration:
                          const InputDecoration(labelText: 'Time limit (seconds)'),
                      validator: (value) {
                        final seconds = int.tryParse(value ?? '');
                        if (seconds == null || seconds <= 10) {
                          return 'Min 10 seconds';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: movesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(labelText: 'Max moves'),
                      validator: (value) {
                        final moves = int.tryParse(value ?? '');
                        if (moves == null || moves <= 0) {
                          return 'Enter moves';
                        }
                        return null;
                      },
                    ),
                    if (gridError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        gridError!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).maybePop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final rows = int.parse(rowsController.text);
                    final cols = int.parse(colsController.text);
                    if ((rows * cols) % 2 != 0) {
                      setStateDialog(() {
                        gridError = 'Rows × columns must produce pairs.';
                      });
                      return;
                    }
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      final rows = int.parse(rowsController.text);
      final cols = int.parse(colsController.text);
      final time = int.parse(timeController.text);
      final moves = int.parse(movesController.text);
      final currentMaxId =
          _levels.isEmpty ? 0 : _levels.map((l) => l.id).reduce(max);
      final newLevel = LevelConfig(
        id: currentMaxId + 1,
        rows: rows,
        cols: cols,
        timeLimitSeconds: time,
        maxMoves: moves,
      );
      await _persistLevels([..._levels, newLevel]);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Habitat ${newLevel.id} added')),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      rowsController.dispose();
      colsController.dispose();
      timeController.dispose();
      movesController.dispose();
    });
  }

  Future<void> _showEditLevelDialog(LevelConfig level, int index) async {
    final formKey = GlobalKey<FormState>();
    final rowsController = TextEditingController(text: level.rows.toString());
    final colsController = TextEditingController(text: level.cols.toString());
    final timeController =
        TextEditingController(text: level.timeLimitSeconds.toString());
    final movesController = TextEditingController(text: level.maxMoves.toString());
    String? gridError;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Edit Habitat ${level.id}'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: rowsController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.black87),
                            decoration: const InputDecoration(labelText: 'Rows'),
                            validator: (value) {
                              final rows = int.tryParse(value ?? '');
                              if (rows == null || rows <= 0) {
                                return 'Enter rows';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: colsController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.black87),
                            decoration: const InputDecoration(labelText: 'Cols'),
                            validator: (value) {
                              final cols = int.tryParse(value ?? '');
                              if (cols == null || cols <= 0) {
                                return 'Enter cols';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: timeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black87),
                      decoration:
                          const InputDecoration(labelText: 'Time limit (seconds)'),
                      validator: (value) {
                        final seconds = int.tryParse(value ?? '');
                        if (seconds == null || seconds <= 10) {
                          return 'Min 10 seconds';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: movesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(labelText: 'Max moves'),
                      validator: (value) {
                        final moves = int.tryParse(value ?? '');
                        if (moves == null || moves <= 0) {
                          return 'Enter moves';
                        }
                        return null;
                      },
                    ),
                    if (gridError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        gridError!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).maybePop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final rows = int.parse(rowsController.text);
                    final cols = int.parse(colsController.text);
                    if ((rows * cols) % 2 != 0) {
                      setStateDialog(() {
                        gridError = 'Rows × columns must produce pairs.';
                      });
                      return;
                    }
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Save changes'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      final rows = int.parse(rowsController.text);
      final cols = int.parse(colsController.text);
      final time = int.parse(timeController.text);
      final moves = int.parse(movesController.text);
      final updatedLevel = LevelConfig(
        id: level.id,
        rows: rows,
        cols: cols,
        timeLimitSeconds: time,
        maxMoves: moves,
      );
      final updatedList = List<LevelConfig>.from(_levels);
      updatedList[index] = updatedLevel;
      await _persistLevels(updatedList);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Habitat ${level.id} updated')),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      rowsController.dispose();
      colsController.dispose();
      timeController.dispose();
      movesController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Habitat'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add habitat',
            onPressed: (_loading || _saving) ? null : _showAddLevelDialog,
          ),
        ],
      ),
      body: AppBackground(
        useSafeArea: false,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _levels.isEmpty
                ? const Center(
                    child: Text(
                      'No habitats found in the animal registry.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : Column(
                    children: [
                      if (_saving)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(),
                        ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _levels.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final level = _levels[index];
                            final highestLevel = _player?.highestLevel ?? 0;
                            final isUnlocked = level.id <= highestLevel + 1;
                            final isCompleted = level.id <= highestLevel;

                            final badgeColor = isCompleted
                                ? Colors.greenAccent
                                : isUnlocked
                                    ? cs.primary
                                    : cs.onSurfaceVariant;

                            return Opacity(
                              opacity: isUnlocked ? 1 : 0.5,
                              child: Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: badgeColor.withValues(alpha: 0.25),
                                    child: Text(
                                      level.id.toString().padLeft(2, '0'),
                                      style:
                                          const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(
                                    'Habitat ${level.id}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    '${level.rows} × ${level.cols} zone  ·  ${level.timeLimitSeconds}s rescue  ·  ${level.maxMoves} moves',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isCompleted
                                            ? Icons.pets_rounded
                                            : isUnlocked
                                                ? Icons.lock_open_rounded
                                                : Icons.lock_outline_rounded,
                                        color: badgeColor,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_note_rounded),
                                        tooltip: 'Edit habitat',
                                        onPressed: (_loading || _saving)
                                            ? null
                                            : () => _showEditLevelDialog(
                                                  level,
                                                  index,
                                                ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded),
                                        tooltip: 'Remove habitat',
                                        onPressed: (_loading || _saving)
                                            ? null
                                            : () => _removeLevel(level, index),
                                      ),
                                    ],
                                  ),
                                  onTap: isUnlocked
                                      ? () async {
                                          await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => GameScreen(
                                                playerName: widget.playerName,
                                                levelConfig: level,
                                                allLevels: _levels,
                                              ),
                                            ),
                                          );
                                          if (!mounted) return;
                                          await _loadPlayer(showSpinner: true);
                                        }
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
