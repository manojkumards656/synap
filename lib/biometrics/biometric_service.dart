import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../models/biometric_snapshot.dart';
import '../models/touch_event.dart';
import 'cdi_scorer.dart';
import 'feature_extractor.dart';
import 'touch_buffer.dart';

class BiometricService extends ChangeNotifier {
  final TouchBuffer _buffer = TouchBuffer();
  final FeatureExtractor _extractor = FeatureExtractor();
  final CDIScorer _scorer = CDIScorer();

  bool _isCallActive = false;
  BiometricSnapshot _currentSnapshot = BiometricSnapshot.initial();
  double _currentCDI = 0.0;

  bool get isCallActive => _isCallActive;
  BiometricSnapshot get currentSnapshot => _currentSnapshot;
  double get currentCDI => _currentCDI;
  int get eventCount => _buffer.length;
  List<TouchEvent> get rawEvents => _buffer.events;

  /// Updates telephony state from CallStateService
  void updateCallState(bool active) {
    if (_isCallActive != active) {
      _isCallActive = active;
      _recompute();
    }
  }

  /// Ingests a new touch event from the UI
  void recordTouch(TouchEvent event) {
    _buffer.add(event);
    _recompute();
  }

  /// Recomputes behavioral features and updates CDI
  void _recompute() {
    final events = _buffer.events;
    if (events.length < 2) {
      _currentSnapshot = BiometricSnapshot.initial();
      _currentCDI = _isCallActive ? CDIConstants.wCallActive : 0.0;
      notifyListeners();
      return;
    }

    _currentSnapshot = _extractor.extract(
      events: events,
      isCallActive: _isCallActive,
    );
    _currentCDI = _scorer.computeCDI(_currentSnapshot);
    notifyListeners();
  }

  /// Evaluates risk decision for a transaction amount
  TransactionDecision evaluateTransaction(double amount) {
    return _scorer.evaluateDecision(
      cdi: _currentCDI,
      isCallActive: _isCallActive,
      amount: amount,
    );
  }

  /// Clears current session buffer for a fresh transaction
  void resetSession() {
    _buffer.clear();
    _currentSnapshot = BiometricSnapshot.initial();
    _currentCDI = _isCallActive ? CDIConstants.wCallActive : 0.0;
    notifyListeners();
  }

  /// Optional debug helper to pre-fill simulated duress or calm patterns for testing
  void simulatePattern({required bool underDuress, required bool callActive}) {
    resetSession();
    _isCallActive = callActive;

    var currentT = 1000000; // microseconds

    final count = underDuress ? 18 : 16;
    for (int i = 0; i < count; i++) {
      int dwellUs;
      int flightUs;
      double px = 100.0 + (i % 3) * 80.0;
      double py = 400.0 + (i ~/ 3) * 60.0;

      if (underDuress) {
        // Dictation pauses (2.5s) alternating with frantic bursts (80ms)
        flightUs = (i % 4 == 0) ? 2600000 : (i % 2 == 0 ? 85000 : 450000);
        dwellUs = (120000 + (i * 37000) % 280000);
        // Chaotic spatial jitter
        px += ((i * 31) % 40) - 20;
        py += ((i * 17) % 40) - 20;
      } else {
        // Steady, rhythmic typing
        flightUs = 280000 + ((i * 13) % 40000);
        dwellUs = 95000 + ((i * 7) % 20000);
      }

      currentT += flightUs;
      final downEvent = TouchEvent(
        timestampUs: currentT,
        x: px,
        y: py,
        pressure: 0.7,
        type: TouchType.down,
        keyLabel: '${(i % 9) + 1}',
      );
      _buffer.add(downEvent);

      currentT += dwellUs;
      final upEvent = TouchEvent(
        timestampUs: currentT,
        x: px + 1.0,
        y: py + 1.0,
        pressure: 0.0,
        type: TouchType.up,
        keyLabel: '${(i % 9) + 1}',
        dwellTimeMs: dwellUs / 1000.0,
      );
      _buffer.add(upEvent);
    }

    _recompute();
  }
}
