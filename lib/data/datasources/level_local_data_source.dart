import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/level_config.dart';

abstract class LevelLocalDataSource {
  Future<List<LevelConfig>> fetchLevels();
  Future<void> saveLevels(List<LevelConfig> levels);
}

class LevelLocalDataSourceImpl implements LevelLocalDataSource {
  static const String _fileName = 'level.json';
  static const String _assetPath = 'assets/data/level.json';
  List<LevelConfig>? _cache;

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> _seedFileIfMissing() async {
    final file = await _getFile();
    if (await file.exists()) return;

    final raw = await rootBundle.loadString(_assetPath);
    await file.create(recursive: true);
    await file.writeAsString(raw);
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

  List<LevelConfig> _decodeLevels(String raw) {
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => LevelConfig.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  @override
  Future<List<LevelConfig>> fetchLevels() async {
    if (_cache != null) {
      return _cache!;
    }

    String raw = (await _readRaw()).trim();
    if (raw.isEmpty) {
      _cache = [];
      return _cache!;
    }

    try {
      _cache = _decodeLevels(raw);
    } catch (_) {
      // If stored data is corrupted, fallback to bundled asset.
      raw = (await rootBundle.loadString(_assetPath)).trim();
      try {
        _cache = raw.isEmpty ? [] : _decodeLevels(raw);
        await _writeRaw(raw);
      } catch (_) {
        _cache = [];
      }
    }

    return _cache!;
  }

  @override
  Future<void> saveLevels(List<LevelConfig> levels) async {
    _cache = List<LevelConfig>.from(levels)
      ..sort((a, b) => a.id.compareTo(b.id));
    final encoded =
        jsonEncode(_cache!.map((e) => e.toJson()).toList(growable: false));
    await _writeRaw(encoded);
  }
}
