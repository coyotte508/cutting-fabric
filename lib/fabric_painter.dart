import 'package:flutter/material.dart';

class FabricPainter extends CustomPainter {
  final ({double patternWidth, double patternLength})? Function()
      _patternGetter;

  FabricPainter(this._patternGetter);

  ({double patternWidth, double patternLength})? storedPattern;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    final pattern = _patternGetter();

    storedPattern = pattern;

    if (pattern != null) {
      final patternPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      for (var i = pattern.patternLength;
          i < size.width;
          i += pattern.patternLength) {
        final path = Path()
          ..moveTo(i, 0)
          ..lineTo(i, size.height);

        canvas.drawPath(path, patternPaint);
      }

      for (var i = pattern.patternWidth;
          i < size.height;
          i += pattern.patternWidth) {
        final path = Path()
          ..moveTo(0, i.toDouble())
          ..lineTo(size.width, i.toDouble());

        canvas.drawPath(path, patternPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    final oldPattern = (oldDelegate as FabricPainter).storedPattern;
    final newPattern = _patternGetter();
    if (oldPattern == newPattern) {
      return false;
    }
    if (oldPattern == null || newPattern == null) {
      return true;
    }
    return oldPattern.patternWidth != newPattern.patternWidth ||
        oldPattern.patternLength != newPattern.patternLength;
  }
}
