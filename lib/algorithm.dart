import "dart:math";
import 'package:flutter/material.dart';

import './ordered_map.dart';
import 'fabric.dart';

class CutPlacement {
  CutPlacement({required this.cut, required this.x, required this.y});

  final CutInfo cut;
  final int x;
  final int y;

  bool intersects(CutPlacement other) {
    return x < other.x + other.cut.width &&
        x + cut.width > other.x &&
        y < other.y + other.cut.length &&
        y + cut.length > other.y;
  }
}

class Rectangle {
  Rectangle({required this.width, required this.length, required this.x, required this.y});

  final int width;
  final int length;
  final int x;
  final int y;

  get area => width * length;
}

class CutPlacements {
  CutPlacements({required this.fabricWidth, this.pattern});

  final List<CutPlacement> placements = [];

  // /// For a list of X coordinates, lists all cuts that intersect with that X coordinate
  // final OrderedMap<OrderedMap<CutPlacement>> cutsByX = OrderedMap();

  /// For a list of Y coordinates, lists all cuts that intersect with that Y coordinate
  final OrderedMap<OrderedMap<CutPlacement>> cutsByY = OrderedMap.of([(k: 0, v: OrderedMap<CutPlacement>())]);

  // todo: maintain a list of "gaps" instead of computing them on the fly
  // it could even contain invalid gaps that would be invalidated when checked next time

  final int fabricWidth;
  PatternInfo? pattern;

  get totalLength => cutsByY.lastCoordinate;

  addCut(CutInfo cut, int x, int y) {
    final placement = CutPlacement(cut: cut, x: x, y: y);
    placements.add(placement);

    final (hStart, addedStart) = cutsByY.putIfAbsent(y, OrderedMap());
    final (hEnd, addedEnd) = cutsByY.putIfAbsent(y + cut.length, OrderedMap());

    if (addedStart) {
      for (final item in (cutsByY.beforePointer(hStart) ?? OrderedMap())) {
        if (item.v.y + item.v.cut.length - 1 >= y) {
          cutsByY.atPointer(hStart)!.put(item.k, item.v);
        }
      }
    }

    if (addedEnd) {
      for (final item in (cutsByY.beforePointer(hEnd) ?? OrderedMap())) {
        if (item.v.y + item.v.cut.length - 1 >= y + cut.length) {
          cutsByY.atPointer(hEnd)!.put(item.k, item.v);
        }
      }
    }

    for (final h in cutsByY.rangedPointerValues(hStart, hEnd)) {
      h.put(x, placement);
    }
  }

  /// Returns a tuple with a boolean indicating if the cut can be placed at the given coordinates and if not,
  ///  an integer indicating where the cut can be moved to the right to avoid the collision
  ({bool ok, int? moveRightTo}) canPlaceCut(CutInfo cut, int x, int y) {
    final placement = CutPlacement(cut: cut, x: x, y: y);

    for (final v in cutsByY.rangedValuesEnglobingStart(y, y + cut.length - 1)) {
      for (final item in v.rangedValuesEnglobingStart(x, x + cut.width - 1)) {
        if (placement.intersects(item)) {
          return (ok: false, moveRightTo: item.x + item.cut.width);
        }
      }
    }

    return (ok: true, moveRightTo: null);
  }

  void placeCutBottomLeft(CutInfo cut) {
    final hasGrid = pattern != null && cut.centerOnPattern;
    var iteratorY = cutsByY.iterator;

    // debugPrint("Placing cut ${cut.width}x${cut.length} ${cut.name}");

    if (!iteratorY.moveNext()) {
      // debugPrint("No cuts yet, placing at 0, 0");
      addCut(cut, hasGrid ? nextGridCoord(0, pattern!.width, cut.width) : 0,
          hasGrid ? nextGridCoord(0, pattern!.length, cut.length) : 0);
      return;
    }

    var y = iteratorY.current;
    while (iteratorY.moveNext()) {
      final nextY = iteratorY.current;

      final yCoord = hasGrid ? nextGridCoord(y.k, pattern!.length, cut.length) : y.k;

      if (yCoord > nextY.k) {
        // debugPrint("Moving to next Y $nextY");
        y = nextY;
        continue;
      }
      // debugPrint("Y $yCoord");

      final gaps = _findGapsAtY(y.v, cut.width);

      for (final gap in gaps) {
        // debugPrint("Gap at ${gap.start} to ${gap.end}");
        for (var x = hasGrid ? nextGridCoord(gap.start, pattern!.width, cut.width) : gap.start;
            x <= gap.end - cut.width;
            x = hasGrid ? nextGridCoord(x, pattern!.width, cut.width) : x) {
          final canPlace = canPlaceCut(cut, x, yCoord);
          if (canPlace.ok) {
            addCut(cut, x, yCoord);
            return;
          } else {
            x = canPlace.moveRightTo!;
          }
        }
      }

      y = nextY;
    }
    addCut(cut, hasGrid ? nextGridCoord(0, pattern!.width, cut.width) : 0,
        hasGrid ? nextGridCoord(totalLength, pattern!.length, cut.length) : totalLength);
  }

  Iterable<({int start, int end})> _findGapsAtY(OrderedMap<CutPlacement> cuts, int minWidth) sync* {
    var prevX = 0;

    for (final item in cuts) {
      // debugPrint("Cut at ${item.v.x} with width ${item.v.cut.width}");
      if (item.v.x - prevX >= minWidth) {
        yield (start: prevX, end: item.v.x);
      }

      prevX = item.v.x + item.v.cut.width;
    }

    // debugPrint("Remaining space ${fabricWidth - prevX} ${fabricWidth} ${prevX} ${minWidth}");

    if (fabricWidth - prevX >= minWidth) {
      yield (start: prevX, end: fabricWidth);
    }
  }
}

int nextGridCoord(int coord, int gridSize, int cutSize) {
  final offset = (gridSize - (((cutSize - gridSize) ~/ 2) % gridSize)) % gridSize;
  // debugPrint("Next grid coord $coord $gridSize $cutSize");
  // debugPrint("Offset $offset");
  return ((coord + gridSize - offset - 1) ~/ gridSize) * gridSize + offset;
}
