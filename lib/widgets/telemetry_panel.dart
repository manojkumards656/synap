import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../biometrics/biometric_service.dart';
import '../core/theme.dart';
import '../telephony/call_state_service.dart';

class TelemetryPanel extends StatefulWidget {
  const TelemetryPanel({super.key});

  @override
  State<TelemetryPanel> createState() => _TelemetryPanelState();
}

class _TelemetryPanelState extends State<TelemetryPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bioService = context.watch<BiometricService>();
    final callService = context.watch<CallStateService>();
    final snapshot = bioService.currentSnapshot;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AegisTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AegisTheme.surfaceBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.biotech_outlined,
                    size: 18,
                    color: AegisTheme.primaryCyan,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'LIVE BIOMETRIC TELEMETRY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AegisTheme.textPrimary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AegisTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${snapshot.computeTimeMs.toStringAsFixed(2)}ms',
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: AegisTheme.statusSafe,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: AegisTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(color: AegisTheme.surfaceBorder, height: 1),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetricRow(
                    'ICI Variance (Rhythm)',
                    '${snapshot.rawIciVariance.toStringAsFixed(0)} ms²',
                    snapshot.iciVariance,
                  ),
                  const SizedBox(height: 8),
                  _buildMetricRow(
                    'Dwell Std Dev (Press Consistency)',
                    '${snapshot.rawDwellStdDev.toStringAsFixed(1)} ms',
                    snapshot.dwellStdDev,
                  ),
                  const SizedBox(height: 8),
                  _buildMetricRow(
                    'Curvature Entropy (Trajectory)',
                    'H = ${snapshot.curvatureEntropy.toStringAsFixed(3)}',
                    snapshot.curvatureEntropy,
                  ),
                  const SizedBox(height: 8),
                  _buildMetricRow(
                    'Hesitation Ratio (>2.0s dictation)',
                    '${(snapshot.hesitationRatio * 100).toStringAsFixed(0)}%',
                    snapshot.hesitationRatio,
                  ),
                  const SizedBox(height: 8),
                  _buildMetricRow(
                    'Burst Ratio (<120ms panic)',
                    '${(snapshot.burstRatio * 100).toStringAsFixed(0)}%',
                    snapshot.burstRatio,
                  ),
                  const SizedBox(height: 8),
                  _buildMetricRow(
                    'Active Call Amplifier',
                    bioService.isCallActive ? 'TRUE (+0.20)' : 'FALSE (0.0)',
                    bioService.isCallActive ? 1.0 : 0.0,
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AegisTheme.surfaceBorder, height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Samples: ${snapshot.sampleCount} events',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AegisTheme.textMuted,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Text(
                        'Zero-PII Engine',
                        style: TextStyle(
                          fontSize: 11,
                          color: AegisTheme.primaryCyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Quick Preset Testing Buttons for Demo
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AegisTheme.statusSafe),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () {
                            callService.setSimulatedCall(false);
                            bioService.simulatePattern(
                              underDuress: false,
                              callActive: false,
                            );
                          },
                          child: const Text(
                            'Sim Calm',
                            style: TextStyle(fontSize: 11, color: AegisTheme.statusSafe),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AegisTheme.statusCritical),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () {
                            callService.setSimulatedCall(true);
                            bioService.simulatePattern(
                              underDuress: true,
                              callActive: true,
                            );
                          },
                          child: const Text(
                            'Sim Duress',
                            style: TextStyle(fontSize: 11, color: AegisTheme.statusCritical),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Reset Buffer',
                        icon: const Icon(Icons.refresh, size: 18),
                        onPressed: () => bioService.resetSession(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String valueStr, double normalized) {
    Color barColor = AegisTheme.statusSafe;
    if (normalized >= 0.6) {
      barColor = AegisTheme.statusCritical;
    } else if (normalized >= 0.3) {
      barColor = AegisTheme.statusElevated;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AegisTheme.textSecondary,
              ),
            ),
            Text(
              valueStr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        LinearProgressIndicator(
          value: normalized.clamp(0.0, 1.0),
          backgroundColor: AegisTheme.surfaceLight,
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }
}
