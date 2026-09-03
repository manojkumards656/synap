import '../core/constants.dart';
import '../models/biometric_snapshot.dart';

class CDIScorer {
  /// Computes the final Cognitive Duress Index (CDI).
  /// Pure mathematical execution in < 0.05ms.
  double computeCDI(BiometricSnapshot snapshot) {
    final rawScore = (CDIConstants.wIciVariance * snapshot.iciVariance) +
        (CDIConstants.wDwellStdDev * snapshot.dwellStdDev) +
        (CDIConstants.wCurvatureEntropy * snapshot.curvatureEntropy) +
        (CDIConstants.wHesitationRatio * snapshot.hesitationRatio) +
        (CDIConstants.wBurstRatio * snapshot.burstRatio) +
        (CDIConstants.wCallActive * snapshot.callActive);

    return rawScore.clamp(0.0, 1.0);
  }

  /// Tiered fraud interception decision logic.
  /// Protects high-value transfers during active calls without locking out ordinary users.
  TransactionDecision evaluateDecision({
    required double cdi,
    required bool isCallActive,
    required double amount,
  }) {
    // Scenario 1: Extreme Duress under active call -> Immediate 15-min Escrow
    if (cdi >= CDIConstants.thresholdCritical && isCallActive) {
      return TransactionDecision.escrow;
    }

    // Scenario 2: Elevated Duress on high-value transfer (>₹10,000) under active call
    if (cdi >= CDIConstants.thresholdElevated &&
        isCallActive &&
        amount >= CDIConstants.highValueThreshold) {
      return TransactionDecision.escrow;
    }

    // Scenario 3: Elevated Duress without active call (e.g. walking, trembling elderly user)
    // or low duress during friendly casual call with lower amount
    if (cdi >= CDIConstants.thresholdSafe || isCallActive) {
      return TransactionDecision.warnAndClear;
    }

    // Scenario 4: Calm, normal daily banking -> Instant Real-Time Settlement
    return TransactionDecision.clear;
  }
}
