import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class CDIGauge extends StatefulWidget {
  final double cdiValue; // 0.0 to 1.0

  const CDIGauge({
    super.key,
    required this.cdiValue,
  });

  @override
  State<CDIGauge> createState() => _CDIGaugeState();
}

class _CDIGaugeState extends State<CDIGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentValue = 0.0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.cdiValue.clamp(0.0, 1.0);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: _currentValue,
      end: _currentValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(covariant CDIGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cdiValue != widget.cdiValue) {
      final target = widget.cdiValue.clamp(0.0, 1.0);
      _animation = Tween<double>(
        begin: _animation.value,
        end: target,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final val = _animation.value;
        final color = AegisTheme.getCDIColor(val);
        final label = AegisTheme.getCDILabel(val);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 120,
                width: 220,
                child: CustomPaint(
                  painter: _GaugePainter(value: val),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            val.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                              color: color,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: color.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'CDI: $label',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0.0 SAFE',
                    style: TextStyle(
                      fontSize: 10,
                      color: AegisTheme.statusSafe,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '0.55 ELEVATED',
                    style: TextStyle(
                      fontSize: 10,
                      color: AegisTheme.statusElevated,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '1.0 CRITICAL',
                    style: TextStyle(
                      fontSize: 10,
                      color: AegisTheme.statusCritical,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value; // 0.0 to 1.0

  _GaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final radius = size.width / 2 - 16;
    const strokeWidth = 14.0;

    // Background track (180 deg, from pi to 2*pi)
    final bgPaint = Paint()
      ..color = AegisTheme.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      bgPaint,
    );

    // Active progress arc
    if (value > 0.01) {
      final sweepAngle = pi * value.clamp(0.0, 1.0);

      final activePaint = Paint()
        ..shader = SweepGradient(
          startAngle: pi,
          endAngle: 2 * pi,
          colors: const [
            AegisTheme.statusSafe,
            AegisTheme.statusElevated,
            AegisTheme.statusCritical,
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: GradientRotation(pi / 2),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi,
        sweepAngle,
        false,
        activePaint,
      );

      // Indicator tip dot
      final needleAngle = pi + sweepAngle;
      final tipX = center.dx + radius * cos(needleAngle);
      final tipY = center.dy + radius * sin(needleAngle);

      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(tipX, tipY), strokeWidth / 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
