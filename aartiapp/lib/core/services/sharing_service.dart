import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/aarti_item.dart';

/// Service for sharing Aarti lyrics as text or image.
class SharingService {
  SharingService._();

  static final SharingService instance = SharingService._();

  /// Share Aarti lyrics as formatted text.
  Future<void> shareAsText(AartiItem aarti) async {
    final buffer = StringBuffer();
    buffer.writeln('🙏 ${aarti.title}');
    buffer.writeln(aarti.devanagari);
    buffer.writeln('');
    buffer.writeln('Deity: ${aarti.deity}');
    buffer.writeln('');

    for (final verse in aarti.verses) {
      buffer.writeln('— ${verse.label} —');
      for (final line in verse.lines) {
        buffer.writeln(line);
      }
      buffer.writeln('');
    }

    buffer.writeln('Shared from Aarti Sangrah 🙏');

    await Share.share(buffer.toString());
  }

  /// Share Aarti lyrics as an image captured from [repaintKey].
  ///
  /// The caller must wrap the widget tree to capture with a
  /// `RepaintBoundary` whose key is [repaintKey].
  Future<void> shareAsImage(
    GlobalKey repaintKey, {
    String filename = 'aarti_lyrics.png',
  }) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final xFile = XFile.fromData(
        bytes,
        mimeType: 'image/png',
        name: filename,
      );

      await Share.shareXFiles([xFile]);
    } catch (_) {
      // Fail silently
    }
  }
}
