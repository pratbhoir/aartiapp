import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_constants.dart';

/// Lightweight local activity log with JSONL persistence.
abstract final class ActivityLogService {
  static final List<String> _lines = <String>[];

  static File? _file;
  static bool _initialized = false;

  /// Number of entries currently loaded in memory.
  static int get length => _lines.length;

  /// Hydrates the in-memory buffer from local JSONL file.
  static Future<void> init() async {
    if (_initialized) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${AppConstants.activityLogFileName}');
      _file = file;

      if (await file.exists()) {
        final raw = await file.readAsLines();
        _lines
          ..clear()
          ..addAll(raw.where((line) => line.trim().isNotEmpty));
      } else {
        await file.create(recursive: true);
      }

      _trimIfNeeded();
      await _flush();
      _initialized = true;
      info('ActivityLog', 'Initialized with ${_lines.length} existing entries');
    } catch (e, stack) {
      debugPrint('ActivityLog init failed: $e');
      debugPrint(stack.toString());
    }
  }

  /// Logs an informational event.
  static void info(String tag, String message) {
    _write(level: 'info', tag: tag, message: message);
  }

  /// Logs a warning event.
  static void warn(String tag, String message, [StackTrace? stack]) {
    _write(level: 'warn', tag: tag, message: message, stack: stack);
  }

  /// Logs an error event.
  static void error(String tag, String message, [StackTrace? stack]) {
    _write(level: 'error', tag: tag, message: message, stack: stack);
  }

  /// Returns entries in newest-first order.
  static Future<List<Map<String, dynamic>>> getEntries() async {
    if (!_initialized) {
      await init();
    }

    return _lines.reversed.map(_parseLine).toList(growable: false);
  }

  /// Clears the in-memory and persisted activity log.
  static Future<void> clear() async {
    try {
      _lines.clear();
      await _flush();
      if (kDebugMode) {
        debugPrint('[ActivityLog][info][ActivityLog] Log cleared');
      }
    } catch (e, stack) {
      debugPrint('ActivityLog clear failed: $e');
      debugPrint(stack.toString());
    }
  }

  /// Shares a timestamped log snapshot as a text file.
  static Future<void> share() async {
    if (!_initialized) {
      await init();
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final safeTs = now.toIso8601String().replaceAll(':', '-');
      final file = File('${tempDir.path}/aarti_activity_log_$safeTs.txt');

      final content = StringBuffer()
        ..writeln(_buildShareHeader(now))
        ..writeln('---')
        ..writeln(_lines.join('\n'));

      await file.writeAsString(content.toString(), flush: true);
      await Share.shareXFiles(
        <XFile>[XFile(file.path)],
        text: 'Aarti Sangrah activity log',
      );
    } catch (e, stack) {
      debugPrint('ActivityLog share failed: $e');
      debugPrint(stack.toString());
    }
  }

  static void _write({
    required String level,
    required String tag,
    required String message,
    StackTrace? stack,
  }) {
    try {
      final payload = <String, dynamic>{
        'ts': DateTime.now().toUtc().toIso8601String(),
        'level': level,
        'tag': tag,
        'msg': message,
        if (stack != null) 'stack': _compactStack(stack),
      };

      _lines.add(jsonEncode(payload));
      _trimIfNeeded();

      if (kDebugMode) {
        debugPrint('[ActivityLog][$level][$tag] $message');
      }

      unawaited(_flush());
    } catch (e, fallbackStack) {
      debugPrint('ActivityLog write failed: $e');
      debugPrint(fallbackStack.toString());
    }
  }

  static void _trimIfNeeded() {
    final overflow = _lines.length - AppConstants.activityLogMaxEntries;
    if (overflow > 0) {
      _lines.removeRange(0, overflow);
    }
  }

  static Future<void> _flush() async {
    try {
      final file = _file;
      if (file == null) return;
      await file.writeAsString(_lines.join('\n'), flush: true);
    } catch (e, stack) {
      debugPrint('ActivityLog flush failed: $e');
      debugPrint(stack.toString());
    }
  }

  static Map<String, dynamic> _parseLine(String line) {
    try {
      final decoded = jsonDecode(line);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {
      // Fallback map for malformed lines.
    }

    return <String, dynamic>{
      'ts': DateTime.now().toUtc().toIso8601String(),
      'level': 'warn',
      'tag': 'ActivityLog',
      'msg': 'Malformed log line',
      'raw': line,
    };
  }

  static String _compactStack(StackTrace stack) {
    return stack.toString().split('\n').take(8).join('\n');
  }

  static String _buildShareHeader(DateTime now) {
    return [
      'Aarti Sangrah Activity Log',
      'Generated: ${now.toIso8601String()}',
      'Entries: ${_lines.length}',
      'Format: JSONL',
    ].join('\n');
  }
}