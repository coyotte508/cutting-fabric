// Todo: use binary tree for better times

import 'dart:math';

class OrderedMap<V> extends Iterable<({int k, V v})> {
  final List<({int k, V v})> _list = [];

  static OrderedMap<V> of<V>(List<({int k, V v})> items) {
    final map = OrderedMap<V>();
    for (final item in items) {
      map.put(item.k, item.v);
    }
    return map;
  }

  ({int? prev, int? exact, int? next}) pointer(int k) {
    if (_list.isEmpty) {
      return (prev: null, exact: null, next: null);
    }
    var l = 0;
    var r = _list.length;
    while (l < r) {
      final m = (l + r) ~/ 2;
      if (_list[m].k < k) {
        l = m + 1;
      } else {
        r = m;
      }
    }

    // now l is the first element that is greater or equal to k

    final exact = l < _list.length && _list[l].k == k ? l : null;
    final before = l - 1 < 0 ? null : l - 1;
    final after = exact != null ? (l + 1 >= _list.length ? null : l + 1) : (l >= _list.length ? null : l);

    return (prev: before, exact: exact, next: after);
  }

  V? operator [](int k) {
    return atPointer(pointer(k));
  }

  V? atPointer(OrderedMapPointer pointer) {
    return pointer.exact != null ? _list[pointer.exact!].v : null;
  }

  V? beforePointer(OrderedMapPointer pointer) {
    return pointer.prev != null ? _list[pointer.prev!].v : null;
  }

  bool has(OrderedMapPointer pointer) {
    return pointer.exact != null;
  }

  (OrderedMapPointer, bool added) putIfAbsent(int k, V v) {
    final pointer = this.pointer(k);
    if (pointer.exact != null) {
      return (pointer, false);
    } else if (pointer.prev == null) {
      _list.insert(0, (k: k, v: v));
      return ((prev: null, exact: 0, next: _list.length > 1 ? 1 : null), true);
    } else {
      _list.insert(pointer.prev! + 1, (k: k, v: v));
      return ((prev: pointer.prev, exact: pointer.prev! + 1, next: pointer.prev! + 2), true);
    }
  }

  OrderedMapPointer put(int k, V v) {
    final pointer = this.pointer(k);
    if (pointer.exact != null) {
      _list[pointer.exact!] = (k: k, v: v);
      return pointer;
    } else if (pointer.prev == null) {
      _list.insert(0, (k: k, v: v));
      return (prev: null, exact: 0, next: _list.length > 1 ? 1 : null);
    } else {
      _list.insert(pointer.prev! + 1, (k: k, v: v));
      return (prev: pointer.prev, exact: pointer.prev! + 1, next: pointer.prev! + 2);
    }
  }

  OrderedMapPointer prevPointer(OrderedMapPointer pointer) {
    if (pointer.prev == null) {
      return pointer;
    }
    return (prev: pointer.prev! - 1, exact: pointer.prev, next: pointer.exact);
  }

  OrderedMapPointer nextPointer(OrderedMapPointer pointer) {
    if (pointer.next == null) {
      return pointer;
    }
    return (prev: pointer.exact, exact: pointer.next, next: pointer.next! + 1);
  }

  /// Returns values in the range [start, endExcl[
  /// If there is no exact match for start, it will return the next value
  /// If there is no exact match for endExcl, it will return the previous value
  Iterable<V> rangedPointerValues(OrderedMapPointer start, OrderedMapPointer endExcl) sync* {
    final startIndex = start.exact ?? start.next ?? _list.length;
    final endIndex = min(endExcl.exact ?? endExcl.prev ?? 0, _list.length - 1);

    for (var i = startIndex; i < endIndex; i++) {
      yield _list[i].v;
    }
  }

  /// Returns values in the range [start, endIncl]
  /// If there is no exact match for start, it will return the previous value
  /// If there is no exact match for endIncl, it will return the previous value
  Iterable<V> rangedValuesEnglobingStart(int minKey, int maxKeyIncl) sync* {
    final startPointer = this.pointer(minKey);
    final startIndex = startPointer.exact ?? startPointer.prev ?? 0;

    for (var i = startIndex; i < _list.length; i++) {
      if (_list[i].k > maxKeyIncl) {
        break;
      }

      yield _list[i].v;
    }
  }

  @override
  Iterator<({int k, V v})> get iterator => _list.iterator;
  Iterable<int> get keys sync* {
    for (final item in _list) {
      yield item.k;
    }
  }

  get lastCoordinate => _list.isEmpty ? 0 : _list.last.k;
}

typedef OrderedMapPointer = ({int? prev, int? exact, int? next});
