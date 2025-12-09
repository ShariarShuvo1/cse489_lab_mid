import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_theme.dart';

//AI generated structure but custom theme colors and design
Future<BitmapDescriptor> createCustomMarker() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = 80.0;

  final orangePaint = Paint()
    ..color = const Color(0xFFD97706)
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  final darkPaint = Paint()
    ..color = AppTheme.darkBackground
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  final darkStrokePaint = Paint()
    ..color = AppTheme.darkBackground
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5
    ..isAntiAlias = true;

  const pinHeadRadius = 14.0;
  const pinHeadY = 18.0;

  canvas.drawCircle(
    const Offset(size / 2, pinHeadY),
    pinHeadRadius,
    orangePaint,
  );

  canvas.drawCircle(const Offset(size / 2, pinHeadY), 8.0, darkPaint);

  final needlePath = Path();
  needlePath.moveTo(size / 2 - 6, pinHeadY + pinHeadRadius - 2);
  needlePath.lineTo(size / 2 + 6, pinHeadY + pinHeadRadius - 2);
  needlePath.lineTo(size / 2, 55);
  needlePath.close();

  canvas.drawPath(needlePath, orangePaint);

  canvas.drawCircle(
    const Offset(size / 2, pinHeadY),
    pinHeadRadius,
    darkStrokePaint,
  );

  canvas.drawPath(needlePath, darkStrokePaint);

  final image = await recorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
}

Future<BitmapDescriptor> createUserLocationMarker() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = 80.0;

  final fillPaint = Paint()
    ..color = AppTheme.accentBlue
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  final innerPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  final strokePaint = Paint()
    ..color = AppTheme.darkBackground
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5
    ..isAntiAlias = true;

  const pinHeadRadius = 14.0;
  const pinHeadY = 18.0;

  canvas.drawCircle(const Offset(size / 2, pinHeadY), pinHeadRadius, fillPaint);

  canvas.drawCircle(const Offset(size / 2, pinHeadY), 8.0, innerPaint);

  final needlePath = Path();
  needlePath.moveTo(size / 2 - 6, pinHeadY + pinHeadRadius - 2);
  needlePath.lineTo(size / 2 + 6, pinHeadY + pinHeadRadius - 2);
  needlePath.lineTo(size / 2, 55);
  needlePath.close();

  canvas.drawPath(needlePath, fillPaint);

  canvas.drawCircle(
    const Offset(size / 2, pinHeadY),
    pinHeadRadius,
    strokePaint,
  );

  canvas.drawPath(needlePath, strokePaint);

  final image = await recorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
}

Future<BitmapDescriptor> createPreviewMarker() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = 80.0;

  final fillPaint = Paint()
    ..color = AppTheme.successGreen
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  final innerPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  final strokePaint = Paint()
    ..color = AppTheme.darkBackground
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5
    ..isAntiAlias = true;

  const pinHeadRadius = 14.0;
  const pinHeadY = 18.0;

  canvas.drawCircle(const Offset(size / 2, pinHeadY), pinHeadRadius, fillPaint);

  canvas.drawCircle(const Offset(size / 2, pinHeadY), 8.0, innerPaint);

  final needlePath = Path();
  needlePath.moveTo(size / 2 - 6, pinHeadY + pinHeadRadius - 2);
  needlePath.lineTo(size / 2 + 6, pinHeadY + pinHeadRadius - 2);
  needlePath.lineTo(size / 2, 55);
  needlePath.close();

  canvas.drawPath(needlePath, fillPaint);

  canvas.drawCircle(
    const Offset(size / 2, pinHeadY),
    pinHeadRadius,
    strokePaint,
  );

  canvas.drawPath(needlePath, strokePaint);

  final image = await recorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
}
