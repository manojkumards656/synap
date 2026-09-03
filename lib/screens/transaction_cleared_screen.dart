import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/biometric_snapshot.dart';

class TransactionClearedScreen extends StatelessWidget {
  final double amount;
  final String recipientIban;
  final BiometricSnapshot snapshot;
  final TransactionDecision decision;

  const TransactionClearedScreen({
    super.key,
    required this.amount,
    required this.recipientIban,
    required this.snapshot,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##,###.##', 'en_IN');
    final formattedAmount = currencyFormat.format(amount);

    final isWarn = decision == TransactionDecision.warnAndClear;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(),
              // Checkmark Circle
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: (isWarn ? AegisTheme.statusElevated : AegisTheme.statusSafe)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isWarn ? AegisTheme.statusElevated : AegisTheme.statusSafe,
                    width: 3,
                  ),
                ),
                child: Icon(
                  isWarn ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  size: 52,
                  color: isWarn ? AegisTheme.statusElevated : AegisTheme.statusSafe,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isWarn ? 'Transfer Cleared with Caution' : 'Transfer Successfully Settled',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AegisTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Funds cleared via Real-Time Settlement Rails',
                style: TextStyle(
                  fontSize: 13,
                  color: isWarn ? AegisTheme.statusElevated : AegisTheme.statusSafe,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              // Transaction Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AegisTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AegisTheme.surfaceBorder),
                ),
                child: Column(
                  children: [
                    _buildRow('Amount Transferred', '₹ $formattedAmount', isBold: true),
                    const Divider(color: AegisTheme.surfaceBorder, height: 24),
                    _buildRow('Recipient Account', recipientIban, isMonospace: true),
                    const Divider(color: AegisTheme.surfaceBorder, height: 24),
                    _buildRow('Settlement Speed', '< 1 second (Instant)'),
                    const Divider(color: AegisTheme.surfaceBorder, height: 24),
                    _buildRow('Cognitive Duress Index (CDI)', '${snapshot.cdiScore.toStringAsFixed(2)} / 1.00'),
                    const Divider(color: AegisTheme.surfaceBorder, height: 24),
                    _buildRow('Biometrics Engine Latency', '${snapshot.computeTimeMs.toStringAsFixed(2)} ms'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Security Audit Note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AegisTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: AegisTheme.textSecondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Audit Log ID: #SYNP-84920 | Zero-PII cryptographically verified',
                        style: TextStyle(fontSize: 10, color: AegisTheme.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AegisTheme.surfaceLight,
                    foregroundColor: AegisTheme.textPrimary,
                    side: const BorderSide(color: AegisTheme.surfaceBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                  child: const Text(
                    'Return to Dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, bool isMonospace = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AegisTheme.textSecondary),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontFamily: isMonospace ? 'monospace' : null,
              color: isBold ? AegisTheme.statusSafe : AegisTheme.textPrimary,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
