import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ScaleInWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const ScaleInWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = const Duration(milliseconds: 0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      duration: duration,
      delay: delay,
      child: child,
    );
  }
}
