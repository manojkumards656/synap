import '../core/constants.dart';
import '../models/touch_event.dart';

class TouchBuffer {
  final int capacity;
  final List<TouchEvent?> _buffer;
  int _head = 0;
  int _count = 0;

  TouchBuffer({this.capacity = CDIConstants.bufferCapacity})
      : _buffer = List<TouchEvent?>.filled(CDIConstants.bufferCapacity, null);

  /// Appends a new touch event to the circular buffer.
  /// If it's an UP event, attempts to pair with the preceding DOWN event for dwell calculation.
  void add(TouchEvent event) {
    if (event.type == TouchType.up) {
      // Find the most recent uncompleted DOWN event to calculate dwell
      for (int i = 0; i < _count; i++) {
        final idx = (_head - 1 - i + capacity) % capacity;
        final candidate = _buffer[idx];
        if (candidate != null &&
            candidate.type == TouchType.down &&
            candidate.dwellTimeMs == null) {
          final dwell = event.timestampMs - candidate.timestampMs;
          if (dwell >= 0 && dwell < 3000) {
            candidate.dwellTimeMs = dwell;
            event.dwellTimeMs = dwell;
          }
          break;
        }
      }
    }

    _buffer[_head] = event;
    _head = (_head + 1) % capacity;
    if (_count < capacity) {
      _count++;
    }
  }

  /// Returns all active events in chronological order.
  List<TouchEvent> get events {
    final list = <TouchEvent>[];
    final start = (_count == capacity) ? _head : 0;
    for (int i = 0; i < _count; i++) {
      final item = _buffer[(start + i) % capacity];
      if (item != null) {
        list.add(item);
      }
    }
    return list;
  }

  /// Returns chronological DOWN events only.
  List<TouchEvent> get downEvents {
    return events.where((e) => e.type == TouchType.down).toList();
  }

  /// Returns chronological UP events only.
  List<TouchEvent> get upEvents {
    return events.where((e) => e.type == TouchType.up).toList();
  }

  int get length => _count;

  void clear() {
    _buffer.fillRange(0, capacity, null);
    _head = 0;
    _count = 0;
  }
}
