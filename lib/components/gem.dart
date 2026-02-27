import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sensors_plus/sensors_plus.dart';

// Enum defining animation types for the Gem widget.
enum AnimationType { none, pop, waveLeft, waveRight }

// A widget representing an animated gem with interactive and sensor-based effects.
class Gem extends StatefulWidget {
  // Unique identifier for the gem (controls color).
  final int id;
  // Size of the gem.
  final double size;
  // Indicates whether the gem is locked.
  final bool isLocked;
  // Enables haptic feedback on tap.
  final bool enableHapticFeedback;
  // Type of animation applied to the gem.
  final AnimationType animationType;
  // Delay before triggering the lock animation.
  final int lockDelay;
  // Delay before triggering the heart animation.
  final int heartDelay;
  // Delay before the gem grows to full size.
  final int growDelay;
  final Function function;

  const Gem({
    super.key,
    required this.id,
    this.size = 60.0,
    this.isLocked = false,
    this.enableHapticFeedback = true,
    this.animationType = AnimationType.pop, required this.lockDelay, required this.heartDelay, required this.growDelay, required this.function,
  });

  @override
  State<Gem> createState() => _GemState();
}

class _GemState extends State<Gem> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _tapController;
  late AnimationController _growController;
  late AnimationController _heartController;
  late AnimationController _lockController;
  late AnimationController _waveController;

  // Animation objects
  late Animation<double> _tapAnimation;
  late Animation<double> _heartAnimation;
  late Animation<double> _lockAnimation;
  late Animation<double> _growAnimation;

  // Variables for accelerometer-based movement
  double dx = 0.0, dy = 0.0;

  StreamSubscription? _accelerometerSubscription;


  @override
  void initState() {
    super.initState();

    // Controller for the shimmer wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Tap controller for the gem animations
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Tap animation for the gem
    _tapAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50), // Expand
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50), // Shrink back
    ]).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));

    // Controller for the lock animation
    _lockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds:800),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(seconds: widget.lockDelay), () {
          if(mounted)
            {
              _lockController.forward(from: 0);
            }
        });
      }
    });
    // Animation for the lock
    _lockAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 4), weight: 50), // Move right
      TweenSequenceItem(tween: Tween(begin: 4, end: -4), weight: 100), // Move left
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 50), // Return to center
    ]).animate(CurvedAnimation(
      parent: _lockController,
      curve: Curves.easeInOut,
    ));

    // Controller for the heart animation
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds:1000),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(seconds: widget.heartDelay), () {
          if(mounted)
            _heartController.forward(from: 0);
        });
      }
    });
    // Animation for the heart
    _heartAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50), // Expand
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50), // Shrink back
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50), // Shrink back
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50), // Shrink back
    ]).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeInOut,
    ));

    // Controller for the grow animation
    _growController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    // Animation for grow effect
    _growAnimation = Tween<double>(
      begin: 0.0, // Start as a dot
      end: 1.0, // Grow to full size
    ).animate(CurvedAnimation(
      parent: _growController,
      curve: Curves.bounceInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: widget.growDelay), () {
        if(mounted)
          {
            _growController.forward(from: 0);
          }
      });
      // Your animation trigger code here
    });

    _heartController.forward();
    _lockController.forward();

    // Listen to accelerometer changes for shadow movement effect
      _accelerometerSubscription = accelerometerEventStream().listen((event) {
        if (mounted)
          {
            setState(() {
              dx = -event.x * 3;
              dy = event.y * 3;
            });
          }
      });

  }

  @override
  void dispose() {
    _tapController.dispose();
    _waveController.dispose();
    _growController.dispose();
    _heartController.dispose();
    _lockController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }
  // Handles tap interaction with haptic feedback.
  void _handleTap() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    _tapController.forward(from: 0);

    // Trigger shake when wave completes
    _tapController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _lockController.forward(from: 0);
        _heartController.forward(from: 0);
      }
    });
    widget.function();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_tapController, _waveController]),
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(
                widget.animationType == AnimationType.waveRight
                    ? sin(_tapController.value * pi) * 5
                    : widget.animationType == AnimationType.waveLeft
                    ? -sin(_tapController.value * pi) * 5
                    : 0.0,
                0.0,
                0.0,
              )
              ..scale(widget.animationType == AnimationType.pop ? _tapAnimation.value : 1.0),
            child: AnimatedBuilder(
              animation: _growController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _growAnimation.value,
                  child: Stack(alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200), // Smooth transition
                        transform: Matrix4.translationValues(dx + (widget.size*0.04), dy + (widget.size*0.08), 0),
                        child: Stack(alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity:.3,
                              child: SvgPicture.asset(
                                "assets/components/gems/gem${widget.id}/main.svg",
                                height: widget.size,
                                width: widget.size,
                              ),
                            ),
                            Container(width: widget.size,height: widget.size,decoration: BoxDecoration(shape: BoxShape.circle,boxShadow: [
                              BoxShadow(blurRadius: 10,spreadRadius: 2,blurStyle: BlurStyle.normal,color: Colors.black.withOpacity(0.5))
                            ]),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(fit: BoxFit.cover,
                            "assets/components/gems/gem${widget.id}/main.svg",
                            height: widget.size,
                            width: widget.size,
                          ),
                          SvgPicture.asset(fit: BoxFit.cover,
                            "assets/components/gems/gem${widget.id}/overlay.svg",
                            height: widget.size,
                            width: widget.size,
                          ),
                          CustomPaint(
                            size: Size(widget.size, widget.size),
                            painter: ShimmerEffectPainter(_waveController,),
                          ),
                          widget.isLocked?
                          Container(
                            width: widget.size,
                            height: widget.size,
                            child: AnimatedBuilder(
                              animation: _lockController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(_lockAnimation.value, 0),  // Shake left & right
                                  child: Icon(shadows: const[
                                    Shadow(color: Colors.black54,offset: Offset(1, 2),blurRadius: 6)
                                  ],Icons.lock_outline_rounded, color: Colors.white, size: widget.size/3.5),
                                );
                              },
                            ),
                          ):
                          AnimatedBuilder(
                            animation: _heartController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _heartAnimation.value,
                                child: Icon(shadows: const [
                                  Shadow(color: Colors.black54,offset: Offset(1, 2),blurRadius: 6)
                                ],Icons.favorite_outline_rounded, color: const Color.fromRGBO(240, 240, 240, 1), size: widget.size/3.5),
                              );
                            },
                          ),

                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Custom Painter for shimmer effect
class ShimmerEffectPainter extends CustomPainter {
  final AnimationController waveController;

  ShimmerEffectPainter( this.waveController) : super(repaint: waveController);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0,0,size.height,size.height);


    final shimmerPaint = Paint();

    // Compute shimmer position
    double shimmerX = (waveController.value * size.width * 2) - size.width;
    double shimmerY = (waveController.value * size.height * 2) - size.height;

    shimmerPaint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.3),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.3,0.5,0.7],
    ).createShader(Rect.fromLTWH(shimmerX, shimmerY, size.width, size.height));

    canvas.drawOval(rect, shimmerPaint);

  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


