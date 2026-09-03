import 'package:flutter_test/flutter_test.dart';
import 'package:aegis_kin/biometrics/biometric_service.dart';
import 'package:aegis_kin/biometrics/cdi_scorer.dart';
import 'package:aegis_kin/biometrics/feature_extractor.dart';
import 'package:aegis_kin/biometrics/touch_buffer.dart';
import 'package:aegis_kin/core/constants.dart';
import 'package:aegis_kin/models/touch_event.dart';
import 'package:aegis_kin/app.dart';

void main() {
  group('AegisKin Biometrics & CDI Engine Tests', () {
    test('Steady, calm typing without phone call yields low CDI (<0.30)', () {
      final extractor = FeatureExtractor();
      final scorer = CDIScorer();
      final events = <TouchEvent>[];

      var t = 1000000;
      // 10 steady keystrokes with ~250ms cadence and ~90ms dwell
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

      expect(cdi, lessThan(0.30));
      expect(snapshot.hesitationRatio, equals(0.0));
      expect(snapshot.burstRatio, equals(0.0));
      expect(snapshot.computeTimeMs, lessThan(5.0)); // Ultra-low latency < 5ms requirement

      final decision = scorer.evaluateDecision(
        cdi: cdi,
        isCallActive: false,
        amount: 50000.0,
      );
      expect(decision, equals(TransactionDecision.clear));
    });

    test('Coerced typing with dictation pauses and panic bursts under active call triggers Escrow (CDI >= 0.75)', () {
      final extractor = FeatureExtractor();
      final scorer = CDIScorer();
      final events = <TouchEvent>[];

      var t = 1000000;
      // Irregular dictation pattern: long 2.5s pauses alternating with frantic 80ms bursts
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

      expect(cdi, greaterThanOrEqualTo(0.70));
      expect(snapshot.hesitationRatio, greaterThan(0.20));
      expect(snapshot.burstRatio, greaterThan(0.20));

      final decision = scorer.evaluateDecision(
        cdi: cdi,
        isCallActive: true,
        amount: 50000.0,
      );
      expect(decision, equals(TransactionDecision.escrow));
    });

    test('TouchBuffer correctly circularizes and pairs dwell times', () {
      final buffer = TouchBuffer(capacity: 10);
      expect(buffer.length, equals(0));

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
        timestampUs: 1100000, // 100ms later
        x: 100,
        y: 200,
        pressure: 0.0,
        type: TouchType.up,
        keyLabel: '5',
      );
      buffer.add(up);

      expect(buffer.length, equals(2));
      expect(down.dwellTimeMs, closeTo(100.0, 1.0));
      expect(buffer.downEvents.length, equals(1));
      expect(buffer.upEvents.length, equals(1));
    });

    test('BiometricService simulation updates state correctly', () {
      final service = BiometricService();
      expect(service.currentCDI, equals(0.0));

      service.simulatePattern(underDuress: true, callActive: true);
      expect(service.currentCDI, greaterThanOrEqualTo(0.70));
      expect(service.isCallActive, isTrue);

      final decision = service.evaluateTransaction(50000.0);
      expect(decision, equals(TransactionDecision.escrow));
    });
  });

  testWidgets('SynapApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SynapApp());
    await tester.pumpAndSettle();

    // Verify presence of title and key banking elements
    expect(find.text('Synap Guardian'), findsOneWidget);
    expect(find.text('Transfer Funds (Live Demo)'), findsOneWidget);
    expect(find.text('Total Balance'), findsOneWidget);
  });
}
