import 'package:flutter/material.dart';

class CountUpAnimation extends StatefulWidget {
  final int begin;
  final int end;
  final Duration duration;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;

  const CountUpAnimation({
    Key? key,
    required this.begin,
    required this.end,
    this.duration = const Duration(seconds: 1),
    this.style,
    this.prefix,
    this.suffix,
  }) : super(key: key);

  @override
  State<CountUpAnimation> createState() => _CountUpAnimationState();
}

class _CountUpAnimationState extends State<CountUpAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = IntTween(begin: widget.begin, end: widget.end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(CountUpAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.end != widget.end) {
      _controller.duration = widget.duration;
      _animation = IntTween(begin: oldWidget.end, end: widget.end).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final text = '${widget.prefix ?? ''}${_formatNumber(_animation.value)}${widget.suffix ?? ''}';
        return Text(text, style: widget.style);
      },
    );
  }
}
