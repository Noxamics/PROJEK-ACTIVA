// widgets/ai_wellness_card.dart
//
// Premium AI Wellness Status Card.
// Shows: glowing mini-graph bars, wellness icon, supportive insight text.
// Style: glassmorphism, floating, rounded corners, soft teal glow.

import 'package:flutter/material.dart';

class AiWellnessCard extends StatefulWidget {
  const AiWellnessCard({super.key});

  @override
  State<AiWellnessCard> createState() => _AiWellnessCardState();
}

class _AiWellnessCardState extends State<AiWellnessCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _barAnim;

  // Simulated weekly trend data (0.0–1.0 normalized)
  final List<double> _bars = [0.55, 0.62, 0.48, 0.70, 0.65, 0.80, 0.75];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _barAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0D1F3C).withValues(alpha: 0.92),
            const Color(0xFF091528).withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF00E5C8).withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5C8).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Mascot
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF00E5C8), Color(0xFF005588)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5C8).withValues(alpha: 0.35),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.spa_rounded, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Wellness Insight',
                      style: TextStyle(
                        color: Color(0xFF00E5C8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Perjalanan digitalmu mulai lebih stabil minggu ini',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.90),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Mini graph
          _MiniGraph(bars: _bars, anim: _barAnim),

          const SizedBox(height: 14),

          // Trend label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5C8).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF00E5C8),
                      size: 14,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '+15% dari minggu lalu',
                      style: TextStyle(
                        color: Color(0xFF00E5C8),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Mini bar graph inside wellness card

class _MiniGraph extends StatelessWidget {
  final List<double> bars;
  final Animation<double> anim;

  const _MiniGraph({required this.bars, required this.anim});

  @override
  Widget build(BuildContext context) {
    const days = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    const barHeight = 52.0;
    const barW = 10.0;

    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        return SizedBox(
          height: barHeight + 22,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(bars.length, (i) {
              final h = barHeight * bars[i] * anim.value;
              final isLast = i == bars.length - 1;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: barW,
                    height: h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isLast
                            ? [const Color(0xFF00E5C8), const Color(0xFF00FFE0)]
                            : [
                                const Color(0xFF00E5C8).withValues(alpha: 0.3),
                                const Color(0xFF4B9FFF).withValues(alpha: 0.5),
                              ],
                      ),
                      boxShadow: isLast
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF00E5C8,
                                ).withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[i],
                    style: TextStyle(
                      color: isLast
                          ? const Color(0xFF00E5C8)
                          : Colors.white.withValues(alpha: 0.35),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
