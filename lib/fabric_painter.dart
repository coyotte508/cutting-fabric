import 'package:flutter/material.dart';
import 'package:upholstery_cutting_tool/algorithm.dart';
import 'fabric.dart';

class FabricPainter extends CustomPainter {
  final (int width, bool showPattern, PatternInfo?, PanelPlacements placements) Function() _patternGetter;

  FabricPainter(this._patternGetter);

  PatternInfo? storedPattern;
  int? storedWidth;
  PanelPlacements? storedPlacements;

  @override
  void paint(Canvas canvas, Size size) {
    final (width, showPattern, pattern, placements) = _patternGetter();

    final ratio = size.width / width;

    storedPattern = pattern;
    storedWidth = width;
    storedPlacements = placements;

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

    for (final placement in placements.placements) {
      final x = placement.x * ratio;
      final y = placement.y * ratio;
      final width = placement.panel.width * ratio;
      final height = placement.panel.length * ratio;

      final panelPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 1.0
        ..style = PaintingStyle.fill;

      canvas.drawRect(Rect.fromLTWH(x, y, width, height), panelPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: placement.panel.name,
          style: const TextStyle(color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(maxWidth: width);

      textPainter.paint(canvas, Offset(x, y));

      final borderPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawRect(Rect.fromLTWH(x, y, width, height), borderPaint);
    }

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
    final (newWidth, _, newPattern, placements) = _patternGetter();
    if (storedPlacements != placements) {
      return true;
    }
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
