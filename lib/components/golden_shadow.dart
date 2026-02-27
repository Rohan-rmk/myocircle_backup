import 'package:flutter/material.dart';

class GoldenFlowShadow extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final Duration duration;

  const GoldenFlowShadow({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<GoldenFlowShadow> createState() => _GoldenFlowShadowState();
}

class _GoldenFlowShadowState extends State<GoldenFlowShadow>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> glow;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    glow = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glow,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.amberAccent.withOpacity(glow.value),
                blurRadius: 35 * glow.value,
                spreadRadius: 12 * glow.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
