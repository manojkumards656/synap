/// AegisKin Core Constants
class CDIConstants {
  // CDI Decision Thresholds
  static const double thresholdSafe = 0.30;       // Green zone (< 0.30)
  static const double thresholdElevated = 0.50;   // Yellow zone (0.30 - 0.50)
  static const double thresholdCritical = 0.70;   // Red zone (>= 0.70) -> Escrow trigger

  // CDI Feature Weights (Sum = 1.0)
  // Re-tuned: Active call is primary risk context; burst ratio detects panic rush
  static const double wCallActive = 0.35;        // 35% - Active telephony is primary duress context
  static const double wBurstRatio = 0.20;        // 20% - Panic typing rush / rapid cadence
  static const double wHesitationRatio = 0.15;   // 15% - Dictation listening pauses
  static const double wIciVariance = 0.15;       // 15% - Rhythm irregularity / broken cadence
  static const double wDwellStdDev = 0.10;       // 10% - Touch tremors / hold inconsistency
  static const double wCurvatureEntropy = 0.05;  // 5%  - Trajectory wavering

  // Buffer & Timing
  static const int bufferCapacity = 200;
  static const double hesitationThresholdMs = 900.0;  // > 900ms = hesitation pause while dictated to
  static const double burstThresholdMs = 350.0;       // < 350ms = rapid panic rush / fast typing
  static const int escrowDurationSeconds = 900;       // 15 minutes (15 * 60s)
  static const double highValueThreshold = 10000.0;   // ₹10,000 threshold for tiered intervention

  // Feature Normalization Caps
  static const double maxExpectedIciVarianceMs2 = 160000.0; // Max expected variance in ms^2 (std dev ~400ms)
  static const double maxExpectedDwellStdDevMs = 180.0;     // Max expected std dev in ms
}

/// Transaction Decision Outcome
enum TransactionDecision {
  clear,
  warnAndClear,
  escrow,
}
