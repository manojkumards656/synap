/// AegisKin Core Constants
class CDIConstants {
  // CDI Thresholds
  static const double thresholdSafe = 0.30;       // Green zone (< 0.30)
  static const double thresholdElevated = 0.55;   // Yellow zone (0.30 - 0.55)
  static const double thresholdCritical = 0.75;   // Red zone (>= 0.75) -> Escrow trigger

  // CDI Feature Weights (Sum = 1.0)
  // Tuned for high contrast between calm input vs dictated coercion
  static const double wIciVariance = 0.20;
  static const double wDwellStdDev = 0.15;
  static const double wCurvatureEntropy = 0.15;
  static const double wHesitationRatio = 0.20;
  static const double wBurstRatio = 0.10;
  static const double wCallActive = 0.20;

  // Buffer & Timing
  static const int bufferCapacity = 200;
  static const double hesitationThresholdMs = 2000.0; // > 2s between keypresses = dictation pause
  static const double burstThresholdMs = 120.0;        // < 120ms = rapid panic burst
  static const int escrowDurationSeconds = 900;       // 15 minutes (15 * 60s)
  static const double highValueThreshold = 10000.0;   // ₹10,000 threshold for tiered intervention

  // Feature Normalization Caps
  static const double maxExpectedIciVarianceMs2 = 2500000.0; // Max expected variance in ms^2
  static const double maxExpectedDwellStdDevMs = 350.0;       // Max expected std dev in ms
}

/// Transaction Decision Outcome
enum TransactionDecision {
  clear,
  warnAndClear,
  escrow,
}
