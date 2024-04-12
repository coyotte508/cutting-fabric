import 'package:flutter/material.dart';
import 'fabric.dart';

class FabricPainter extends CustomPainter {
  final (double width, bool showPattern, PatternInfo?) Function() _patternGetter;

  FabricPainter(this._patternGetter);

  PatternInfo? storedPattern;
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

      for (var i = pattern.length; i < size.height / ratio; i += pattern.length) {
        final path = Path()
          ..moveTo(0, i * ratio)
          ..lineTo(width * ratio, i * ratio);

        canvas.drawPath(path, patternPaint);
      }

      for (var i = pattern.width; i < width; i += pattern.width) {
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
    final (newWidth, _, newPattern) = _patternGetter();
    if (oldPattern == newPattern) {
      return false;
    }
    if (oldPattern == null || newPattern == null) {
      return true;
    }
    if (newWidth != oldWidth) {
      return true;
    }
    return oldPattern.width != newPattern.width || oldPattern.length != newPattern.length;
  }
}
