import 'package:flutter/material.dart';
import '../core/theme.dart';

class BlinkingCursor extends StatefulWidget {
  final double height;
  final double width;
  final Color color;

  const BlinkingCursor({
    super.key,
    this.height = 30.0,
    this.width = 2.5,
    this.color = SynapTheme.primaryCyan,
  });

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: const EdgeInsets.only(left: 3),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.6),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
