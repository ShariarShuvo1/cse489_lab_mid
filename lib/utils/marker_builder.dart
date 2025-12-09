import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_theme.dart';

//AI generated structure but custom theme colors and design
Future<BitmapDescriptor> createCustomMarker() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = 80.0;

  final yellowPaint = Paint()
    ..color = AppTheme.yellowForeground
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  final blackPaint = Paint()
    ..color = AppTheme.darkBackground
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  final blackStrokePaint = Paint()
    ..color = AppTheme.darkBackground
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..isAntiAlias = true;

  const pinHeadRadius = 14.0;
  const pinHeadY = 18.0;

  canvas.drawCircle(
    const Offset(size / 2, pinHeadY),
    pinHeadRadius,
    yellowPaint,
  );

  canvas.drawCircle(const Offset(size / 2, pinHeadY), 8.0, blackPaint);

  final needlePath = Path();
  needlePath.moveTo(size / 2 - 6, pinHeadY + pinHeadRadius - 2);
  needlePath.lineTo(size / 2 + 6, pinHeadY + pinHeadRadius - 2);
  needlePath.lineTo(size / 2, 55);
  needlePath.close();

  canvas.drawPath(needlePath, yellowPaint);

  canvas.drawCircle(
    const Offset(size / 2, pinHeadY),
    pinHeadRadius,
    blackStrokePaint,
  );

  canvas.drawPath(needlePath, blackStrokePaint);

  final image = await recorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
}
