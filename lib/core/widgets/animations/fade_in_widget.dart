import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class FadeInWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final bool animate;

  const FadeInWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = const Duration(milliseconds: 0),
    this.animate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: duration,
      delay: delay,
      animate: animate,
      child: child,
    );
  }
}

class FadeInUpWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final bool animate;

  const FadeInUpWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = const Duration(milliseconds: 0),
    this.animate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: duration,
      delay: delay,
      animate: animate,
      child: child,
    );
  }
}
