import 'package:flutter/material.dart';

class FabricPainter extends CustomPainter {
  final (
    double width,
    bool showPattern,
    ({double patternWidth, double patternLength})?
  )
      Function() _patternGetter;

  FabricPainter(this._patternGetter);

  ({double patternWidth, double patternLength})? storedPattern;
  double? storedWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final (width, showPattern, pattern) = _patternGetter();

    final ratio = size.width / width;

    storedPattern = pattern;
    storedWidth = width;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(width * ratio, size.height)
      ..lineTo(width * ratio, 0)
      ..close();

    canvas.drawPath(path, paint);

    if (pattern != null && showPattern) {
      final patternPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      for (var i = pattern.patternLength;
          i < size.height / ratio;
          i += pattern.patternLength) {
        final path = Path()
          ..moveTo(0, i * ratio)
          ..lineTo(width * ratio, i * ratio);

        canvas.drawPath(path, patternPaint);
      }

      for (var i = pattern.patternWidth; i < width; i += pattern.patternWidth) {
        final path = Path()
          ..moveTo(i * ratio, 0)
          ..lineTo(i * ratio, size.height);

        canvas.drawPath(path, patternPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    final oldPattern = (oldDelegate as FabricPainter).storedPattern;
    final oldWidth = oldDelegate.storedWidth;
    final (newWidth, showPattern, newPattern) = _patternGetter();
    if (oldPattern == newPattern) {
      return false;
    }
    if (oldPattern == null || newPattern == null) {
      return true;
    }
    if (newWidth != oldWidth) {
      return true;
    }
    return oldPattern.patternWidth != newPattern.patternWidth ||
        oldPattern.patternLength != newPattern.patternLength;
  }
}
