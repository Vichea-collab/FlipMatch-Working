import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/level_config.dart';

abstract class LevelLocalDataSource {
  Future<List<LevelConfig>> fetchLevels();
  Future<void> saveLevels(List<LevelConfig> levels);
}

class LevelLocalDataSourceImpl implements LevelLocalDataSource {
  static const String _fileName = 'level.json';
  static const String _assetPath = 'assets/data/level.json';
  static const String _prefsKey = 'levels_data';
  static const String _versionKey = 'levels_version';
  // Bump to force-refresh seeded level data when assets change.
  static const int _dataVersion = 2;
  List<LevelConfig>? _cache;

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

      final raw = await rootBundle.loadString(_assetPath);
      await prefs.setString(_prefsKey, raw);
      await prefs.setInt(_versionKey, _dataVersion);
      return;
    }

    final file = await _getFile();
    if (!forceRefresh && await file.exists()) return;

    final raw = await rootBundle.loadString(_assetPath);
    await file.create(recursive: true);
    await file.writeAsString(raw);
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

  List<LevelConfig> _decodeLevels(String raw) {
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => LevelConfig.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  @override
  Future<List<LevelConfig>> fetchLevels() async {
    final prefs = await _prefs();
    final storedVersion = prefs.getInt(_versionKey) ?? 0;
    final needsRefresh = storedVersion < _dataVersion;

    if (needsRefresh) {
      _cache = null;
    } else if (_cache != null) {
      return _cache!;
    }

    String raw = (await _readRaw(prefs, forceRefresh: needsRefresh)).trim();
    if (raw.isEmpty) {
      _cache = [];
      return _cache!;
    }

    try {
      _cache = _decodeLevels(raw);
    } catch (_) {
      // If stored data is corrupted, fallback to bundled asset.
      raw = (await _readRaw(prefs, forceRefresh: true)).trim();
      try {
        _cache = raw.isEmpty ? [] : _decodeLevels(raw);
      } catch (_) {
        _cache = [];
      }
    }

    return _cache!;
  }

  @override
  Future<void> saveLevels(List<LevelConfig> levels) async {
    final prefs = await _prefs();
    _cache = List<LevelConfig>.from(levels)
      ..sort((a, b) => a.id.compareTo(b.id));
    final encoded =
        jsonEncode(_cache!.map((e) => e.toJson()).toList(growable: false));
    await _writeRaw(encoded, prefs);
  }
}
