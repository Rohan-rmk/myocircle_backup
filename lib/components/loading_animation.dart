import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// InfinityRibbonLoader
/// A polished, high-quality animation that draws a figure-eight (lemniscate)
/// ribbon outlined by two thin gradient borders (left and right side of the path),
/// while a glossy "shimmer" (moving line segment) glides along the center of the ribbon.
///
/// Key features:
/// - Gradient border (left-to-right) using the exact colors you requested.
/// - Two thin parallel outlines (computed by offsetting the path along normals).
/// - A moving central segment whose color is the same gradient and which casts a soft glow/shadow.
/// - Highly smooth geometry sampling and careful tangent/normal computation for stable offsets.
/// - Configurable size, thicknesses, animation speed and shimmer length.
///
/// Usage (see canvas file for full example): place inside a Center or any container.
class InfinityRibbonLoader extends StatefulWidget {
  final double size;
  final Duration duration;
  final List<Color> colors; // gradient colors left -> right
  final double borderThickness; // thickness of each outline
  final double gap; // gap between the two outlines (space where the line moves)
  final double lineThickness; // thickness of the moving line
  final double
      segmentFraction; // fraction of path length occupied by the moving shimmer
  final bool showGlow;

  const InfinityRibbonLoader({
    Key? key,
    this.size = 220,
    this.duration = const Duration(milliseconds: 2800),
    this.colors = const [
      Color(0xff063183),
      Color(0xff0B3E6A),
      Color(0xff104C4E),
      Color(0xff165A32),
    ],
    this.borderThickness = 2.0,
    this.gap = 10.0,
    this.lineThickness = 6.0,
    this.segmentFraction = 0.14,
    this.showGlow = true,
  }) : super(key: key);

  @override
  _InfinityRibbonLoaderState createState() => _InfinityRibbonLoaderState();
}

class _InfinityRibbonLoaderState extends State<InfinityRibbonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _InfinityRibbonPainter(
              progress: _controller.value,
              colors: widget.colors,
              borderThickness: widget.borderThickness,
              gap: widget.gap,
              lineThickness: widget.lineThickness,
              segmentFraction: widget.segmentFraction,
              showGlow: widget.showGlow,
            ),
          );
        },
      ),
    );
  }
}

class _InfinityRibbonPainter extends CustomPainter {
  final double progress; // 0..1
  final List<Color> colors;
  final double borderThickness;
  final double gap;
  final double lineThickness;
  final double segmentFraction;
  final bool showGlow;

  _InfinityRibbonPainter({
    required this.progress,
    required this.colors,
    required this.borderThickness,
    required this.gap,
    required this.lineThickness,
    required this.segmentFraction,
    required this.showGlow,
  });

  // lemniscate parametric function (same style used in previous widget) - returns offset from center
  Offset _lemniscatePoint(double t, double a) {
    final double s = math.sin(t);
    final double c = math.cos(t);
    final double denom = 1 + s * s;
    final double x = a * c / denom;
    final double y = a * s * c / denom;
    return Offset(x, y);
  }

  // safe normalize helper
  Offset _normalize(Offset v) {
    final double len = v.distance;
    if (len == 0) return Offset.zero;
    return v / len;
  }

