import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../biometrics/biometric_service.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../telephony/call_state_service.dart';
import '../widgets/cdi_gauge.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bioService = context.watch<BiometricService>();
    final callService = context.watch<CallStateService>();
    final snapshot = bioService.currentSnapshot;
    final cdi = bioService.currentCDI;

    final decision = bioService.evaluateTransaction(50000);
    final decisionLabel = decision == TransactionDecision.escrow
        ? '15-MIN ESCROW INTERCEPT'
        : decision == TransactionDecision.warnAndClear
            ? 'WARN & STEP-UP'
            : 'INSTANT SETTLEMENT';

    final decisionColor = decision == TransactionDecision.escrow
        ? SynapTheme.statusCritical
        : decision == TransactionDecision.warnAndClear
            ? SynapTheme.statusElevated
            : SynapTheme.statusSafe;

    return Scaffold(
      backgroundColor: const Color(0xFF090D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F141F),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Synap Fraud Operations Console',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Enterprise SOC • Real-Time APP Coercion Telemetry',
              style: TextStyle(fontSize: 11, color: SynapTheme.primaryCyan),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Buffer',
            onPressed: () => bioService.resetSession(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131A29),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SynapTheme.surfaceBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: decisionColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.security, color: decisionColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SYSTEM INTERVENTION LEVEL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: SynapTheme.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          decisionLabel,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: decisionColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Telemetry Latency: ${snapshot.computeTimeMs.toStringAsFixed(2)} ms • Zero-PII Protected',
                          style: const TextStyle(fontSize: 11, color: SynapTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Live CDI Gauge with Math Readout
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SynapTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SynapTheme.surfaceBorder),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'REAL-TIME CDI CALCULATION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: SynapTheme.textPrimary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Formula: Σ (wᵢ · fᵢ)',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: SynapTheme.primaryCyan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CDIGauge(cdiValue: cdi),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SynapTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weighted Scoring Equation:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SynapTheme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'CDI = (0.15 × ${(snapshot.iciVariance).toStringAsFixed(2)}) + '
                          '(0.10 × ${(snapshot.dwellStdDev).toStringAsFixed(2)}) + '
                          '(0.05 × ${(snapshot.curvatureEntropy).toStringAsFixed(2)}) + '
                          '(0.15 × ${(snapshot.hesitationRatio).toStringAsFixed(2)}) + '
                          '(0.20 × ${(snapshot.burstRatio).toStringAsFixed(2)}) + '
                          '(0.35 × ${bioService.isCallActive ? "1.00" : "0.00"})${bioService.isCallActive && snapshot.burstRatio > 0.30 ? " + Panic Boost" : ""} = ${cdi.toStringAsFixed(3)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: SynapTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Deep Signal Breakdown
            const Text(
              'Biometric Signals Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: SynapTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            _buildSignalCard(
              title: 'Flight Interval Variance (ICI)',
              weight: 'Weight: 15%',
              rawValue: '${snapshot.rawIciVariance.toStringAsFixed(0)} ms²',
              normalized: snapshot.iciVariance,
              description: 'Measures typing rhythm irregularities caused by listening to dictation over phone.',
            ),
            _buildSignalCard(
              title: 'Key Dwell Time Std Dev',
              weight: 'Weight: 10%',
              rawValue: '${snapshot.rawDwellStdDev.toStringAsFixed(1)} ms',
              normalized: snapshot.dwellStdDev,
              description: 'Measures key-press duration tremors and stress-induced motor hesitation.',
            ),
            _buildSignalCard(
              title: 'Pointer Trajectory Curvature Entropy',
              weight: 'Weight: 5%',
              rawValue: 'H = ${snapshot.curvatureEntropy.toStringAsFixed(3)} / 3.0',
              normalized: snapshot.curvatureEntropy,
              description: 'Shannon entropy across directional angles between consecutive taps. High = chaotic zigzag.',
            ),
            _buildSignalCard(
              title: 'Hesitation Ratio (>0.9s pauses)',
              weight: 'Weight: 15%',
              rawValue: '${(snapshot.hesitationRatio * 100).toStringAsFixed(0)}% of taps',
              normalized: snapshot.hesitationRatio,
              description: 'Detects prolonged delays while the victim waits for the fraudster\'s next instruction.',
            ),
            _buildSignalCard(
              title: 'Panic Burst / Fast Rush Ratio (<350ms)',
              weight: 'Weight: 20%',
              rawValue: '${(snapshot.burstRatio * 100).toStringAsFixed(0)}% rush',
              normalized: snapshot.burstRatio,
              description: 'Detects frantic keystroke bursts and accelerated typing under live phone pressure.',
            ),
            _buildSignalCard(
              title: 'Active Voice Call Telephony Flag',
              weight: 'Weight: 35%',
              rawValue: bioService.isCallActive ? 'CALL ACTIVE (True)' : 'IDLE (False)',
              normalized: bioService.isCallActive ? 1.0 : 0.0,
              description: 'Verified via Android TelephonyManager/PhoneState. Acts as the primary coercion context.',
            ),
            const SizedBox(height: 20),

            // Demo Injection Controls
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: SynapTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: SynapTheme.primaryBlue.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune, color: SynapTheme.primaryCyan, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Judge & Analyst Test Controls',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: SynapTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SynapTheme.statusSafe,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            callService.setSimulatedCall(false);
                            bioService.simulatePattern(underDuress: false, callActive: false);
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('Simulate Calm User'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SynapTheme.statusCritical,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            callService.setSimulatedCall(true);
                            bioService.simulatePattern(underDuress: true, callActive: true);
                          },
                          icon: const Icon(Icons.warning_amber_rounded, size: 18),
                          label: const Text('Simulate Coercion'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: SynapTheme.textPrimary,
                            side: const BorderSide(color: SynapTheme.surfaceBorder),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () {
                            final next = !(callService.isCallActive);
                            callService.setSimulatedCall(next);
                          },
                          icon: Icon(
                            callService.isCallActive ? Icons.call_end : Icons.call,
                            size: 18,
                            color: callService.isCallActive ? SynapTheme.statusCritical : SynapTheme.statusSafe,
                          ),
                          label: Text(
                            callService.isCallActive ? 'Force Call Idle' : 'Force Call Active',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SynapTheme.textSecondary,
                          side: const BorderSide(color: SynapTheme.surfaceBorder),
                        ),
                        onPressed: () {
                          callService.setSimulatedCall(null);
                          bioService.resetSession();
                        },
                        child: const Text('Reset All', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Raw Events Inspector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SynapTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SynapTheme.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RAW TOUCHSTREAM (ZERO PII)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: SynapTheme.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '${bioService.rawEvents.length} events buffered',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: SynapTheme.primaryCyan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (bioService.rawEvents.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Touch buffer empty. Type on the transfer screen keypad or tap a simulation button above.',
                        style: TextStyle(fontSize: 12, color: SynapTheme.textMuted),
                      ),
                    )
                  else
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFF090D14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                        itemCount: bioService.rawEvents.length > 10 ? 10 : bioService.rawEvents.length,
                        itemBuilder: (ctx, i) {
                          final e = bioService.rawEvents[bioService.rawEvents.length - 1 - i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            child: Text(
                              '#$i ${e.type.name.toUpperCase().padRight(4)} '
                              't:${e.timestampMs.toStringAsFixed(0)}ms '
                              'pos:(${e.x.toStringAsFixed(0)}, ${e.y.toStringAsFixed(0)}) '
                              'dwell:${e.dwellTimeMs?.toStringAsFixed(1) ?? "-"}ms '
                              'key:${e.keyLabel ?? "-"}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: SynapTheme.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalCard({
    required String title,
    required String weight,
    required String rawValue,
    required double normalized,
    required String description,
  }) {
    Color barColor = SynapTheme.statusSafe;
    if (normalized >= 0.6) {
      barColor = SynapTheme.statusCritical;
    } else if (normalized >= 0.3) {
      barColor = SynapTheme.statusElevated;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SynapTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SynapTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: SynapTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: SynapTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  weight,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SynapTheme.primaryCyan),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 11, color: SynapTheme.textMuted),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Raw value: $rawValue',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: SynapTheme.textSecondary),
              ),
              Text(
                'Norm: ${(normalized * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: normalized.clamp(0.0, 1.0),
            backgroundColor: SynapTheme.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}
