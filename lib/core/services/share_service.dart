// lib/core/services/share_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Captures a [RepaintBoundary] identified by [boundaryKey] and shares it
  /// as a PNG image.
  ///
  /// **Dark image fix:** Pass [backgroundColor] to composite a solid background
  /// behind the captured widget before encoding. This prevents transparent or
  /// theme-inherited dark surfaces from producing a black/dark share image.
  ///
  /// Callers should also ensure the widget inside the [RepaintBoundary] has an
  /// explicit background (e.g. wrap with [Material] or [ColoredBox]) for best
  /// results when [backgroundColor] is null.
  ///
  /// Parameters:
  /// - [boundaryKey]    GlobalKey on the RepaintBoundary widget to capture.
  /// - [fileBaseName]   Output filename without extension (e.g. 'prayer_card').
  /// - [text]           Optional share text shown alongside the image.
  /// - [pixelRatio]     Render resolution multiplier. Default 3.0 (high-res).
  /// - [backgroundColor] Optional background color composited behind the image.
  ///                    Use [Colors.white] to guarantee a white background, or
  ///                    pass your theme's surface color. If null, the widget's
  ///                    own background is used as-is.
  static Future<void> shareRepaintBoundary({
    required GlobalKey boundaryKey,
    required String fileBaseName,
    String? text,
    double pixelRatio = 3.0,
    ui.Color? backgroundColor,
  }) async {
    // Wait for any pending frames to finish rendering
    await WidgetsBinding.instance.endOfFrame;

    final context = boundaryKey.currentContext;
    if (context == null || !context.mounted) {
      debugPrint('❌ ShareService: boundaryKey has no valid context');
      return;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      debugPrint('❌ ShareService: renderObject is not a RenderRepaintBoundary');
      return;
    }

    // Capture the widget as a raw image at the requested pixel ratio
    final ui.Image capturedImage =
        await renderObject.toImage(pixelRatio: pixelRatio);

    ui.Image finalImage = capturedImage;

    // Composite a background color if provided — fixes dark/transparent images
    if (backgroundColor != null) {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final width = capturedImage.width.toDouble();
      final height = capturedImage.height.toDouble();

      // Draw solid background first
      canvas.drawRect(
        ui.Rect.fromLTWH(0, 0, width, height),
        ui.Paint()..color = backgroundColor,
      );

      // Draw the captured widget on top
      canvas.drawImage(capturedImage, ui.Offset.zero, ui.Paint());

      final picture = recorder.endRecording();
      finalImage = await picture.toImage(
        capturedImage.width,
        capturedImage.height,
      );

      // Dispose the intermediate image to free memory
      capturedImage.dispose();
    }

    // Encode to PNG bytes
    final ByteData? byteData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);

    finalImage.dispose();

    if (byteData == null) {
      debugPrint('❌ ShareService: failed to encode image to PNG');
      return;
    }

    final Uint8List pngBytes = byteData.buffer.asUint8List();

    // Write to a temp file and share
    final Directory dir = await getTemporaryDirectory();
    final File file = File('${dir.path}/$fileBaseName.png');
    await file.writeAsBytes(pngBytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: text,
      ),
    );

    debugPrint('✅ ShareService: shared $fileBaseName.png');
  }
}