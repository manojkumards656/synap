import 'package:flutter/material.dart';
import '../core/theme.dart';

class IbanField extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const IbanField({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  String _formatIban(String input) {
    if (input.isEmpty) return 'Enter Recipient IBAN';
    final clean = input.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final display = _formatIban(text);
    final isEmpty = text.isEmpty;

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
                  'RECIPIENT IBAN / ACCOUNT',
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
              children: [
                const Icon(
                  Icons.account_balance_outlined,
                  size: 20,
                  color: AegisTheme.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    display,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      fontFamily: 'monospace',
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
