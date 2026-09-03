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
    if (raw.isEmpty) return '0.00';
    final parsed = double.tryParse(raw) ?? 0.0;
    final formatter = NumberFormat('#,##,###.##', 'en_IN');
    return formatter.format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final display = _formatAmount(rawAmount);
    final isEmpty = rawAmount.isEmpty || rawAmount == '0';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AegisTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AegisTheme.primaryBlue
                : AegisTheme.surfaceBorder,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AegisTheme.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
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
                  'TRANSFER AMOUNT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AegisTheme.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AegisTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '₹ ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AegisTheme.primaryCyan,
                  ),
                ),
                Expanded(
                  child: Text(
                    display,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isEmpty
                          ? AegisTheme.textMuted
                          : AegisTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
