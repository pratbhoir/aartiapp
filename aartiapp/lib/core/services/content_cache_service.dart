import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Local file-backed cache for festival and aarti JSON payloads.
class ContentCacheService {
  ContentCacheService({Future<Directory> Function()? documentsDirectoryLoader})
    : _documentsDirectoryLoader =
          documentsDirectoryLoader ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _documentsDirectoryLoader;

  static const String _festivalCacheFileName = 'festival_content_cache.json';
  static const String _aartiCacheFileName = 'aarti_content_cache.json';

  /// Returns cached festival JSON if present.
  Future<String?> readFestivalContent() => _read(_festivalCacheFileName);

  /// Returns cached aarti JSON if present.
  Future<String?> readAartiContent() => _read(_aartiCacheFileName);

  /// Persists the latest festival JSON payload.
  Future<void> writeFestivalContent(String json) =>
      _write(_festivalCacheFileName, json);

  /// Persists the latest aarti JSON payload.
  Future<void> writeAartiContent(String json) =>
      _write(_aartiCacheFileName, json);

  Future<String?> _read(String fileName) async {
    final file = await _fileFor(fileName);
    if (!await file.exists()) {
      return null;
    }

    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      return null;
    }

    return contents;
  }

  Future<void> _write(String fileName, String json) async {
    final file = await _fileFor(fileName);
    await file.writeAsString(json, flush: true);
  }

  Future<File> _fileFor(String fileName) async {
    final directory = await _documentsDirectoryLoader();
    return File('${directory.path}/$fileName');
  }
}