  // sample the gradient colors list at xNormalized in [0..1]
  Color _sampleGradientColor(double x) {
    if (colors.isEmpty) return Colors.white;
    if (colors.length == 1) return colors.first;
    // evenly spaced stops
    final int n = colors.length;
    final double segment = 1.0 / (n - 1);
    final int idx = (x / segment).clamp(0, n - 2).floor();
    final double localT = ((x - idx * segment) / segment).clamp(0.0, 1.0);
    return Color.lerp(colors[idx], colors[idx + 1], localT)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final Offset center = Offset(cx, cy);

    // radius of the lemniscate path
    final double pathRadius = size.width * 0.38;

    // how many samples for smoothness: scale with size
    final int steps = (size.width * 1.8).clamp(240, 720).toInt();

    // build central sample points along the lemniscate
    final List<Offset> centerPoints = List.generate(steps + 1, (i) {
      final double t = (i / steps) * 2 * math.pi;
      return center + _lemniscatePoint(t, pathRadius);
    });

    // compute normals using centered-difference of points
    final List<Offset> normals = List.generate(centerPoints.length, (i) {
      final int prev = (i - 1 + centerPoints.length) % centerPoints.length;
      final int next = (i + 1) % centerPoints.length;
      final Offset tangent = (centerPoints[next] - centerPoints[prev]) / 2.0;
      final Offset normal = _normalize(Offset(-tangent.dy, tangent.dx));
      return normal;
    });

    // offset magnitude for the outlines
    final double offsetMag = gap / 2.0;

    // create path objects
    final Path centerPath = Path();
    final Path leftOutline = Path();
    final Path rightOutline = Path();

    for (int i = 0; i < centerPoints.length; i++) {
      final Offset p = centerPoints[i];
      final Offset n = normals[i];
      final Offset left = p + n * offsetMag; // one side
      final Offset right = p - n * offsetMag; // other side
      if (i == 0) {
        centerPath.moveTo(p.dx, p.dy);
        leftOutline.moveTo(left.dx, left.dy);
        rightOutline.moveTo(right.dx, right.dy);
      } else {
        centerPath.lineTo(p.dx, p.dy);
        leftOutline.lineTo(left.dx, left.dy);
        rightOutline.lineTo(right.dx, right.dy);
      }
    }

    // close them to be continuous
    centerPath.close();
    leftOutline.close();
    rightOutline.close();

    // horizontal gradient shader left->right
    final ui.Gradient shader = ui.Gradient.linear(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      colors,
      List.generate(colors.length, (i) => i / (colors.length - 1)),
    );

    // paint for outlines
    final Paint outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderThickness
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..shader = shader;

    // draw outlines
    canvas.drawPath(leftOutline, outlinePaint);
    canvas.drawPath(rightOutline, outlinePaint);

    // moving shimmer: extract a segment from centerPath along its length
    final List<ui.PathMetric> metrics =
        centerPath.computeMetrics(forceClosed: true).toList();

    if (metrics.isEmpty) {
      canvas.restore();
      return;
    }

    final ui.PathMetric metric = metrics.first;

    final double totalLen = metric.length;
    final double segLen = (totalLen * segmentFraction).clamp(
      4.0,
      totalLen * 0.4,
    );
    final double start = (progress * totalLen) % totalLen;
    final double end = (start + segLen) % totalLen;

    // helper to extract possibly-wrapping segment
    final Path movingSegment = Path();
    if (start < end) {
      movingSegment.addPath(metric.extractPath(start, end), Offset.zero);
    } else {
      // wrapped
      movingSegment.addPath(metric.extractPath(start, totalLen), Offset.zero);
      movingSegment.addPath(metric.extractPath(0, end), Offset.zero);
    }

    // shadow/blur behind moving segment for shiny effect
    if (showGlow) {
      final Paint glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineThickness * 1.9
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..maskFilter = ui.MaskFilter.blur(BlurStyle.normal, lineThickness * 1.6)
        ..color = Colors.black.withOpacity(0.18);
      canvas.drawPath(movingSegment, glowPaint);

      // a colored blurred layer (faint) to create a luminous trail
      final Paint coloredBlur = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineThickness * 1.2
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..maskFilter = ui.MaskFilter.blur(BlurStyle.normal, lineThickness * 1.2)
        ..shader = shader
        ..blendMode = BlendMode.screen;
      canvas.drawPath(movingSegment, coloredBlur);
    }

    // main moving line paint: same gradient
    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineThickness
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..shader = shader;

    canvas.drawPath(movingSegment, linePaint);

    // draw shiny head/tail circles for a polished look
    // compute tangent positions for start and end so we can place radial highlights
    ui.Tangent? startTangent = metric.getTangentForOffset(start);
    ui.Tangent? endTangent = metric.getTangentForOffset(
      (start + segLen) % totalLen,
    );

    // helper to paint glow circle with sampled gradient color based on horizontal x
    void _drawHead(Offset pos) {
      final double xn = (pos.dx / size.width).clamp(0.0, 1.0);
      final Color c = _sampleGradientColor(xn);
      final Paint circleGlow = Paint()
        ..color = c.withOpacity(0.24)
        ..maskFilter = ui.MaskFilter.blur(
          BlurStyle.normal,
          lineThickness * 1.8,
        );
      final Paint circleCore = Paint()..color = c;
      canvas.drawCircle(pos, lineThickness * 0.9, circleGlow);
      canvas.drawCircle(pos, lineThickness * 0.45, circleCore);
    }

    if (startTangent != null) _drawHead(startTangent.position);
    if (endTangent != null) _drawHead(endTangent.position);

    // a faint inner glow along the path to give it depth (optional subtle enhancement)
    final Paint innerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (gap * 0.32).clamp(1.0, 6.0)
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..shader = shader
      ..color = Colors.white.withOpacity(0.02);

    canvas.drawPath(centerPath, innerGlow);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InfinityRibbonPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.colors != colors ||
        oldDelegate.borderThickness != borderThickness ||
        oldDelegate.gap != gap ||
        oldDelegate.lineThickness != lineThickness ||
        oldDelegate.segmentFraction != segmentFraction ||
        oldDelegate.showGlow != showGlow;
  }
}
