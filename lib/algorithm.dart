import "dart:math";
import 'package:flutter/material.dart';

import './ordered_map.dart';
import 'fabric.dart';

class PanelPlacement {
  PanelPlacement({required this.panel, required this.x, required this.y});

  final PanelInfo panel;
  final int x;
  final int y;

  bool intersects(PanelPlacement other) {
    return x < other.x + other.panel.width &&
        x + panel.width > other.x &&
        y < other.y + other.panel.length &&
        y + panel.length > other.y;
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

class PanelPlacements {
  PanelPlacements({required this.fabricWidth, this.pattern});

  final List<PanelPlacement> placements = [];

  // /// For a list of X coordinates, lists all panels that intersect with that X coordinate
  // final OrderedMap<OrderedMap<PanelPlacement>> panelsByX = OrderedMap();

  /// For a list of Y coordinates, lists all panels that intersect with that Y coordinate
  final OrderedMap<OrderedMap<PanelPlacement>> panelsByY = OrderedMap.of([(k: 0, v: OrderedMap<PanelPlacement>())]);

  // todo: maintain a list of "gaps" instead of computing them on the fly
  // it could even contain invalid gaps that would be invalidated when checked next time

  final int fabricWidth;
  PatternInfo? pattern;

  get totalLength =>
      placements.fold(0, (previousValue, element) => max(previousValue, element.y + element.panel.length));

  addPanel(PanelInfo panel, int x, int y) {
    final placement = PanelPlacement(panel: panel, x: x, y: y);
    placements.add(placement);

    final (hStart, addedStart) = panelsByY.putIfAbsent(y, OrderedMap());
    final (hEnd, addedEnd) = panelsByY.putIfAbsent(y + panel.length - 1, OrderedMap());

    if (addedStart) {
      for (final item in (panelsByY.beforePointer(hStart) ?? OrderedMap())) {
        if (item.v.y + item.v.panel.length - 1 >= y) {
          panelsByY.atPointer(hStart)!.put(item.k, item.v);
        }
      }
    }

    if (addedEnd) {
      for (final item in (panelsByY.beforePointer(hEnd) ?? OrderedMap())) {
        if (item.v.y + item.v.panel.length - 1 >= y) {
          panelsByY.atPointer(hEnd)!.put(item.k, item.v);
        }
      }
    }

    for (final h in panelsByY.rangedPointerValues(hStart, hEnd)) {
      h.put(x, placement);
    }
  }

  /// Returns a tuple with a boolean indicating if the panel can be placed at the given coordinates and if not,
  ///  an integer indicating where the panel can be moved to the right to avoid the collision
  ({bool ok, int? moveRightTo}) canPlacePanel(PanelInfo panel, int x, int y) {
    final placement = PanelPlacement(panel: panel, x: x, y: y);

    for (final v in panelsByY.rangedValuesEnglobingStart(y, y + panel.length - 1)) {
      for (final item in v.rangedValuesEnglobingStart(x, x + panel.width - 1)) {
        if (placement.intersects(item)) {
          return (ok: false, moveRightTo: item.x + item.panel.width);
        }
      }
    }

    return (ok: true, moveRightTo: null);
  }

  void placePanelBottomLeft(PanelInfo panel) {
    final hasGrid = pattern != null && panel.centerOnPattern;
    var iteratorY = panelsByY.iterator;

    // debugPrint("Placing panel ${panel.width}x${panel.length} on fabric $fabricWidth with pattern $pattern");

    if (!iteratorY.moveNext()) {
      // debugPrint("No panels yet, placing at 0, 0");
      addPanel(panel, hasGrid ? nextGridCoord(0, pattern!.width, panel.width) : 0,
          hasGrid ? nextGridCoord(0, pattern!.length, panel.length) : 0);
      return;
    }

    var y = iteratorY.current;
    while (iteratorY.moveNext()) {
      final nextY = iteratorY.current;

      final gaps = _findGapsAtY(y.v, panel.width);

      final yCoord = hasGrid ? nextGridCoord(y.k, pattern!.length, panel.length) : y.k;

      if (yCoord > nextY.k) {
        // debugPrint("Moving to next Y $nextY");
        y = nextY;
        continue;
      }
      // debugPrint("Y $yCoord");

      for (final gap in gaps) {
        // debugPrint("Gap at ${gap.start} to ${gap.end}");
        for (var x = hasGrid ? nextGridCoord(gap.start, pattern!.width, panel.width) : gap.start;
            x <= gap.end - panel.width;
            x = hasGrid ? nextGridCoord(x, pattern!.width, panel.width) : x) {
          final canPlace = canPlacePanel(panel, x, yCoord);
          if (canPlace.ok) {
            addPanel(panel, x, yCoord);
            return;
          } else {
            x = canPlace.moveRightTo!;
          }
        }
      }

      y = nextY;
    }
    addPanel(panel, hasGrid ? nextGridCoord(0, pattern!.width, panel.width) : 0,
        hasGrid ? nextGridCoord(totalLength, pattern!.length, panel.length) : totalLength);
  }

  Iterable<({int start, int end})> _findGapsAtY(OrderedMap<PanelPlacement> panels, int minWidth) sync* {
    // debugPrint("Finding gaps at Y $minWidth");
    var prevX = 0;

    for (final item in panels) {
      // debugPrint("Panel at ${item.v.x} with width ${item.v.panel.width}");
      if (item.v.x - prevX >= minWidth) {
        yield (start: prevX, end: item.v.x);
      }

      prevX = item.v.x + item.v.panel.width;
    }

    // debugPrint("Remaining space ${fabricWidth - prevX} ${fabricWidth} ${prevX} ${minWidth}");

    if (fabricWidth - prevX >= minWidth) {
      yield (start: prevX, end: fabricWidth);
    }
  }
}

int nextGridCoord(int coord, int gridSize, int panelSize) {
  // debugPrint("Next grid coord $coord $gridSize $panelSize");
  final offset = ((panelSize - gridSize) ~/ 2 * (gridSize < panelSize ? 1 : -1)) % gridSize;
  // debugPrint("Offset $offset");
  return ((coord + gridSize - offset - 1) ~/ gridSize) * gridSize + offset;
}
