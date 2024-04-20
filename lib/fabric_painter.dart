import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cutting_fabric/algorithm.dart';
import 'fabric.dart';

class FabricPainter extends CustomPainter {
  final (int width, bool showPattern, PatternInfo?, CutPlacements placements) Function() _patternGetter;

  FabricPainter(this._patternGetter);

  PatternInfo? storedPattern;
  int? storedWidth;
  CutPlacements? storedPlacements;

  @override
  void paint(Canvas canvas, Size size) {
    // First: fill with white (useful when exporting)
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), whitePaint);

    final (width, showPattern, pattern, placements) = _patternGetter();

    final ratio = size.width / width;

    storedPattern = pattern;
    storedWidth = width;
    storedPlacements = placements;

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.lime,
      Colors.indigo,
      Colors.amber,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey
    ];

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(width * ratio, size.height)
      ..lineTo(width * ratio, 0)
      ..close();

    canvas.drawPath(path, paint);

    final Map<String, Color> givenColors = {};

    var i = 0;
    for (final placement in placements.placements) {
      final x = placement.x * ratio;
      final y = placement.y * ratio;
      final width = placement.cut.width * ratio;
      final height = placement.cut.length * ratio;

      final color = givenColors.containsKey(placement.cut.name)
          ? givenColors[placement.cut.name]!
          : givenColors.putIfAbsent(placement.cut.name, () => colors[i++ % colors.length]);

      final cutPaint = Paint()
        ..color = color
        ..strokeWidth = 1.0
        ..style = PaintingStyle.fill;

      canvas.drawRect(Rect.fromLTWH(x, y, width, height), cutPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: placement.cut.name,
          style: TextStyle(color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(maxWidth: width - 6);

      textPainter.paint(canvas, Offset(x + 3, y + 1));

      final borderPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawRect(Rect.fromLTWH(x, y, width, height), borderPaint);
    }

    if (pattern != null && showPattern) {
      final patternPaint = Paint()
        ..color = darken(Colors.grey, 20)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      for (var i = pattern.length; i < size.height / ratio; i += pattern.length) {
        drawDashedLine(
            canvas: canvas,
            p1: Offset(0, i * ratio),
            p2: Offset(width * ratio, i * ratio),
            pattern: [6, 4],
            paint: patternPaint);
      }

      for (var i = pattern.width; i < width; i += pattern.width) {
        drawDashedLine(
            canvas: canvas,
            p1: Offset(i * ratio, 0),
            p2: Offset(i * ratio, size.height),
            pattern: [6, 4],
            paint: patternPaint);
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

// From https://stackoverflow.com/a/74911486/835629
void drawDashedLine({
  required Canvas canvas,
  required Offset p1,
  required Offset p2,
  required Iterable<double> pattern,
  required Paint paint,
}) {
  assert(pattern.length.isEven);
  final distance = (p2 - p1).distance;
  final normalizedPattern = pattern.map((width) => width / distance).toList();
  final points = <Offset>[];
  double t = 0;
  int i = 0;
  while (t < 1) {
    points.add(Offset.lerp(p1, p2, t)!);
    t += normalizedPattern[i++]; // dashWidth
    points.add(Offset.lerp(p1, p2, t.clamp(0, 1))!);
    t += normalizedPattern[i++]; // dashSpace
    i %= normalizedPattern.length;
  }
  canvas.drawPoints(PointMode.lines, points, paint);
}

// https://stackoverflow.com/a/60191441/835629
Color darken(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  var f = 1 - percent / 100;
  return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(), (c.blue * f).round());
}
