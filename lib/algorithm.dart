import "dart:math";
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
  PanelPlacements({required this.fabricWidth});

  final List<PanelPlacement> placements = [];

  // /// For a list of X coordinates, lists all panels that intersect with that X coordinate
  // final OrderedMap<OrderedMap<PanelPlacement>> panelsByX = OrderedMap();

  /// For a list of Y coordinates, lists all panels that intersect with that Y coordinate
  final OrderedMap<OrderedMap<PanelPlacement>> panelsByY = OrderedMap();

  // todo: maintain a list of "gaps" instead of computing them on the fly
  // it could even contain invalid gaps that would be invalidated when checked next time

  final int fabricWidth;

  get totalLength =>
      placements.fold(0, (previousValue, element) => max(previousValue, element.y + element.panel.length));

  addPanel(PanelInfo panel, int x, int y) {
    final placement = PanelPlacement(panel: panel, x: x, y: y);
    placements.add(placement);

    // final vStart = panelsByX.putIfAbsent(x, OrderedMap());
    // final vEnd = panelsByX.putIfAbsent(x + panel.width, OrderedMap());

    // for (final item in (panelsByX.beforePointer(vStart) ?? OrderedMap())) {
    //   if (item.v.x + item.v.panel.width >= x) {
    //     panelsByX.atPointer(vStart)?.put(item.k, item.v);
    //   }
    // }

    // for (final item in (panelsByX.atPointer(vEnd) ?? OrderedMap())) {
    //   if (item.v.x <= x) {
    //     panelsByX.atPointer(vEnd)?.put(item.k, item.v);
    //   }
    // }

    // for (final v in panelsByX.rangedPointerValues(vStart, vEnd)) {
    //   v.put(y, placement);
    // }

    final hStart = panelsByY.putIfAbsent(y, OrderedMap());
    final hEnd = panelsByY.putIfAbsent(y + panel.length, OrderedMap());

    for (final item in (panelsByY.beforePointer(hStart) ?? OrderedMap())) {
      if (item.v.y + item.v.panel.length >= y) {
        panelsByY.atPointer(hStart)?.put(item.k, item.v);
      }
    }

    for (final item in (panelsByY.atPointer(hEnd) ?? OrderedMap())) {
      if (item.v.y <= y) {
        panelsByY.atPointer(hEnd)?.put(item.k, item.v);
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

    for (final v in panelsByY.rangedValuesEnglobing(y, y + panel.length)) {
      for (final item in v.rangedValuesEnglobing(x, x + panel.width)) {
        if (placement.intersects(item)) {
          return (ok: false, moveRightTo: item.x + item.panel.width);
        }
      }
    }

    return (ok: true, moveRightTo: null);
  }

  void placePanelBottomLeft(PanelInfo panel) {
    var iteratorY = panelsByY.iterator;

    if (!iteratorY.moveNext()) {
      addPanel(panel, 0, 0);
      return;
    }

    var y = iteratorY.current;
    while (iteratorY.moveNext()) {
      final nextY = iteratorY.current;

      final gaps = _findGapsAtY(y.v, panel.width);

      for (final gap in gaps) {
        for (var x = gap.start; x <= gap.end - panel.width;) {
          final canPlace = canPlacePanel(panel, x, y.k);
          if (canPlace.ok) {
            addPanel(panel, x, y.k);
            return;
          } else {
            x = canPlace.moveRightTo!;
          }
        }
      }

      y = nextY;
    }
    addPanel(panel, 0, totalLength);
  }

  Iterable<({int start, int end})> _findGapsAtY(OrderedMap<PanelPlacement> panels, int minWidth) sync* {
    var prevX = 0;

    for (final item in panels) {
      if (item.v.x - prevX >= minWidth) {
        yield (start: prevX, end: item.v.x);
      }

      prevX = item.v.x + item.v.panel.width;
    }
  }
}
