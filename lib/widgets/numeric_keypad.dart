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
            padding: const EdgeInsets.only(bottom: 8.0),
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
        height: 58,
        decoration: BoxDecoration(
          color: _isPressed
              ? AegisTheme.primaryBlue.withValues(alpha: 0.25)
              : AegisTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isPressed
                ? AegisTheme.primaryBlue
                : AegisTheme.surfaceBorder,
            width: 1.2,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: AegisTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Center(
          child: widget.label == '⌫'
              ? const Icon(
                  Icons.backspace_outlined,
                  color: AegisTheme.textPrimary,
                  size: 22,
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    color: AegisTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
