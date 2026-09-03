import 'dart:math';
import '../core/constants.dart';
import '../models/biometric_snapshot.dart';
import '../models/touch_event.dart';

class FeatureExtractor {
  /// Extracts 6 normalized behavioral features from a stream of TouchEvents.
  /// Execution time is typically < 0.3 ms on standard mobile hardware.
  BiometricSnapshot extract({
    required List<TouchEvent> events,
    required bool isCallActive,
  }) {
    final stopwatch = Stopwatch()..start();

    final downEvents = events.where((e) => e.type == TouchType.down).toList();
    final sampleCount = downEvents.length;

    if (sampleCount < 2) {
      stopwatch.stop();
      return BiometricSnapshot.initial();
    }

    // 1. Inter-Character Intervals (ICI)
    final icis = <double>[];
    int hesitationCount = 0;
    int burstCount = 0;

    for (int i = 0; i < sampleCount - 1; i++) {
      final dt = downEvents[i + 1].timestampMs - downEvents[i].timestampMs;
      if (dt > 0) {
        icis.add(dt);
        if (dt >= CDIConstants.hesitationThresholdMs) {
          hesitationCount++;
        } else if (dt <= CDIConstants.burstThresholdMs) {
          burstCount++;
        }
      }
    }

    final totalIciCount = icis.length;
    double rawIciVariance = 0.0;
    double normalizedIciVariance = 0.0;
    double hesitationRatio = 0.0;
    double burstRatio = 0.0;

    if (totalIciCount > 0) {
      final meanIci = icis.reduce((a, b) => a + b) / totalIciCount;
      final sumSquaredDiffs = icis.fold<double>(
        0.0,
        (sum, val) => sum + pow(val - meanIci, 2),
      );
      rawIciVariance = sumSquaredDiffs / totalIciCount;
      normalizedIciVariance = (rawIciVariance / CDIConstants.maxExpectedIciVarianceMs2)
          .clamp(0.0, 1.0);

      hesitationRatio = (hesitationCount / totalIciCount).clamp(0.0, 1.0);
      burstRatio = (burstCount / totalIciCount).clamp(0.0, 1.0);
    }

    // 2. Dwell Times
    final dwells = <double>[];
    for (final ev in downEvents) {
      if (ev.dwellTimeMs != null && ev.dwellTimeMs! > 0) {
        dwells.add(ev.dwellTimeMs!);
      }
    }

    double rawDwellStdDev = 0.0;
    double normalizedDwellStdDev = 0.0;
    if (dwells.length >= 2) {
      final meanDwell = dwells.reduce((a, b) => a + b) / dwells.length;
      final sumSq = dwells.fold<double>(
        0.0,
        (sum, val) => sum + pow(val - meanDwell, 2),
      );
      rawDwellStdDev = sqrt(sumSq / dwells.length);
      normalizedDwellStdDev = (rawDwellStdDev / CDIConstants.maxExpectedDwellStdDevMs)
          .clamp(0.0, 1.0);
    }

    // 3. Pointer Trajectory Curvature Entropy
    double curvatureEntropy = 0.0;
    if (sampleCount >= 3) {
      curvatureEntropy = _computeCurvatureEntropy(downEvents);
    }

    // 4. Telephony Status
    final callValue = isCallActive ? 1.0 : 0.0;

    // 5. Provisional CDI calculation
    final cdi = (CDIConstants.wIciVariance * normalizedIciVariance) +
        (CDIConstants.wDwellStdDev * normalizedDwellStdDev) +
        (CDIConstants.wCurvatureEntropy * curvatureEntropy) +
        (CDIConstants.wHesitationRatio * hesitationRatio) +
        (CDIConstants.wBurstRatio * burstRatio) +
        (CDIConstants.wCallActive * callValue);

    stopwatch.stop();
    final elapsedMs = stopwatch.elapsedMicroseconds / 1000.0;

    return BiometricSnapshot(
      iciVariance: normalizedIciVariance,
      rawIciVariance: rawIciVariance,
      dwellStdDev: normalizedDwellStdDev,
      rawDwellStdDev: rawDwellStdDev,
      curvatureEntropy: curvatureEntropy,
      hesitationRatio: hesitationRatio,
      burstRatio: burstRatio,
      callActive: callValue,
      cdiScore: cdi.clamp(0.0, 1.0),
      sampleCount: sampleCount,
      computeTimeMs: elapsedMs,
    );
  }

  /// Computes Shannon entropy of angle changes across successive 2D touch down points.
  /// High entropy indicates wavering, erratic trajectories typical of motor tremor/duress.
  double _computeCurvatureEntropy(List<TouchEvent> points) {
    const int binCount = 8;
    final bins = List<int>.filled(binCount, 0);
    int totalAngles = 0;

    for (int i = 0; i < points.length - 2; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final p2 = points[i + 2];

      final dx1 = p1.x - p0.x;
      final dy1 = p1.y - p0.y;
      final dx2 = p2.x - p1.x;
      final dy2 = p2.y - p1.y;

      final dist1 = sqrt(dx1 * dx1 + dy1 * dy1);
      final dist2 = sqrt(dx2 * dx2 + dy2 * dy2);

      // Skip negligible finger tremors on the exact same key to avoid math singularities
      if (dist1 < 2.0 || dist2 < 2.0) continue;

      final angle1 = atan2(dy1, dx1);
      final angle2 = atan2(dy2, dx2);
      var deltaAngle = angle2 - angle1;

      // Wrap to [-pi, pi]
      while (deltaAngle > pi) {
        deltaAngle -= 2 * pi;
      }
      while (deltaAngle < -pi) {
        deltaAngle += 2 * pi;
      }

      // Map [-pi, pi] to [0, binCount - 1]
      final normalizedAngle = (deltaAngle + pi) / (2 * pi); // [0.0, 1.0]
      final binIndex = (normalizedAngle * binCount).floor().clamp(0, binCount - 1);
      bins[binIndex]++;
      totalAngles++;
    }

    if (totalAngles == 0) return 0.0;

    // Shannon Entropy: H = - sum(p * log2(p))
    double entropy = 0.0;
    for (int count in bins) {
      if (count > 0) {
        final p = count / totalAngles;
        entropy -= p * (log(p) / ln2);
      }
    }

    // Max entropy for 8 bins = log2(8) = 3.0
    const maxEntropy = 3.0;
    return (entropy / maxEntropy).clamp(0.0, 1.0);
  }
}
