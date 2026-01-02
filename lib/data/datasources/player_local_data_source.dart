import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_model.dart';

abstract class PlayerLocalDataSource {
  Future<List<PlayerModel>> getAllPlayers();
  Future<void> saveAllPlayers(List<PlayerModel> players);
  Future<void> deletePlayer(String name);
}

class PlayerLocalDataSourceImpl implements PlayerLocalDataSource {
  static const String _fileName = 'leaderboard.json';
  static const String _assetPath = 'assets/data/leaderboard.json';
  static const String _prefsKey = 'players_data';
  static const String _versionKey = 'players_version';
  // Bump to force-refresh the seeded leaderboard when assets change.
  static const int _dataVersion = 1;

  Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> _ensureStorageExists(
    SharedPreferences prefs, {
    required bool forceRefresh,
  }) async {
    if (kIsWeb) {
      final hasData = prefs.containsKey(_prefsKey);
      if (!forceRefresh && hasData) return;
      final defaultData = await rootBundle.loadString(_assetPath);
      await prefs.setString(_prefsKey, defaultData);
      await prefs.setInt(_versionKey, _dataVersion);
      return;
    }

    final file = await _getFile();
    if (!forceRefresh && await file.exists()) return;

    final defaultData = await rootBundle.loadString(_assetPath);
    await file.create(recursive: true);
    await file.writeAsString(defaultData);
    await prefs.setInt(_versionKey, _dataVersion);
  }

  Future<String> _readRaw(
    SharedPreferences prefs, {
    required bool forceRefresh,
  }) async {
    await _ensureStorageExists(prefs, forceRefresh: forceRefresh);
    if (kIsWeb) {
      return prefs.getString(_prefsKey) ?? '[]';
    }
    final file = await _getFile();
    if (!await file.exists()) return '[]';
    return file.readAsString();
  }

  Future<void> _writeRaw(String data, SharedPreferences prefs) async {
    if (kIsWeb) {
      await prefs.setString(_prefsKey, data);
    } else {
      final file = await _getFile();
      await file.writeAsString(data);
    }
    await prefs.setInt(_versionKey, _dataVersion);
  }

  Future<List<PlayerModel>> _readPlayers() async {
    final prefs = await _prefs();
    final storedVersion = prefs.getInt(_versionKey) ?? 0;
    final needsRefresh = storedVersion < _dataVersion;

    final raw = (await _readRaw(prefs, forceRefresh: needsRefresh)).trim();
    if (raw.isEmpty) return [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => PlayerModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _writePlayers(List<PlayerModel> players) async {
    final prefs = await _prefs();
    final encoded =
        jsonEncode(players.map((p) => p.toJson()).toList(growable: false));
    await _writeRaw(encoded, prefs);
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
