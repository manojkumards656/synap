import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../biometrics/biometric_service.dart';
import '../core/theme.dart';
import '../models/touch_event.dart';

class NumericKeypad extends StatelessWidget {
  final void Function(String key) onKeyPressed;
  final VoidCallback onBackspace;

  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((label) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: _KeypadButton(
                      label: label,
                      onPressed: () {
                        if (label == '⌫') {
                          onBackspace();
                        } else {
                          onKeyPressed(label);
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _KeypadButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _KeypadButton({
    required this.label,
    required this.onPressed,
  });

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bioService = context.read<BiometricService>();

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        setState(() => _isPressed = true);
        bioService.recordTouch(
          TouchEvent(
            timestampUs: DateTime.now().microsecondsSinceEpoch,
            x: event.position.dx,
            y: event.position.dy,
            pressure: event.pressure > 0.0 ? event.pressure : 0.6,
            type: TouchType.down,
            keyLabel: widget.label,
          ),
        );
      },
      onPointerUp: (event) {
        setState(() => _isPressed = false);
        bioService.recordTouch(
          TouchEvent(
            timestampUs: DateTime.now().microsecondsSinceEpoch,
            x: event.position.dx,
            y: event.position.dy,
            pressure: 0.0,
            type: TouchType.up,
            keyLabel: widget.label,
          ),
        );
        widget.onPressed();
      },
      onPointerCancel: (_) {
        if (_isPressed) {
          setState(() => _isPressed = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 64, // Large, elderly-friendly target
        decoration: BoxDecoration(
          color: _isPressed
              ? SynapTheme.primaryBlue.withValues(alpha: 0.3)
              : SynapTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isPressed
                ? SynapTheme.primaryCyan
                : SynapTheme.surfaceBorder,
            width: 1.5,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: SynapTheme.primaryBlue.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: widget.label == '⌫'
              ? const Icon(
                  Icons.backspace_outlined,
                  color: SynapTheme.textPrimary,
                  size: 26,
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    color: SynapTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
