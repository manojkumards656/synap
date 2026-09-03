import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../telephony/call_state_service.dart';

class CallIndicator extends StatefulWidget {
  final bool compact;

  const CallIndicator({super.key, this.compact = false});

  @override
  State<CallIndicator> createState() => _CallIndicatorState();
}

class _CallIndicatorState extends State<CallIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callService = context.watch<CallStateService>();
    final isActive = callService.isCallActive;

    final badgeColor = isActive ? AegisTheme.statusCritical : AegisTheme.textMuted;
    final badgeBg = isActive
        ? AegisTheme.statusCritical.withValues(alpha: 0.15)
        : AegisTheme.surfaceLight;

    Widget pill = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive
              ? AegisTheme.statusCritical.withValues(alpha: 0.6)
              : AegisTheme.surfaceBorder,
          width: 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AegisTheme.statusCritical.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? 'CALL ACTIVE' : 'NO CALL DETECTED',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive ? AegisTheme.statusCritical : AegisTheme.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          if (callService.simulatedCallOverride != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'SIM',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (isActive) {
      pill = ScaleTransition(scale: _scaleAnimation, child: pill);
    }

    return GestureDetector(
      onTap: () {
        // Tap allows toggling simulation for instant demo control
        _showCallControlDialog(context, callService);
      },
      child: pill,
    );
  }

  void _showCallControlDialog(BuildContext context, CallStateService service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AegisTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AegisTheme.surfaceBorder),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Telephony State & Demo Simulator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AegisTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Current hardware status: ${service.statusMessage}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AegisTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AegisTheme.statusCritical,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        service.setSimulatedCall(true);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.call),
                      label: const Text('Simulate Call ON'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AegisTheme.surfaceLight,
                        foregroundColor: AegisTheme.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AegisTheme.surfaceBorder),
                      ),
                      onPressed: () {
                        service.setSimulatedCall(false);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.call_end),
                      label: const Text('Simulate Call OFF'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    service.setSimulatedCall(null);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Reset to Live Cellular Sensor'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
