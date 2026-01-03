import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../models/player_model.dart';

abstract class PlayerLocalDataSource {
  Future<List<PlayerModel>> getAllPlayers();
  Future<void> saveAllPlayers(List<PlayerModel> players);
  Future<void> deletePlayer(String name);
}

class PlayerLocalDataSourceImpl implements PlayerLocalDataSource {
  static const String _fileName = 'leaderboard.json';
  static const String _assetPath = 'assets/data/leaderboard.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> _seedFileIfMissing() async {
    final file = await _getFile();
    if (await file.exists()) return;

    final defaultData = await rootBundle.loadString(_assetPath);
    await file.create(recursive: true);
    await file.writeAsString(defaultData);
  }

  Future<String> _readRaw() async {
    await _seedFileIfMissing();
    final file = await _getFile();
    return file.readAsString();
  }

  Future<void> _writeRaw(String data) async {
    final file = await _getFile();
    await file.create(recursive: true);
    await file.writeAsString(data);
  }

  Future<List<PlayerModel>> _readPlayers() async {
    final raw = (await _readRaw()).trim();
    if (raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      final players = list
          .map((e) => PlayerModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      players.sort(
        (a, b) => b.totalScore.compareTo(a.totalScore),
      );
      return players;
    } catch (_) {
      return [];
    }
  }

  Future<void> _writePlayers(List<PlayerModel> players) async {
    final sorted = List<PlayerModel>.from(players)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    final encoded =
        jsonEncode(sorted.map((p) => p.toJson()).toList(growable: false));
    await _writeRaw(encoded);
  }

  @override
  Future<List<PlayerModel>> getAllPlayers() {
    return _readPlayers();
  }

  @override
  Future<void> saveAllPlayers(List<PlayerModel> players) {
    return _writePlayers(players);
  }

  @override
  Future<void> deletePlayer(String name) async {
    final players = await _readPlayers();
    players.removeWhere(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
    );
    await _writePlayers(players);
  }
}
