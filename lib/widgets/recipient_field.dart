import 'package:flutter/material.dart';
import '../core/theme.dart';

class RecipientField extends StatelessWidget {
  final String recipientName;
  final String accountOrUpi;
  final bool isSelected;
  final VoidCallback onTap;

  const RecipientField({
    super.key,
    required this.recipientName,
    required this.accountOrUpi,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final display = accountOrUpi.isEmpty ? 'Tap to enter UPI ID or A/C' : accountOrUpi;

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
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: SynapTheme.primaryBlue.withValues(alpha: 0.2),
                  child: Text(
                    recipientName.isNotEmpty ? recipientName[0].toUpperCase() : '₹',
                    style: const TextStyle(
                      color: SynapTheme.primaryCyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            recipientName.isNotEmpty ? recipientName : 'Paying Beneficiary',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: SynapTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, size: 16, color: SynapTheme.statusSafe),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Banking Name: S.B.I. Treasury / Direct Account',
                        style: TextStyle(
                          fontSize: 12,
                          color: SynapTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: SynapTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: SynapTheme.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alternate_email, size: 16, color: SynapTheme.primaryCyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      display,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        color: accountOrUpi.isEmpty ? SynapTheme.textMuted : SynapTheme.textPrimary,
                      ),
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
