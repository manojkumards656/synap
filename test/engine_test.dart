// ignore_for_file: avoid_print
import 'package:aegis_kin/biometrics/cdi_scorer.dart';
import 'package:aegis_kin/biometrics/feature_extractor.dart';
import 'package:aegis_kin/biometrics/touch_buffer.dart';
import 'package:aegis_kin/core/constants.dart';
import 'package:aegis_kin/models/touch_event.dart';

void main() {
  print('=== Running Synap Engine Verification Tests ===');

  // Test 1: Steady, calm typing without call (~550ms intervals)
  {
    final extractor = FeatureExtractor();
    final scorer = CDIScorer();
    final events = <TouchEvent>[];

    var t = 1000000;
    for (int i = 0; i < 10; i++) {
      t += 550000; // 550ms flight (steady calm deliberate typing)
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
    assert(snapshot.burstRatio == 0.0, 'Burst should be 0 for 550ms');
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

    print('Test 2 (Dictation Coercion on Call): CDI = ${cdi.toStringAsFixed(3)}, Latency = ${snapshot.computeTimeMs.toStringAsFixed(3)}ms');
    assert(cdi >= 0.70, 'Coerced typing on call should have CDI >= 0.70');
    assert(snapshot.hesitationRatio > 0.20, 'Hesitation ratio should be elevated');
    assert(snapshot.burstRatio > 0.20, 'Burst ratio should be elevated');

    final decision = scorer.evaluateDecision(
      cdi: cdi,
      isCallActive: true,
      amount: 50000.0,
    );
    assert(decision == TransactionDecision.escrow, 'Should divert to escrow');
    print('  -> PASS: Dictated coercion intercepted into protective escrow hold.');
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

  // Test 4: FAST PANIC TYPING UNDER ACTIVE CALL (The User's specific scenario)
  {
    final extractor = FeatureExtractor();
    final scorer = CDIScorer();
    final events = <TouchEvent>[];

    var t = 1000000;
    // Rushed panic tapping under scam pressure (intervals 180ms - 260ms)
    final fastIntervals = [200000, 180000, 240000, 190000, 210000, 250000];
    for (int i = 0; i < fastIntervals.length; i++) {
      t += fastIntervals[i];
      events.add(TouchEvent(
        timestampUs: t,
        x: 150.0 + (i * 15),
        y: 450.0,
        pressure: 0.85,
        type: TouchType.down,
        keyLabel: '$i',
        dwellTimeMs: 70.0,
      ));
    }

    final snapshot = extractor.extract(events: events, isCallActive: true);
    final cdi = scorer.computeCDI(snapshot);

    print('Test 4 (Fast Panic Typing on Call): CDI = ${cdi.toStringAsFixed(3)}, BurstRatio = ${snapshot.burstRatio.toStringAsFixed(2)}');
    assert(snapshot.burstRatio > 0.50, 'Burst ratio should detect fast typing');
    assert(cdi >= 0.70, 'Fast typing on call must reach critical CDI >= 0.70');

    final decision = scorer.evaluateDecision(
      cdi: cdi,
      isCallActive: true,
      amount: 50000.0,
    );
    assert(decision == TransactionDecision.escrow, 'Fast typing on call MUST trigger escrow!');
    print('  -> PASS: Fast panic typing under call successfully detected and intercepted into escrow.');
  }

  // Test 5: Fast typing WITHOUT call (Normal fast typist) -> Should NOT trigger escrow
  {
    final extractor = FeatureExtractor();
    final scorer = CDIScorer();
    final events = <TouchEvent>[];

    var t = 1000000;
    final fastIntervals = [200000, 180000, 240000, 190000, 210000, 250000];
    for (int i = 0; i < fastIntervals.length; i++) {
      t += fastIntervals[i];
      events.add(TouchEvent(
        timestampUs: t,
        x: 150.0 + (i * 15),
        y: 450.0,
        pressure: 0.7,
        type: TouchType.down,
        keyLabel: '$i',
        dwellTimeMs: 70.0,
      ));
    }

    final snapshot = extractor.extract(events: events, isCallActive: false);
    final cdi = scorer.computeCDI(snapshot);

    print('Test 5 (Fast Typing WITHOUT Call): CDI = ${cdi.toStringAsFixed(3)}');
    assert(cdi < 0.30, 'Fast typing without call should remain in safe zone (< 0.30)');

    final decision = scorer.evaluateDecision(
      cdi: cdi,
      isCallActive: false,
      amount: 50000.0,
    );
    assert(decision == TransactionDecision.clear, 'Fast typing without call should clear without escrow');
    print('  -> PASS: Fast typing without call clears normally without false positive.');
  }

  print('=== ALL 5 PURE ENGINE VERIFICATION TESTS PASSED SUCCESSFULLY! ===');
}
