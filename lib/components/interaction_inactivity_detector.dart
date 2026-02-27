import 'dart:async';
import 'package:flutter/material.dart';

import '../services/applife_cycle_manager.dart';

class InteractionInactivityDetector extends StatefulWidget {
  final Duration timeout;
  final VoidCallback onInactivity;
  final Widget child;

  const InteractionInactivityDetector({
    Key? key,
    required this.timeout,
    required this.onInactivity,
    required this.child,
  }) : super(key: key);

  @override
  _InteractionInactivityDetectorState createState() => _InteractionInactivityDetectorState();
}

class _InteractionInactivityDetectorState extends State<InteractionInactivityDetector> {
  Timer? _inactivityTimer;

  void _resetTimer() {
    _inactivityTimer?.cancel();
    if (ActivityMonitor.isIdle) {
      _inactivityTimer = Timer(widget.timeout, widget.onInactivity);
    }
  }

  void _onUserInteraction([_]) => _resetTimer();

  @override
  void initState() {
    super.initState();
    ActivityMonitor.addListener(_resetTimer);
    _resetTimer();
  }

  @override
  void dispose() {
    ActivityMonitor.removeListener(_resetTimer);
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onUserInteraction,
      onPointerMove: _onUserInteraction,
      onPointerHover: _onUserInteraction,
      onPointerUp: _onUserInteraction,
      child: widget.child,
    );
  }
}