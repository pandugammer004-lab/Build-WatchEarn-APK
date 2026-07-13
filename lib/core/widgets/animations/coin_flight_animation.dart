import 'package:flutter/material.dart';
import 'dart:math' as math;

class CoinFlightAnimation extends StatefulWidget {
  final BuildContext sourceContext;
  final int count;
  final VoidCallback onComplete;

  const CoinFlightAnimation({
    Key? key,
    required this.sourceContext,
    this.count = 5,
    required this.onComplete,
  }) : super(key: key);

  static void show(BuildContext context, {int count = 5, required VoidCallback onComplete}) {
    OverlayEntry? overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (_) => CoinFlightAnimation(
        sourceContext: context,
        count: count,
        onComplete: () {
          onComplete();
          overlayEntry?.remove();
        },
      ),
    );
    
    Overlay.of(context, rootOverlay: true).insert(overlayEntry);
  }

  @override
  State<CoinFlightAnimation> createState() => _CoinFlightAnimationState();
}

class _CoinFlightAnimationState extends State<CoinFlightAnimation> with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<CoinPath> _coins = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPaths();
      _controller.forward();
    });
  }

  void _initPaths() {
    final RenderBox renderBox = widget.sourceContext.findRenderObject() as RenderBox;
    final sourcePosition = renderBox.localToGlobal(Offset.zero);
    final sourceSize = renderBox.size;
    final startX = sourcePosition.dx + (sourceSize.width / 2);
    final startY = sourcePosition.dy + (sourceSize.height / 2);

    // Assume destination is top right (wallet icon area)
    final targetX = MediaQuery.of(context).size.width - 40.0;
    final targetY = 60.0;

    for (int i = 0; i < widget.count; i++) {
      _coins.add(
        CoinPath(
          startX: startX,
          startY: startY,
          targetX: targetX,
          targetY: targetY,
          controlX1: startX + (_random.nextDouble() * 200 - 100),
          controlY1: startY - (_random.nextDouble() * 200 + 50),
          delay: _random.nextDouble() * 0.4,
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_coins.isEmpty) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: _coins.map((coin) {
          final animation = CurvedAnimation(
            parent: _controller,
            curve: Interval(coin.delay, math.min(1.0, coin.delay + 0.6), curve: Curves.easeInOut),
          );

          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              if (animation.value == 0 || animation.value == 1) return const SizedBox.shrink();

              // Bezier curve calculation
              final t = animation.value;
              final x = _calculateBezier(t, coin.startX, coin.controlX1, coin.targetX);
              final y = _calculateBezier(t, coin.startY, coin.controlY1, coin.targetY);

              return Positioned(
                left: x - 15, // center coin
                top: y - 15,
                child: Transform.rotate(
                  angle: t * math.pi * 4,
                  child: Transform.scale(
                    scale: 1.0 - (t * 0.5), // Shrink slightly as it flies
                    child: const Text('🪙', style: TextStyle(fontSize: 30)),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  double _calculateBezier(double t, double p0, double p1, double p2) {
    return math.pow(1 - t, 2) * p0 + 2 * (1 - t) * t * p1 + math.pow(t, 2) * p2;
  }
}

class CoinPath {
  final double startX;
  final double startY;
  final double targetX;
  final double targetY;
  final double controlX1;
  final double controlY1;
  final double delay;

  CoinPath({
    required this.startX,
    required this.startY,
    required this.targetX,
    required this.targetY,
    required this.controlX1,
    required this.controlY1,
    required this.delay,
  });
}
