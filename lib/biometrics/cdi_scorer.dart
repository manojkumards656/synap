import '../core/constants.dart';
import '../models/biometric_snapshot.dart';

class CDIScorer {
  /// Computes the final Cognitive Duress Index (CDI).
  /// Pure mathematical execution in < 0.05ms.
  double computeCDI(BiometricSnapshot snapshot) {
    double rawScore = (CDIConstants.wIciVariance * snapshot.iciVariance) +
        (CDIConstants.wDwellStdDev * snapshot.dwellStdDev) +
        (CDIConstants.wCurvatureEntropy * snapshot.curvatureEntropy) +
        (CDIConstants.wHesitationRatio * snapshot.hesitationRatio) +
        (CDIConstants.wBurstRatio * snapshot.burstRatio) +
        (CDIConstants.wCallActive * snapshot.callActive);

    // Dynamic Coercion Synergy Multiplier:
    // If the user is on an active phone call AND exhibits panic rush (fast typing)
    // or dictation pauses (hesitation), amplify the score.
    // This captures the exact physiological distress of someone being pressured on a call.
    if (snapshot.callActive > 0.5) {
      if (snapshot.burstRatio > 0.30) {
        rawScore += 0.25 * snapshot.burstRatio;
      }
      if (snapshot.hesitationRatio > 0.15) {
        rawScore += 0.20 * snapshot.hesitationRatio;
      }
    }

    return rawScore.clamp(0.0, 1.0);
  }

  /// Tiered fraud interception decision logic.
  /// Protects high-value transfers during active calls without locking out ordinary users.
  TransactionDecision evaluateDecision({
    required double cdi,
    required bool isCallActive,
    required double amount,
  }) {
    // Scenario 1: Critical Duress under active call -> Immediate 15-min Escrow
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
