import "dart:math";
import 'fabric.dart';

class PanelPlacement {
  PanelPlacement({required this.panel, required this.x, required this.y});

  final PanelInfo panel;
  final double x;
  final double y;
}

class Rectangle {
  Rectangle({required this.width, required this.length, required this.x, required this.y});

  final double width;
  final double length;
  final double x;
  final double y;

  get area => width * length;
}

class PanelPlacements {
  PanelPlacements({required this.fabricWidth});

  final List<PanelPlacement> placements = [];
  final List<Rectangle> availableSpaces = [];
  final double fabricWidth;

  get totalLength =>
      placements.fold(0.0, (previousValue, element) => max(previousValue, element.y + element.panel.length));

  /// Uses BM67 box packing algorithm to place panels on fabric: https://stackoverflow.com/a/45685043/835629
  addPanel(PanelInfo panel) {
    // todo: handle rotation, centering on pattern
    for (var availableSpace in availableSpaces) {
      if (availableSpace.width >= panel.width && availableSpace.length >= panel.length) {
        placements.add(PanelPlacement(panel: panel, x: availableSpace.x, y: availableSpace.y));

        availableSpaces.remove(availableSpace);

        if (availableSpace.width > panel.width) {
          availableSpaces.add(Rectangle(
              width: availableSpace.width - panel.width,
              length: panel.length,
              x: availableSpace.x + panel.width,
              y: availableSpace.y));
        }

        if (availableSpace.length > panel.length) {
          availableSpaces.add(Rectangle(
              width: panel.width,
              length: availableSpace.length - panel.length,
              x: availableSpace.x,
              y: availableSpace.y + panel.length));
        }

        // todo: instead of sorting every time, insert in sorted order
        availableSpaces.sort((a, b) => a.area.compareTo(b.area));

        // todo: merge adjacent spaces of the same length / width
        return;
      }
    }

    placements.add(PanelPlacement(panel: panel, x: 0, y: totalLength));

    if (panel.width < fabricWidth) {
      availableSpaces
          .add(Rectangle(width: fabricWidth - panel.width, length: panel.length, x: panel.width, y: placements.last.y));

      // todo: instead of sorting every time, insert in sorted order
      availableSpaces.sort((a, b) => a.area.compareTo(b.area));
    }
  }
}
