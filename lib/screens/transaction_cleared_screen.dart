import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/biometric_snapshot.dart';
import 'admin_screen.dart';

class TransactionClearedScreen extends StatelessWidget {
  final double amount;
  final String recipientIban;
  final String recipientName;
  final BiometricSnapshot snapshot;
  final TransactionDecision decision;

  const TransactionClearedScreen({
    super.key,
    required this.amount,
    required this.recipientIban,
    this.recipientName = 'Beneficiary',
    required this.snapshot,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##,###.##', 'en_IN');
    final formattedAmount = currencyFormat.format(amount);

    final isWarn = decision == TransactionDecision.warnAndClear;

    return Scaffold(
      backgroundColor: SynapTheme.background,
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
                  color: (isWarn ? SynapTheme.statusElevated : SynapTheme.statusSafe)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isWarn ? SynapTheme.statusElevated : SynapTheme.statusSafe,
                    width: 3,
                  ),
                ),
                child: Icon(
                  isWarn ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  size: 52,
                  color: isWarn ? SynapTheme.statusElevated : SynapTheme.statusSafe,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isWarn ? 'Payment Cleared with Step-Up' : 'Payment Successfully Sent',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: SynapTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Settled via Real-Time UPI / IMPS Banking Rails',
                style: TextStyle(
                  fontSize: 14,
                  color: isWarn ? SynapTheme.statusElevated : SynapTheme.statusSafe,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),
              // Transaction Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SynapTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SynapTheme.surfaceBorder),
                ),
                child: Column(
                  children: [
                    _buildRow('Amount Transferred', '₹ $formattedAmount', isBold: true),
                    const Divider(color: SynapTheme.surfaceBorder, height: 22),
                    _buildRow('Recipient', recipientName),
                    const Divider(color: SynapTheme.surfaceBorder, height: 22),
                    _buildRow('UPI ID / Account', recipientIban, isMonospace: true),
                    const Divider(color: SynapTheme.surfaceBorder, height: 22),
                    _buildRow('Settlement Speed', '< 1 sec (Real-Time)'),
                    const Divider(color: SynapTheme.surfaceBorder, height: 22),
                    _buildRow('Duress Risk Score', '${snapshot.cdiScore.toStringAsFixed(2)} (Safe)'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Security Audit Note
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: SynapTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 16, color: SynapTheme.primaryCyan),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Audit Signature: #SYNP-84920 • Tap to view SOC Details →',
                          style: TextStyle(fontSize: 11, color: SynapTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SynapTheme.surfaceLight,
                    foregroundColor: SynapTheme.textPrimary,
                    side: const BorderSide(color: SynapTheme.surfaceBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                  child: const Text(
                    'Done / Back to Home',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
          style: const TextStyle(fontSize: 14, color: SynapTheme.textSecondary),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontFamily: isMonospace ? 'monospace' : null,
              color: isBold ? SynapTheme.statusSafe : SynapTheme.textPrimary,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
