import 'package:flutter/material.dart';
import 'dart:math';

class CoinParticleWidget extends StatefulWidget {
  const CoinParticleWidget({Key? key}) : super(key: key);

  @override
  State<CoinParticleWidget> createState() => _CoinParticleWidgetState();
}

class _CoinParticleWidgetState extends State<CoinParticleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        setState(() {
          for (var p in _particles) {
            p.update();
          }
        });
      })..repeat();

    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(_random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(_particles),
      child: Container(),
    );
  }
}

class Particle {
  double x;
  double y;
  double speedY;
  double speedX;
  double size;
  double alpha;
  Random random;

  Particle(this.random)
      : x = random.nextDouble() * 400,
        y = random.nextDouble() * 800,
        speedY = -0.5 - random.nextDouble() * 1.5,
        speedX = -0.5 + random.nextDouble(),
        size = 8 + random.nextDouble() * 12,
        alpha = 0.1 + random.nextDouble() * 0.4;

  void update() {
    y += speedY;
    x += speedX;
    if (y < -20) {
      y = 820;
      x = random.nextDouble() * 400;
    }
    if (x < -20 || x > 420) {
      speedX *= -1;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    for (var p in particles) {
      paint.color = const Color(0xFFFFD700).withOpacity(p.alpha);
      canvas.drawCircle(Offset(p.x * (size.width / 400), p.y * (size.height / 800)), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
