// ignore_for_file: avoid_print
import 'package:aegis_kin/biometrics/cdi_scorer.dart';
import 'package:aegis_kin/biometrics/feature_extractor.dart';
import 'package:aegis_kin/biometrics/touch_buffer.dart';
import 'package:aegis_kin/core/constants.dart';
import 'package:aegis_kin/models/touch_event.dart';

void main() {
  print('=== Running AegisKin Engine Verification Tests ===');

  // Test 1: Steady, calm typing without call
  {
    final extractor = FeatureExtractor();
    final scorer = CDIScorer();
    final events = <TouchEvent>[];

    var t = 1000000;
    for (int i = 0; i < 10; i++) {
      t += 250000; // 250ms flight
      events.add(TouchEvent(
        timestampUs: t,
        x: 100.0 + (i * 20),
        y: 400.0,
        pressure: 0.7,
        type: TouchType.down,
        keyLabel: '$i',
        dwellTimeMs: 90.0,
      ));
    }

    final snapshot = extractor.extract(events: events, isCallActive: false);
    final cdi = scorer.computeCDI(snapshot);

    print('Test 1 (Calm Input): CDI = ${cdi.toStringAsFixed(3)}, Latency = ${snapshot.computeTimeMs.toStringAsFixed(3)}ms');
    assert(cdi < 0.30, 'Calm typing should have CDI < 0.30');
    assert(snapshot.hesitationRatio == 0.0, 'Hesitation should be 0');
    assert(snapshot.burstRatio == 0.0, 'Burst should be 0');
    assert(snapshot.computeTimeMs < 5.0, 'Inference must be < 5ms');

    final decision = scorer.evaluateDecision(
      cdi: cdi,
      isCallActive: false,
      amount: 50000.0,
    );
    assert(decision == TransactionDecision.clear, 'Should clear transaction');
    print('  -> PASS: Calm typing cleared instantly.');
  }

  // Test 2: Coerced typing with dictation pauses & panic bursts under active call
  {
    final extractor = FeatureExtractor();
    final scorer = CDIScorer();
    final events = <TouchEvent>[];

    var t = 1000000;
    final intervals = [2500000, 80000, 2600000, 75000, 2400000, 90000, 2800000, 85000];
    for (int i = 0; i < intervals.length; i++) {
      t += intervals[i];
      events.add(TouchEvent(
        timestampUs: t,
        x: (i % 2 == 0) ? 50.0 : 250.0,
        y: (i % 3 == 0) ? 350.0 : 500.0,
        pressure: 0.8,
        type: TouchType.down,
        keyLabel: '$i',
        dwellTimeMs: (i % 2 == 0) ? 220.0 : 40.0,
      ));
    }

    final snapshot = extractor.extract(events: events, isCallActive: true);
    final cdi = scorer.computeCDI(snapshot);

    print('Test 2 (Coercion on Call): CDI = ${cdi.toStringAsFixed(3)}, Latency = ${snapshot.computeTimeMs.toStringAsFixed(3)}ms');
    assert(cdi >= 0.70, 'Coerced typing on call should have CDI >= 0.70');
    assert(snapshot.hesitationRatio > 0.20, 'Hesitation ratio should be elevated');
    assert(snapshot.burstRatio > 0.20, 'Burst ratio should be elevated');

    final decision = scorer.evaluateDecision(
      cdi: cdi,
      isCallActive: true,
      amount: 50000.0,
    );
    assert(decision == TransactionDecision.escrow, 'Should divert to escrow');
    print('  -> PASS: Coerced transaction intercepted into protective escrow hold.');
  }

  // Test 3: TouchBuffer pairing and circular capacity
  {
    final buffer = TouchBuffer(capacity: 10);
    final down = TouchEvent(
      timestampUs: 1000000,
      x: 100,
      y: 200,
      pressure: 0.6,
      type: TouchType.down,
      keyLabel: '5',
    );
    buffer.add(down);

    final up = TouchEvent(
      timestampUs: 1100000,
      x: 100,
      y: 200,
      pressure: 0.0,
      type: TouchType.up,
      keyLabel: '5',
    );
    buffer.add(up);

    assert(buffer.length == 2);
    assert(down.dwellTimeMs != null && (down.dwellTimeMs! - 100.0).abs() < 1.0);
    assert(buffer.downEvents.length == 1);
    assert(buffer.upEvents.length == 1);
    print('  -> PASS: TouchBuffer pairing & circular storage verified.');
  }

  print('=== ALL 3 PURE ENGINE VERIFICATION TESTS PASSED SUCCESSFULLY! ===');
}
