import 'package:flutter/material.dart';

class AchievementShimmerText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const AchievementShimmerText({
    super.key,
    required this.text,
    this.fontSize = 32,
    this.fontWeight = FontWeight.bold,
  });

  @override
  State<AchievementShimmerText> createState() => _AchievementShimmerTextState();
}

class _AchievementShimmerTextState extends State<AchievementShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black,
                Colors.amberAccent,
                Colors.amberAccent,
                Colors.black,
              ],
              stops: [
                (controller.value - 0.3).clamp(0.0, 1.0),
                controller.value,
                controller.value,
                (controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              color: Colors.black,
              fontFamily: "Alegreya_Sans",
            ),
          ),
        );
      },
    );
  }
}
