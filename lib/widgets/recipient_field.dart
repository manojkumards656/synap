import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'blinking_cursor.dart';

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
    final isEmpty = accountOrUpi.isEmpty;
    final display = isEmpty ? (isSelected ? '' : 'Tap to enter UPI ID or A/C') : accountOrUpi;
    final title = recipientName.isNotEmpty
        ? recipientName
        : (isEmpty ? 'New Beneficiary' : 'Account Transfer');
    final subtitle = recipientName.isNotEmpty
        ? 'Verified Banking Beneficiary'
        : 'Enter recipient account or UPI ID';

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
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: SynapTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (recipientName.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, size: 16, color: SynapTheme.statusSafe),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (display.isNotEmpty)
                          Flexible(
                            child: Text(
                              display,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                                color: isEmpty ? SynapTheme.textMuted : SynapTheme.textPrimary,
                              ),
                            ),
                          ),
                        if (isSelected)
                          const BlinkingCursor(height: 18, width: 2.2),
                      ],
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
