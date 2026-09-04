class BiometricSnapshot {
  final double iciVariance;
  final double rawIciVariance;
  final double dwellStdDev;
  final double rawDwellStdDev;
  final double curvatureEntropy;
  final double hesitationRatio;
  final double burstRatio;
  final double callActive;
  final double cdiScore;
  final int sampleCount;
  final double computeTimeMs;
  final DateTime timestamp;

  BiometricSnapshot({
    required this.iciVariance,
    required this.rawIciVariance,
    required this.dwellStdDev,
    required this.rawDwellStdDev,
    required this.curvatureEntropy,
    required this.hesitationRatio,
    required this.burstRatio,
    required this.callActive,
    required this.cdiScore,
    required this.sampleCount,
    required this.computeTimeMs,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory BiometricSnapshot.initial() {
    return BiometricSnapshot(
      iciVariance: 0.0,
      rawIciVariance: 0.0,
      dwellStdDev: 0.0,
      rawDwellStdDev: 0.0,
      curvatureEntropy: 0.0,
      hesitationRatio: 0.0,
      burstRatio: 0.0,
      callActive: 0.0,
      cdiScore: 0.0,
      sampleCount: 0,
      computeTimeMs: 0.0,
    );
  }

  /// List of human-readable warnings for elevated signals
  List<String> get activeDuressFlags {
    final flags = <String>[];
    if (callActive > 0.5) flags.add('Active cellular call detected during transfer');
    if (burstRatio > 0.25) flags.add('Frantic panic rush typing (<350ms per key)');
    if (hesitationRatio > 0.20) flags.add('Abnormal dictation listening pauses (>0.9s)');
    if (iciVariance > 0.35) flags.add('Irregular cadence & flight variability');
    if (dwellStdDev > 0.35) flags.add('High dwell time tremor / finger inconsistency');
    if (curvatureEntropy > 0.45) flags.add('Chaotic pointer trajectory & wavering');
    return flags;
  }
}
