import 'dart:math';

import 'package:flutter/material.dart';

class GradientCircularProgressIndicator extends StatelessWidget {
  final double value; // The current progress value (0.0 to 1.0)
  final double parentSize;
  final List<Color> colors;
  final Color remColor;

  const GradientCircularProgressIndicator(
      {Key? key,
      required this.value,
      required this.parentSize,
      required this.colors,
      this.remColor = Colors.grey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: CustomPaint(
        painter: _GradientCircularProgressPainter(
          parentSize: parentSize,
          value: value,
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          remColor: remColor,
        ),
      ),
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  final double value;
  final LinearGradient gradient;
  final double parentSize;
  final Color remColor;

  _GradientCircularProgressPainter({
    required this.value,
    required this.gradient,
    required this.parentSize,
    this.remColor = Colors.grey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = parentSize / 85
      ..strokeCap = StrokeCap.round;

    final backgroundPaint = Paint()
      ..color = remColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = parentSize / 85;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;

    // Draw the background circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw the progress arc
    final startAngle = -pi / 2; // Start from bottom center
    final sweepAngle = 2 * pi * value; // Progress value
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint whenever the value changes
  }
}
