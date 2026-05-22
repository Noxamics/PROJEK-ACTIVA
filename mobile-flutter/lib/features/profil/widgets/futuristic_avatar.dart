// widgets/futuristic_avatar.dart
//
// Glowing circular profile orb with layered gradient ring,
// pulse animation, and animated initials display.

import 'package:flutter/material.dart';

class FuturisticAvatar extends StatelessWidget {
  final String initials;
  final Animation<double> pulseAnim;
  final double size;

  const FuturisticAvatar({
    super.key,
    required this.initials,
    required this.pulseAnim,
    this.size = 96,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, child) {
        final glow = 0.15 + 0.12 * pulseAnim.value;
        final ringScale = 1.0 + 0.04 * pulseAnim.value;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            Transform.scale(
              scale: ringScale,
              child: Container(
                width: size + 40,
                height: size + 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00E5C8).withValues(alpha: glow),
                      const Color(0xFF00E5C8).withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // Mid ring (border gradient)
            Container(
              width: size + 16,
              height: size + 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    const Color(0xFF00E5C8),
                    const Color(0xFF4B9FFF),
                    const Color(0xFF8B7FFF),
                    const Color(0xFF00E5C8),
                  ],
                  transform: GradientRotation(pulseAnim.value * 2 * 3.14159),
                ),
              ),
            ),

            // Inner ring separator (navy gap)
            Container(
              width: size + 8,
              height: size + 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF091528),
              ),
            ),

            // Avatar body
            child!,
          ],
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00E5C8), Color(0xFF0099AA), Color(0xFF005588)],
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.35,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
        ),
      ),
    );
  }
}
