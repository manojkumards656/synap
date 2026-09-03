import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/biometric_snapshot.dart';
import 'admin_screen.dart';

class EscrowHoldScreen extends StatefulWidget {
  final double amount;
  final String recipientIban;
  final String recipientName;
  final BiometricSnapshot snapshot;
  final bool isCallActive;

  const EscrowHoldScreen({
    super.key,
    required this.amount,
    required this.recipientIban,
    this.recipientName = 'Unknown Beneficiary',
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
      backgroundColor: SynapTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Shield Icon with Red Glow
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: SynapTheme.statusCritical.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: SynapTheme.statusCritical,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: SynapTheme.statusCritical.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 46,
                  color: SynapTheme.statusCritical,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Paused for Your Safety',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: SynapTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Potential Phone Call Scam / Coercion Intercepted',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SynapTheme.statusCritical,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Elderly Reassurance Banner (Large, High-Contrast)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SynapTheme.statusSafe.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SynapTheme.statusSafe.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: SynapTheme.statusSafe, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DO NOT WORRY — YOUR MONEY IS SAFE',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: SynapTheme.statusSafe,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹ $formattedAmount has NOT left your bank account.',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: SynapTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Live Countdown Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2B1419),
                      Color(0xFF1B1218),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: SynapTheme.statusCritical.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '15-MINUTE COOLING-OFF HOLD ACTIVE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: SynapTheme.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        color: SynapTheme.textPrimary,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'This break protects you from urgent phone pressure.',
                      style: TextStyle(
                        fontSize: 12,
                        color: SynapTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Detected Signals Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SynapTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: SynapTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'WHY WAS THIS PAYMENT PAUSED?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: SynapTheme.statusCritical,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: SynapTheme.statusCritical.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'CDI ${widget.snapshot.cdiScore.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: SynapTheme.statusCritical,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (flags.isEmpty)
                      const Text(
                        'Elevated hesitation pattern detected during active phone call.',
                        style: TextStyle(fontSize: 13, color: SynapTheme.textSecondary),
                      )
                    else
                      ...flags.map((flag) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  size: 18,
                                  color: SynapTheme.statusCritical,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    flag,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: SynapTheme.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    const SizedBox(height: 12),
                    const Divider(color: SynapTheme.surfaceBorder, height: 1),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Beneficiary:', style: TextStyle(fontSize: 13, color: SynapTheme.textSecondary)),
                        Text(widget.recipientName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SynapTheme.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount:', style: TextStyle(fontSize: 13, color: SynapTheme.textSecondary)),
                        Text('₹ $formattedAmount', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SynapTheme.statusCritical)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Educational Scam Advice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SynapTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 22, color: SynapTheme.primaryCyan),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Real police, tax officers, or bank officials will NEVER ask you to transfer money to a "secure safety account" over a phone call.',
                        style: TextStyle(
                          fontSize: 12,
                          color: SynapTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Large, Elderly-Friendly Cancel CTA
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SynapTheme.statusSafe,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payment cancelled. ₹$formattedAmount safely retained in your account.'),
                        backgroundColor: SynapTheme.statusSafe,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 22),
                  label: const Text(
                    'Cancel Payment & Keep Money Safe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // SOC Operations Link
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminScreen()),
                  );
                },
                icon: const Icon(Icons.analytics_outlined, size: 16, color: SynapTheme.primaryCyan),
                label: const Text(
                  'View Enterprise SOC Telemetry Details →',
                  style: TextStyle(fontSize: 13, color: SynapTheme.primaryCyan, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
