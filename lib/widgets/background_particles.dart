import 'dart:math';
import 'package:flutter/material.dart';

class BackgroundParticles extends StatefulWidget {
  const BackgroundParticles({super.key});

  @override
  State<BackgroundParticles> createState() => _BackgroundParticlesState();
}

class _BackgroundParticlesState extends State<BackgroundParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Создаем частицы с эмодзи еды
    final foodEmojis = ['🍎', '🥕', '🐟', '🥛', '🥩', '🥚', '🌾', '🍒', '🍞', '🧀', '🍅', '🥑'];
    for (int i = 0; i < 24; i++) {
      _particles.add(Particle(
        emoji: foodEmojis[_random.nextInt(foodEmojis.length)],
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.3 + _random.nextDouble() * 0.3,
        rotation: _random.nextDouble() * 360,
        rotationSpeed: 1 + _random.nextDouble() * 2,
        size: 24 + _random.nextDouble() * 40,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlesPainter(_particles, _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class Particle {
  final String emoji;
  double x;
  double y;
  final double speed;
  double rotation;
  final double rotationSpeed;
  final double size;

  Particle({
    required this.emoji,
    required this.x,
    required this.y,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
  });

  void update(double deltaTime) {
    // Движение частиц
    y += speed * deltaTime;
    if (y > 1.2) {
      y = -0.2;
    }

    // Вращение
    rotation += rotationSpeed * deltaTime;
    if (rotation > 360) {
      rotation -= 360;
    }
  }
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlesPainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final deltaTime = 0.016; // ~60 FPS

    for (final particle in particles) {
      particle.update(deltaTime);

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      // Рисуем эмодзи как текст
      final textPainter = TextPainter(
        text: TextSpan(
          text: particle.emoji,
          style: TextStyle(
            fontSize: particle.size,
            color: Colors.white.withOpacity(0.15),
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation * 3.14159 / 180);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



























