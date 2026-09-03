enum TouchType { down, move, up }

class TouchEvent {
  final int timestampUs;
  final double x;
  final double y;
  final double pressure;
  final TouchType type;
  final String? keyLabel;
  
  double? dwellTimeMs;
  double? flightTimeMs;

  TouchEvent({
    required this.timestampUs,
    required this.x,
    required this.y,
    required this.pressure,
    required this.type,
    this.keyLabel,
    this.dwellTimeMs,
    this.flightTimeMs,
  });

  double get timestampMs => timestampUs / 1000.0;

  @override
  String toString() {
    return 'TouchEvent($type, key: $keyLabel, t: ${timestampMs.toStringAsFixed(1)}ms, pos: (${x.toStringAsFixed(0)}, ${y.toStringAsFixed(0)}))';
  }
}
