import 'package:flutter/material.dart';
import 'dart:math' as math;

class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final bool animate;
  final Duration duration;

  const ShakeAnimation({
    Key? key,
    required this.child,
    this.animate = false,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    
    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward(from: 0);
    } else if (!widget.animate && oldWidget.animate) {
      _controller.stop();
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
        // Creates a shake effect by using sine wave
        final sineValue = math.sin(_animation.value * math.pi * 4);
        final offset = (1 - _animation.value) * 10 * sineValue; // Decaying amplitude
        
        return Transform.translate(
          offset: Offset(offset, 0),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}
