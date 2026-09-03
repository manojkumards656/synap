import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/biometric_snapshot.dart';

class EscrowHoldScreen extends StatefulWidget {
  final double amount;
  final String recipientIban;
  final BiometricSnapshot snapshot;
  final bool isCallActive;

  const EscrowHoldScreen({
    super.key,
    required this.amount,
    required this.recipientIban,
    required this.snapshot,
    required this.isCallActive,
  });

  @override
  State<EscrowHoldScreen> createState() => _EscrowHoldScreenState();
}

class _EscrowHoldScreenState extends State<EscrowHoldScreen> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = CDIConstants.escrowDurationSeconds; // 900s = 15:00
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSecs) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##,###.##', 'en_IN');
    final formattedAmount = currencyFormat.format(widget.amount);
    final flags = widget.snapshot.activeDuressFlags;

    return Scaffold(
      backgroundColor: AegisTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Shield Icon with Red Glow
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AegisTheme.statusCritical.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AegisTheme.statusCritical,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AegisTheme.statusCritical.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 44,
                  color: AegisTheme.statusCritical,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Protective Escrow Hold',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AegisTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Transfer Intercepted for Scam Protection',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AegisTheme.statusCritical,
                ),
              ),
              const SizedBox(height: 20),
              // Live Countdown Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF261217),
                      Color(0xFF191016),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AegisTheme.statusCritical.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'MANDATORY COOLING-OFF PERIOD',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AegisTheme.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        color: AegisTheme.textPrimary,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Funds are safe and untouched in reserve escrow.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AegisTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Why this happened (Coercion Breakdown)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AegisTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AegisTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'COGNITIVE DURESS DETECTED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AegisTheme.statusCritical,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AegisTheme.statusCritical.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'CDI ${widget.snapshot.cdiScore.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AegisTheme.statusCritical,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (flags.isEmpty)
                      const Text(
                        'Elevated hesitation pattern detected during active call.',
                        style: TextStyle(fontSize: 12, color: AegisTheme.textSecondary),
                      )
                    else
                      ...flags.map((flag) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  size: 16,
                                  color: AegisTheme.statusCritical,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    flag,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AegisTheme.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    const SizedBox(height: 12),
                    const Divider(color: AegisTheme.surfaceBorder, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Target Beneficiary:',
                          style: TextStyle(fontSize: 12, color: AegisTheme.textSecondary),
                        ),
                        Text(
                          widget.recipientIban,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: AegisTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Intercepted Amount:',
                          style: TextStyle(fontSize: 12, color: AegisTheme.textSecondary),
                        ),
                        Text(
                          '₹ $formattedAmount',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AegisTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Explanatory note breaking the scam urgency
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AegisTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: AegisTheme.primaryCyan),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Genuine government authorities or bank fraud units will NEVER order you to move money to "safe accounts" over a call.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AegisTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Immediate Cancel CTA
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AegisTheme.statusSafe,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transfer aborted. ₹50,000 retained safely in your account.'),
                        backgroundColor: AegisTheme.statusSafe,
                      ),
                    );
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text(
                    'Cancel Transfer (Save My Funds)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Secondary Action: Return Home
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AegisTheme.textSecondary,
                    side: const BorderSide(color: AegisTheme.surfaceBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                  child: const Text('Dismiss & Review Details'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
