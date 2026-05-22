// widgets/floating_particles.dart
//
// Lightweight floating particle effect for the profile background.
// Uses a single AnimationController driving all particles for performance.
// Particles drift upward, fade, and loop seamlessly.

import 'dart:math' as math;
import 'package:flutter/material.dart';

class FloatingParticles extends StatefulWidget {
  final int count;
  final Color color;

  const FloatingParticles({
    super.key,
    this.count = 16,
    this.color = const Color(0xFF00E5C8),
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    final rng = math.Random(42);
    _particles = List.generate(widget.count, (_) => _Particle.random(rng));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only render in the top dark section (hero area, ~40% of screen)
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final size = MediaQuery.of(context).size;
            final heroH = size.height * 0.42;
            return ClipRect(
              child: SizedBox(
                width: size.width,
                height: heroH,
                child: CustomPaint(
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _ctrl.value,
                    color: widget.color,
                    width: size.width,
                    height: heroH,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Particle {
  final double x; // 0-1 horizontal position
  final double startY; // 0-1 starting Y (bottom)
  final double speed; // relative speed multiplier
  final double size; // radius
  final double opacity; // max opacity
  final double phase; // animation phase offset

  const _Particle({
    required this.x,
    required this.startY,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.phase,
  });

  factory _Particle.random(math.Random rng) => _Particle(
    x: rng.nextDouble(),
    startY: rng.nextDouble(),
    speed: 0.4 + rng.nextDouble() * 0.6,
    size: 1.5 + rng.nextDouble() * 2.5,
    opacity: 0.15 + rng.nextDouble() * 0.35,
    phase: rng.nextDouble(),
  );
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;
  final double width;
  final double height;

  const _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Particle cycles from bottom to top, looping via (progress + phase) % 1
      final t = ((progress * p.speed + p.phase) % 1.0);
      final py = height * (1.0 - t); // moves upward
      final px = width * p.x;

      // Fade in at bottom, fade out at top
      final fade = t < 0.15
          ? t / 0.15
          : t > 0.80
          ? (1.0 - t) / 0.20
          : 1.0;

      final paint = Paint()
        ..color = color.withValues(alpha: p.opacity * fade)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(px, py), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress;
}
