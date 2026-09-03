import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';

class AmountField extends StatelessWidget {
  final String rawAmount;
  final bool isSelected;
  final VoidCallback onTap;

  const AmountField({
    super.key,
    required this.rawAmount,
    required this.isSelected,
    required this.onTap,
  });

  String _formatAmount(String raw) {
    if (raw.isEmpty) return '0';
    final parsed = double.tryParse(raw) ?? 0.0;
    final formatter = NumberFormat('#,##,###', 'en_IN');
    return formatter.format(parsed);
  }

  String _toWords(String raw) {
    final val = double.tryParse(raw) ?? 0.0;
    if (val == 0) return 'Zero Rupees';
    if (val == 50) return 'Fifty Rupees';
    if (val == 500) return 'Five Hundred Rupees';
    if (val == 1000) return 'One Thousand Rupees';
    if (val == 5000) return 'Five Thousand Rupees';
    if (val == 10000) return 'Ten Thousand Rupees';
    if (val == 50000) return 'Fifty Thousand Rupees';
    if (val == 100000) return 'One Lakh Rupees';
    if (val == 500000) return 'Five Lakh Rupees';
    return '${NumberFormat.compactSimpleCurrency(locale: 'en_IN', name: '').format(val)} Rupees';
  }

  @override
  Widget build(BuildContext context) {
    final display = _formatAmount(rawAmount);
    final inWords = _toWords(rawAmount);
    final isEmpty = rawAmount.isEmpty || rawAmount == '0';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: SynapTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? SynapTheme.primaryBlue : SynapTheme.surfaceBorder,
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: SynapTheme.primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ENTER AMOUNT TO PAY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: SynapTheme.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: SynapTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'INR (₹)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SynapTheme.primaryCyan),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '₹ ',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: SynapTheme.primaryCyan,
                  ),
                ),
                Expanded(
                  child: Text(
                    display,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isEmpty ? SynapTheme.textMuted : SynapTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Elderly-friendly verbal translation of amount
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: SynapTheme.surfaceLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.record_voice_over_outlined, size: 14, color: SynapTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    inWords,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: SynapTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
