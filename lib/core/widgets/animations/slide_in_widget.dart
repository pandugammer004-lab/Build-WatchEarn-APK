import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

enum SlideDirection { up, down, left, right }

class SlideInWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final SlideDirection direction;

  const SlideInWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = const Duration(milliseconds: 0),
    this.direction = SlideDirection.left,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (direction) {
      case SlideDirection.up:
        return SlideInUp(duration: duration, delay: delay, child: child);
      case SlideDirection.down:
        return SlideInDown(duration: duration, delay: delay, child: child);
      case SlideDirection.left:
        return SlideInLeft(duration: duration, delay: delay, child: child);
      case SlideDirection.right:
        return SlideInRight(duration: duration, delay: delay, child: child);
    }
  }
}
