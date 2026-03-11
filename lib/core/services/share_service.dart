// lib/core/services/share_service.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareWidget({
    required Widget widget,
    required String fileBaseName,
    String? text,
    double pixelRatio = 3.0,
    Size logicalSize = const Size(420, 9999), // height is unconstrained
  }) async {
    // Wrap in a LayoutBuilder so intrinsic height is respected
    final renderView = RenderRepaintBoundary();
    final renderView2 = RenderView(
      view: WidgetsBinding.instance.platformDispatcher.views.first,
      child: RenderPositionedBox(
        alignment: Alignment.topCenter,
        child: renderView,
      ),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints(
          maxWidth: logicalSize.width,
          maxHeight: logicalSize.height,
        ),
        devicePixelRatio: pixelRatio,
      ),
    );

    final pipelineOwner = PipelineOwner();
    pipelineOwner.rootNode = renderView2;
    renderView2.prepareInitialFrame();

    final buildOwner = BuildOwner(focusManager: FocusManager());

    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: renderView,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(),
          child: widget,
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await renderView.toImage(pixelRatio: pixelRatio);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (byteData == null) {
      debugPrint('❌ ShareService.shareWidget: failed to encode PNG');
      return;
    }

    final Uint8List pngBytes = byteData.buffer.asUint8List();
    final Directory dir = await getTemporaryDirectory();
    final File file = File('${dir.path}/$fileBaseName.png');
    await file.writeAsBytes(pngBytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: text),
    );

    debugPrint('✅ ShareService.shareWidget: shared $fileBaseName.png');
  }

  static Future<void> shareRepaintBoundary({
    required GlobalKey boundaryKey,
    required String fileBaseName,
    String? text,
    double pixelRatio = 3.0,
    ui.Color? backgroundColor,
  }) async {
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

    final ui.Image capturedImage =
        await renderObject.toImage(pixelRatio: pixelRatio);

    ui.Image finalImage = capturedImage;

    if (backgroundColor != null) {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final width = capturedImage.width.toDouble();
      final height = capturedImage.height.toDouble();

      canvas.drawRect(
        ui.Rect.fromLTWH(0, 0, width, height),
        ui.Paint()..color = backgroundColor,
      );
      canvas.drawImage(capturedImage, ui.Offset.zero, ui.Paint());

      final picture = recorder.endRecording();
      finalImage = await picture.toImage(
        capturedImage.width,
        capturedImage.height,
      );
      capturedImage.dispose();
    }

    final ByteData? byteData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);
    finalImage.dispose();

    if (byteData == null) {
      debugPrint('❌ ShareService: failed to encode image to PNG');
      return;
    }

    final Uint8List pngBytes = byteData.buffer.asUint8List();
    final Directory dir = await getTemporaryDirectory();
    final File file = File('${dir.path}/$fileBaseName.png');
    await file.writeAsBytes(pngBytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: text),
    );

    debugPrint('✅ ShareService: shared $fileBaseName.png');
  }
}
