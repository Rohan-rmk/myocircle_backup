import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CircularTickCounter extends StatefulWidget {
  const CircularTickCounter({
    Key? key,
    required this.totalTicks,
    required this.completedTicks,
    required this.completedReps,
    required this.totalReps,
    this.size = 300,
    this.completedColor = const Color(0xFF00E5FF),
    this.remainingColor = Colors.white70,
    this.animationDuration = const Duration(milliseconds: 600),
    this.label,
    this.backgroundDecoration,
    this.onTap,
  }) : super(key: key);

  final int totalTicks;
  final int completedTicks;
  final int completedReps;
  final int totalReps;
  final double size;
  final Color completedColor;
  final Color remainingColor;
  final Duration animationDuration;
  final String? label;
  final Decoration? backgroundDecoration;
  final VoidCallback? onTap;

  @override
  State<CircularTickCounter> createState() => _CircularTickCounterState();
}

class _CircularTickCounterState extends State<CircularTickCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _oldCompleted;
  late int _currentCompleted;

  @override
  void initState() {
    super.initState();
    _oldCompleted = widget.completedTicks;
    _currentCompleted = widget.completedTicks;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant CircularTickCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completedTicks != _currentCompleted) {
      _oldCompleted = _currentCompleted;
      _currentCompleted = widget.completedTicks.clamp(0, widget.totalTicks);
      _controller
        ..value = 0.0
        ..animateTo(1.0, curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _progressFraction {
    final double start = _oldCompleted / widget.totalTicks;
    final double end = _currentCompleted / widget.totalTicks;
    return ui.lerpDouble(start, end, _controller.value)!.clamp(0.0, 1.0);
  }

  int get _currentAnimatedInt {
    return (_progressFraction * widget.totalTicks).round();
  }

  @override
  Widget build(BuildContext context) {
    // Scaling factors based on size
    final tickWidthSmall = widget.size * 0.006; // scales with size
    final tickWidthLarge = widget.size * 0.012;
    final tickLengthSmall = widget.size * 0.04;
    final tickLengthLarge = widget.size * 0.085;
    final innerPadding = widget.size * 0.1;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final double frac = _progressFraction;
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _TickPainter(
                totalTicks: widget.totalTicks,
                progressFraction: frac,
                completedColor: widget.completedColor,
                remainingColor: widget.remainingColor,
                tickWidthSmall: tickWidthSmall,
                tickWidthLarge: tickWidthLarge,
                tickLengthSmall: tickLengthSmall,
                tickLengthLarge: tickLengthLarge,
                innerPadding: innerPadding,
              ),
              foregroundPainter: _CenterPainter(
                value: _currentAnimatedInt,
                label: widget.label,
                size: widget.size,
                completedReps: widget.completedReps,
                totalReps: widget.totalReps,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  _TickPainter({
    required this.totalTicks,
    required this.progressFraction,
    required this.completedColor,
    required this.remainingColor,
    required this.tickWidthSmall,
    required this.tickWidthLarge,
    required this.tickLengthSmall,
    required this.tickLengthLarge,
    required this.innerPadding,
  });

  final int totalTicks;
  final double progressFraction;
  final Color completedColor;
  final Color remainingColor;
  final double tickWidthSmall;
  final double tickWidthLarge;
  final double tickLengthSmall;
  final double tickLengthLarge;
  final double innerPadding;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;
    final innerRadius = maxRadius - innerPadding - tickLengthLarge;

    final completedTicks = (progressFraction * totalTicks).floor();
    final partial = (progressFraction * totalTicks) - completedTicks;

    for (int i = 0; i < totalTicks; i++) {
      final double t = i / totalTicks;
      final double angle = (t * 2 * pi) - pi / 2;
      final direction = Offset(cos(angle), sin(angle));

      final bool isCompleted = i < completedTicks;
      final bool isPartialTick = i == completedTicks && partial > 0;

      final double len = isCompleted
          ? tickLengthLarge
          : (isPartialTick
              ? tickLengthSmall + (tickLengthLarge - tickLengthSmall) * partial
              : tickLengthSmall);
      final double stroke = isCompleted
          ? tickWidthLarge
          : (isPartialTick
              ? tickWidthSmall + (tickWidthLarge - tickWidthSmall) * partial
              : tickWidthSmall);

      final start = center + direction * innerRadius;
      final end = center + direction * (innerRadius + len);

      final Paint paint = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true
        ..color = isCompleted
            ? completedColor.withOpacity(1.0)
            : remainingColor.withOpacity(0.95);

      if (isCompleted) {
        final glow = Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = stroke + 3
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..color = completedColor.withOpacity(0.18);
        canvas.drawLine(start, end, glow);
      } else if (isPartialTick) {
        final glow = Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = stroke + 1.2
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
          ..color = completedColor.withOpacity(0.08 * partial);
        canvas.drawLine(start, end, glow);
      }

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TickPainter old) {
    return old.progressFraction != progressFraction ||
        old.totalTicks != totalTicks ||
        old.completedColor != completedColor ||
        old.remainingColor != remainingColor;
  }
}

class _CenterPainter extends CustomPainter {
  _CenterPainter({
    required this.value,
    required this.label,
    required this.size,
    required this.completedReps,
    required this.totalReps,
  });

  final int value;
  final String? label;
  final double size;
  final int completedReps;
  final int totalReps;

  @override
  void paint(Canvas canvas, Size s) {
    final center = Offset(s.width / 2, s.height / 2);

    // Main reps text
    final TextSpan spanReps = TextSpan(
      text: "$completedReps/$totalReps",
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.18, // scales with widget size
        fontWeight: FontWeight.w700,
        fontFamily: 'Roboto',
        shadows: const [
          Shadow(
            blurRadius: 6,
            color: Color.fromARGB(90, 0, 0, 0),
            offset: Offset(0, 2),
          ),
        ],
      ),
    );

    final TextPainter tpReps = TextPainter(
      text: spanReps,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tpReps.layout();
    final repsOffset = center - Offset(tpReps.width / 2, tpReps.height / 2);
    tpReps.paint(canvas, repsOffset);

    // Label below reps
    if (label != null && label!.isNotEmpty) {
      final TextSpan spanLabel = TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white70,
          fontSize: size * 0.08, // scales with widget size
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
      );

      final TextPainter tpLabel = TextPainter(
        text: spanLabel,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tpLabel.layout();
      final spacing = size * 0.04; // dynamic spacing
      final labelOffset =
          center + Offset(-tpLabel.width / 2, tpReps.height / 2 + spacing);
      tpLabel.paint(canvas, labelOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _CenterPainter old) {
    return old.label != label ||
        old.completedReps != completedReps ||
        old.totalReps != totalReps;
  }
}
