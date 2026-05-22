// lib/features/hasil_prediksi/screens/hasil_prediksi_screen.dart
//
// Tampilan: Dark navy/teal seperti screenshot wellness-app-ui
// Warna per kategori:
//   rendah  → Cyan/Teal  (#0CFFE1 neon mint)
//   sedang  → Amber/Gold (#FFB830 neon amber)
//   tinggi  → Red/Rose   (#FF4D6A neon rose)
// Semua logika / provider / navigasi TIDAK berubah.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../kuisioner/providers/questionnaire_provider.dart';
import '../models/ml_result_model.dart';
import '../providers/result_provider.dart';
import '../../histori/screens/histori_screen.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../profil/screens/profil_screen.dart';

// ─── Base Dark Palette ────────────────────────────────────────────────────────

const _white = Color(0xFFFFFFFF);

// Dark navy backgrounds (layered)
const _bgBase = Color(0xFF0A1628); // deepest navy
const _bgMid = Color(0xFF0D1F3C); // mid navy
const _bgCard = Color(0xFF142040); // card surface
const _bgCardAlt = Color(0xFF1A2B52); // slightly lighter card

// Text
const _textPrimary = Color(0xFFE8F0FF);
const _textSub = Color(0xFF7B91B5);
const _textMuted = Color(0xFF4A6080);

// Glass borders
const _glassBorder = Color(0x33FFFFFF); // 20% white
const _glassBorder2 = Color(0x1AFFFFFF); // 10% white

// ─── Per-Category Theme ────────────────────────────────────────────────────────
//
//  rendah  → Neon Cyan/Teal
//  sedang  → Neon Amber/Gold
//  tinggi  → Neon Rose/Red

class _CategoryTheme {
  /// Neon accent (bright glow color)
  final Color accent;

  /// Slightly dimmer version for secondary use
  final Color accentDim;

  /// Background gradient start (dark tinted)
  final Color bgFrom;

  /// Background gradient end (dark tinted)
  final Color bgTo;

  /// Glow color for shadows
  final Color glow;

  /// Label shown on badge
  final String statusLabel;

  /// Subtitle message in hero
  final String subtitle;

  const _CategoryTheme({
    required this.accent,
    required this.accentDim,
    required this.bgFrom,
    required this.bgTo,
    required this.glow,
    required this.statusLabel,
    required this.subtitle,
  });
}

// RENDAH — Neon Cyan/Teal (seperti screenshot)
const _themeRendah = _CategoryTheme(
  accent: Color(0xFF0CFFE1), // neon teal/cyan
  accentDim: Color(0xFF0DD9C0),
  bgFrom: Color(0xFF0A1628),
  bgTo: Color(0xFF0C2235),
  glow: Color(0xFF0CFFE1),
  statusLabel: 'Pola Hidup Sehat',
  subtitle: 'Hebat! Kamu menjaga keseimbangan digitalmu dengan baik.',
);

// SEDANG — Neon Amber/Gold
const _themeSedang = _CategoryTheme(
  accent: Color(0xFFFFB830), // neon amber
  accentDim: Color(0xFFE0A020),
  bgFrom: Color(0xFF160F00),
  bgTo: Color(0xFF1E1500),
  glow: Color(0xFFFFB830),
  statusLabel: 'Perlu Perhatian',
  subtitle: 'Aktivitas digitalmu mulai perlu diseimbangkan.',
);

// TINGGI — Neon Rose/Red
const _themeTinggi = _CategoryTheme(
  accent: Color(0xFFFF4D6A), // neon rose-red
  accentDim: Color(0xFFE03050),
  bgFrom: Color(0xFF160A10),
  bgTo: Color(0xFF200D16),
  glow: Color(0xFFFF4D6A),
  statusLabel: 'Risiko Ketergantungan',
  subtitle: 'Aktivitas digitalmu sangat intens.\nSaatnya memberi dirimu jeda.',
);

_CategoryTheme _themeFor(String category) {
  final cat = category.toLowerCase();
  if (cat == 'tinggi' || cat == 'high') return _themeTinggi;
  if (cat == 'sedang' || cat == 'moderate') return _themeSedang;
  return _themeRendah;
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

// ─── Floating Particle ────────────────────────────────────────────────────────

class _FP {
  final double x, y, r, sx, sy, op;
  const _FP(this.x, this.y, this.r, this.sx, this.sy, this.op);
}

class _ParticlePainter extends CustomPainter {
  final List<_FP> particles;
  final double t;
  final Color accent;
  const _ParticlePainter({
    required this.particles,
    required this.t,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < particles.length; i++) {
      final p = particles[i];
      final phase = t * math.pi * 2 + i * 0.4;
      final dx = p.x * size.width + math.sin(phase) * 10;
      final dy = p.y * size.height + math.cos(phase * 0.6) * 8;
      final op = p.op * (0.5 + 0.5 * math.sin(phase).abs());
      canvas.drawCircle(
        Offset(dx, dy),
        p.r,
        Paint()
          ..color = accent.withValues(alpha: op * 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

// ─── Score Ring Painter ────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color accent;
  final double glow;
  const _RingPainter({
    required this.progress,
    required this.accent,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 14;
    const sw = 8.0;
    const start = -math.pi / 2;

    // Decorative dot ring (dim)
    for (var i = 0; i < 40; i++) {
      final a = i / 40 * math.pi * 2 - math.pi / 2;
      canvas.drawCircle(
        Offset(c.dx + (r + 12) * math.cos(a), c.dy + (r + 12) * math.sin(a)),
        1.0,
        Paint()..color = accent.withValues(alpha: 0.20),
      );
    }

    // Track
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = _white.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );

    if (progress <= 0) return;

    final sweep = math.pi * 2 * progress;

    // Outer glow
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      start,
      sweep,
      false,
      Paint()
        ..color = accent.withValues(alpha: 0.25 * glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw + 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Main arc — gradient via shader
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      start,
      sweep,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: start,
          endAngle: start + sweep,
          colors: [accent.withValues(alpha: 0.5), accent],
        ).createShader(Rect.fromCircle(center: c, radius: r))
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );

    // Tip dot
    final tipAngle = start + sweep;
    final tip = Offset(
      c.dx + r * math.cos(tipAngle),
      c.dy + r * math.sin(tipAngle),
    );
    canvas.drawCircle(
      tip,
      sw * 0.8,
      Paint()
        ..color = accent.withValues(alpha: 0.40 * glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(tip, sw * 0.28, Paint()..color = _white);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.glow != glow;
}

// ─── Mascot Painter ───────────────────────────────────────────────────────────

class _MascotPainter extends CustomPainter {
  final bool mini;
  const _MascotPainter({this.mini = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body
    canvas.drawOval(
      Rect.fromLTWH(w * 0.06, h * 0.06, w * 0.88, h * 0.88),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: [const Color(0xFFD4F5F0), const Color(0xFFB8E0F8)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Highlight
    canvas.drawOval(
      Rect.fromLTWH(w * 0.22, h * 0.14, w * 0.34, h * 0.24),
      Paint()..color = _white.withValues(alpha: 0.45),
    );

    final eye = Paint()..color = const Color(0xFF1A2A4A);
    if (!mini) {
      canvas.drawOval(
        Rect.fromLTWH(w * 0.28, h * 0.38, w * 0.14, h * 0.18),
        eye,
      );
      canvas.drawOval(
        Rect.fromLTWH(w * 0.58, h * 0.38, w * 0.14, h * 0.18),
        eye,
      );
      canvas.drawCircle(
        Offset(w * 0.31, h * 0.40),
        w * 0.04,
        Paint()..color = _white,
      );
      canvas.drawCircle(
        Offset(w * 0.61, h * 0.40),
        w * 0.04,
        Paint()..color = _white,
      );
      final smile = Path()
        ..moveTo(w * 0.35, h * 0.64)
        ..quadraticBezierTo(w * 0.50, h * 0.76, w * 0.65, h * 0.64);
      canvas.drawPath(
        smile,
        Paint()
          ..color = const Color(0xFF1A2A4A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.04
          ..strokeCap = StrokeCap.round,
      );
      // Blush
      canvas.drawOval(
        Rect.fromLTWH(w * 0.10, h * 0.53, w * 0.16, h * 0.10),
        Paint()..color = const Color(0xFFFFB3CC).withValues(alpha: 0.40),
      );
      canvas.drawOval(
        Rect.fromLTWH(w * 0.74, h * 0.53, w * 0.16, h * 0.10),
        Paint()..color = const Color(0xFFFFB3CC).withValues(alpha: 0.40),
      );
    } else {
      canvas.drawOval(
        Rect.fromLTWH(w * 0.27, h * 0.37, w * 0.13, h * 0.17),
        eye,
      );
      canvas.drawOval(
        Rect.fromLTWH(w * 0.60, h * 0.37, w * 0.13, h * 0.17),
        eye,
      );
      canvas.drawCircle(
        Offset(w * 0.30, h * 0.40),
        w * 0.035,
        Paint()..color = _white,
      );
      canvas.drawCircle(
        Offset(w * 0.63, h * 0.40),
        w * 0.035,
        Paint()..color = _white,
      );
      final smile = Path()
        ..moveTo(w * 0.36, h * 0.63)
        ..quadraticBezierTo(w * 0.50, h * 0.74, w * 0.64, h * 0.63);
      canvas.drawPath(
        smile,
        Paint()
          ..color = const Color(0xFF1A2A4A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.045
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_MascotPainter old) => false;
}

// ─── Sparkle ──────────────────────────────────────────────────────────────────

class _Sparkle extends StatelessWidget {
  final double size;
  final Color color;
  final double phase;
  final double t;
  const _Sparkle({
    required this.size,
    required this.color,
    required this.phase,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final op = (0.4 + 0.6 * ((math.sin((t + phase) * math.pi * 2) + 1) / 2))
        .clamp(0.0, 1.0);
    return Opacity(
      opacity: op,
      child: CustomPaint(
        size: Size(size, size),
        painter: _StarPainter(color: color),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;
  const _StarPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      final r = i % 2 == 0 ? size.width / 2 : size.width / 4;
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatefulWidget {
  final MlResultModel data;
  const _HeroSection({required this.data});
  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with TickerProviderStateMixin {
  late final AnimationController _glow;
  late final AnimationController _progress;
  late final AnimationController _particle;
  late final AnimationController _fadeIn;
  late final AnimationController _score;
  late final Animation<double> _glowA, _progressA, _fadeA, _scoreA;
  late final Animation<Offset> _slideA;
  late final List<_FP> _particles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42);
    _particles = List.generate(
      28,
      (_) => _FP(
        rng.nextDouble(),
        rng.nextDouble(),
        rng.nextDouble() * 3.0 + 1.0,
        (rng.nextDouble() - .5) * .3,
        (rng.nextDouble() - .5) * .3,
        rng.nextDouble() * .35 + .10,
      ),
    );

    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _glowA = Tween<double>(
      begin: .30,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glow, curve: Curves.easeInOut));

    _progress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    _progressA = CurvedAnimation(parent: _progress, curve: Curves.easeOutCubic);

    _particle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fadeIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeA = CurvedAnimation(parent: _fadeIn, curve: Curves.easeOut);
    _slideA = Tween<Offset>(
      begin: const Offset(0, .04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeIn, curve: Curves.easeOut));

    _score = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    _scoreA = CurvedAnimation(parent: _score, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _glow.dispose();
    _progress.dispose();
    _particle.dispose();
    _fadeIn.dispose();
    _score.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final theme = _themeFor(data.category);
    final pct = (data.digitalDependenceScore / 100).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _glowA,
        _progressA,
        _particle,
        _fadeA,
        _scoreA,
      ]),
      builder: (_, __) {
        final displayScore = (_scoreA.value * data.dependenceInt).round();

        return FadeTransition(
          opacity: _fadeA,
          child: SlideTransition(
            position: _slideA,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.bgFrom,
                    theme.bgTo,
                    Color.lerp(theme.bgTo, theme.accent, 0.06)!,
                  ],
                  stops: const [0, .55, 1],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.glow.withValues(alpha: .18 * _glowA.value),
                    blurRadius: 40,
                    spreadRadius: 2,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Particles
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(36),
                      ),
                      child: CustomPaint(
                        painter: _ParticlePainter(
                          particles: _particles,
                          t: _particle.value,
                          accent: theme.accent,
                        ),
                      ),
                    ),
                  ),

                  // Ambient orbs
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.accent.withValues(alpha: .08 * _glowA.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.accent.withValues(alpha: .05 * _glowA.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 52, 20, 28),
                    child: Column(
                      children: [
                        // ── TOP BAR ──────────────────────────────────────────
                        Row(
                          children: [
                            _NavBtn(
                              onTap: () => Navigator.pop(context),
                              accent: theme.accent,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hasil Analisis',
                                  style: TextStyle(
                                    color: _textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Machine Learning AI',
                                  style: TextStyle(
                                    color: _textSub.withValues(alpha: .70),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: .8,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Mascot header top-right
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: CustomPaint(
                                painter: _MascotPainter(mini: true),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // ── SCORE ORB ─────────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left floating mascot (larger)
                            _FloatMascot(
                              size: 60,
                              accent: theme.accent,
                              t: _particle.value,
                            ),
                            const SizedBox(width: 4),

                            // Orb
                            _ScoreOrb(
                              score: displayScore,
                              category: _capitalize(data.category),
                              pct: _progressA.value * pct,
                              theme: theme,
                              glow: _glowA.value,
                              t: _particle.value,
                            ),

                            const SizedBox(width: 4),
                            // Right sparkles
                            SizedBox(
                              width: 60,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _Sparkle(
                                    size: 14,
                                    color: theme.accent,
                                    phase: 0,
                                    t: _particle.value,
                                  ),
                                  const SizedBox(height: 10),
                                  _Sparkle(
                                    size: 9,
                                    color: theme.accent.withValues(alpha: .6),
                                    phase: .4,
                                    t: _particle.value,
                                  ),
                                  const SizedBox(height: 6),
                                  _Sparkle(
                                    size: 6,
                                    color: theme.accent.withValues(alpha: .4),
                                    phase: .7,
                                    t: _particle.value,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── STATUS TEXT ──────────────────────────────────────
                        Text(
                          'Digital Balance: ${theme.statusLabel}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .2,
                            shadows: [
                              Shadow(
                                color: theme.accent.withValues(
                                  alpha: .25 * _glowA.value,
                                ),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          theme.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _textSub,
                            fontSize: 13,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── INSIGHT BUBBLE ────────────────────────────────────
                        _InsightBubble(theme: theme, data: data),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Nav Button ───────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Color accent;
  const _NavBtn({required this.onTap, required this.accent});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: .08),
        border: Border.all(color: accent.withValues(alpha: .25)),
      ),
      child: Icon(Icons.arrow_back_ios_new_rounded, color: accent, size: 15),
    ),
  );
}

// ─── Floating Mascot ──────────────────────────────────────────────────────────

class _FloatMascot extends StatelessWidget {
  final double size;
  final Color accent;
  final double t;
  const _FloatMascot({
    required this.size,
    required this.accent,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final offset = math.sin(t * math.pi * 2) * 5;
    return Transform.translate(
      offset: Offset(0, offset),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size + 20,
            height: size + 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [accent.withValues(alpha: .20), Colors.transparent],
              ),
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(painter: _MascotPainter()),
          ),
        ],
      ),
    );
  }
}

// ─── Score Orb ────────────────────────────────────────────────────────────────

class _ScoreOrb extends StatelessWidget {
  final int score;
  final String category;
  final double pct;
  final _CategoryTheme theme;
  final double glow;
  final double t;
  const _ScoreOrb({
    required this.score,
    required this.category,
    required this.pct,
    required this.theme,
    required this.glow,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    const orbSize = 196.0;
    const innerSize = orbSize * 0.63;

    return SizedBox(
      width: orbSize,
      height: orbSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ambient glow
          Container(
            width: orbSize,
            height: orbSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.glow.withValues(alpha: .20 * glow),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),

          // Progress ring
          CustomPaint(
            size: const Size(orbSize, orbSize),
            painter: _RingPainter(
              progress: pct,
              accent: theme.accent,
              glow: glow,
            ),
          ),

          // Inner dark glass orb
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _bgMid,
              border: Border.all(
                color: theme.accent.withValues(alpha: .18),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.glow.withValues(alpha: .12 * glow),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: _white.withValues(alpha: .04),
                  blurRadius: 8,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner glow blob
                Positioned(
                  top: 8,
                  left: 12,
                  child: Container(
                    width: innerSize * .4,
                    height: innerSize * .28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _white.withValues(alpha: .06),
                    ),
                  ),
                ),

                // Score text + category chip
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        color: theme.accent,
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -3,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: theme.glow.withValues(alpha: .50 * glow),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Category badge inside orb
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: theme.accent.withValues(alpha: .12),
                        border: Border.all(
                          color: theme.accent.withValues(alpha: .30),
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: theme.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Insight Bubble ───────────────────────────────────────────────────────────

class _InsightBubble extends StatelessWidget {
  final _CategoryTheme theme;
  final MlResultModel data;
  const _InsightBubble({required this.theme, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
          bottomRight: Radius.circular(22),
          bottomLeft: Radius.circular(6),
        ),
        color: _bgCard,
        border: Border.all(color: theme.accent.withValues(alpha: .15)),
        boxShadow: [
          BoxShadow(
            color: theme.glow.withValues(alpha: .08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CustomPaint(painter: _MascotPainter(mini: true)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hai! ${theme.subtitle}',
              style: TextStyle(
                color: _textPrimary.withValues(alpha: .85),
                fontSize: 13,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(theme.accent.withValues(alpha: .50)),
              const SizedBox(height: 4),
              _dot(theme.accent.withValues(alpha: .35)),
              const SizedBox(height: 4),
              _dot(theme.accent.withValues(alpha: .20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
    width: 6,
    height: 6,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );
}

// ─── Factor Pills ─────────────────────────────────────────────────────────────

class _FactorPills extends StatelessWidget {
  final _CategoryTheme theme;
  const _FactorPills({required this.theme});

  static const _pills = [
    (Icons.smartphone_rounded, '📱 Screen Time'),
    (Icons.nightlight_round, '🌙 Malam Hari'),
    (Icons.bed_rounded, '😴 Kurang Tidur'),
    (Icons.notifications_rounded, '🔔 Notifikasi'),
    (Icons.sports_esports_rounded, '🎮 Gaming'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _pills.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final (icon, label) = _pills[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: _bgCard,
              border: Border.all(
                color: theme.accent.withValues(alpha: .22),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.glow.withValues(alpha: .07),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: theme.accent, size: 15),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── AI Analysis Card ─────────────────────────────────────────────────────────

class _AiAnalysisCard extends StatelessWidget {
  final MlResultModel data;
  final _CategoryTheme theme;
  const _AiAnalysisCard({required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: _bgCard,
        border: Border.all(
          color: theme.accent.withValues(alpha: .18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.glow.withValues(alpha: .10),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top-right tint orb
          Positioned(
            top: -12,
            right: -12,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.accent.withValues(alpha: .10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.accent.withValues(alpha: .12),
                        border: Border.all(
                          color: theme.accent.withValues(alpha: .30),
                        ),
                      ),
                      child: Icon(
                        Icons.psychology_rounded,
                        color: theme.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Analisis AI',
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .3,
                          ),
                        ),
                        Text(
                          'Powered by Activa Intelligence',
                          style: TextStyle(
                            color: theme.accentDim,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: .5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        theme.accent.withValues(alpha: .25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  data.pembukaan,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    height: 1.75,
                    letterSpacing: .1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recommendation Card ──────────────────────────────────────────────────────

class _RecommendationCard extends StatelessWidget {
  final RecommendationItem item;
  final int index;
  final _CategoryTheme theme;
  const _RecommendationCard({
    required this.item,
    required this.index,
    required this.theme,
  });

  static const _tagMeta = <String, (IconData, String)>{
    'social_media': (Icons.smartphone_rounded, '📱 Screen Time Tinggi'),
    'sleep': (Icons.nightlight_round, '🌙 Kurang Tidur'),
    'exercise': (Icons.directions_run_rounded, '🏃 Aktivitas Fisik'),
    'notification': (Icons.notifications_off_rounded, '🔔 Notifikasi Berlebih'),
    'notifications': (
      Icons.notifications_off_rounded,
      '🔔 Notifikasi Berlebih',
    ),
    'screen_time': (Icons.timer_off_rounded, '⏱ Screen Time'),
    'stress': (Icons.favorite_rounded, '💛 Kelola Stres'),
    'general': (Icons.auto_awesome_rounded, '✨ Rekomendasi'),
  };

  @override
  Widget build(BuildContext context) {
    final meta = _tagMeta[item.tag] ?? _tagMeta['general']!;
    final icon = meta.$1;
    final title = meta.$2;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _bgCard,
        border: Border.all(
          color: theme.accent.withValues(alpha: .15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.glow.withValues(alpha: .07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Left gradient accent strip
          Positioned(
            left: 0,
            top: 16,
            bottom: 16,
            child: Container(
              width: 3.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.accent, theme.accent.withValues(alpha: .30)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.glow.withValues(alpha: .40),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),

          // Mini mascot on first card
          if (index == 0)
            Positioned(
              top: -4,
              right: -4,
              child: SizedBox(
                width: 28,
                height: 28,
                child: CustomPaint(painter: _MascotPainter(mini: true)),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: theme.accent.withValues(alpha: .10),
                    border: Border.all(
                      color: theme.accent.withValues(alpha: .25),
                    ),
                  ),
                  child: Icon(icon, color: theme.accent, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.isi,
                        style: const TextStyle(
                          color: _textSub,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Activity Wave ────────────────────────────────────────────────────────────

class _ActivityWave extends StatelessWidget {
  final _CategoryTheme theme;
  const _ActivityWave({required this.theme});

  static const _days = ['S', 'M', 'T', 'R', 'K', 'J', 'S'];
  static const _values = [35.0, 65.0, 45.0, 80.0, 55.0, 40.0, 25.0];

  @override
  Widget build(BuildContext context) {
    const maxV = 80.0, barH = 70.0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: _bgCard,
        border: Border.all(
          color: theme.accent.withValues(alpha: .15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.glow.withValues(alpha: .08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aktivitas Mingguan',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.accent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.accent.withValues(alpha: .40),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_days.length, (i) {
              final h = (_values[i] / maxV) * barH;
              final isMax = _values[i] == maxV;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.accent,
                          theme.accent.withValues(alpha: .30),
                        ],
                      ),
                      boxShadow: isMax
                          ? [
                              BoxShadow(
                                color: theme.glow.withValues(alpha: .40),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _days[i],
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── CTA Buttons ─────────────────────────────────────────────────────────────

class _CtaButtons extends StatelessWidget {
  final _CategoryTheme theme;
  const _CtaButtons({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary — gradient with accent glow
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [theme.accent, theme.accentDim.withValues(alpha: .80)],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.glow.withValues(alpha: .35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LaporanPerkembanganScreen(),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lihat Perkembangan',
                    style: TextStyle(
                      color: Color(0xFF0A1628),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .3,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF0A1628),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary — dark glass
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _bgCard,
            border: Border.all(
              color: theme.accent.withValues(alpha: .28),
              width: 1.2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KuesionerScreen()),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, color: theme.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Ulangi Analisis',
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── History Button ───────────────────────────────────────────────────────────

class _HistoriButton extends StatelessWidget {
  final _CategoryTheme theme;
  const _HistoriButton({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _bgCard,
        border: Border.all(color: theme.accent.withValues(alpha: .22)),
        boxShadow: [
          BoxShadow(
            color: theme.glow.withValues(alpha: .07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoriScreen()),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_rounded, color: theme.accent, size: 22),
              const SizedBox(width: 10),
              Text(
                'Lihat Riwayat Analisis',
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _AnalysisErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;
  const _AnalysisErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_bgBase, _bgMid],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _bgCard,
                  border: Border.all(
                    color: _themeRendah.accent.withValues(alpha: .30),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  color: _themeRendah.accent,
                  size: 42,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Hasil Tidak Ditemukan',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tidak dapat memuat hasil analisis.\nCoba kembali ke kuesioner.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSub.withValues(alpha: .80),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _themeRendah.accent.withValues(alpha: .50),
                    fontSize: 11,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: _themeRendah.accent.withValues(alpha: .12),
                    border: Border.all(
                      color: _themeRendah.accent.withValues(alpha: .30),
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: _themeRendah.accent,
                    ),
                    label: Text(
                      'Coba Lagi',
                      style: TextStyle(
                        color: _themeRendah.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen  (LOGIKA TIDAK BERUBAH)
// ─────────────────────────────────────────────────────────────────────────────

class HasilPrediksiScreen extends ConsumerStatefulWidget {
  final MlResultModel? result;
  const HasilPrediksiScreen({super.key, this.result});

  @override
  ConsumerState<HasilPrediksiScreen> createState() =>
      _HasilPrediksiScreenState();
}

class _HasilPrediksiScreenState extends ConsumerState<HasilPrediksiScreen> {
  MlResultModel? _data;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  void _resolve() {
    try {
      if (widget.result != null) {
        _data = widget.result;
        return;
      }
      final fromQ = ref.read(questionnaireResultProvider);
      if (fromQ != null) {
        _data = fromQ;
        return;
      }
      final fromLatest = ref.read(resultProvider).latestResult;
      if (fromLatest != null) {
        _data = fromLatest;
        return;
      }
      _error = Exception(
        'Hasil analisis tidak ditemukan. Silakan isi kuesioner terlebih dahulu.',
      );
    } catch (e) {
      _error = e;
    }
  }

  void _retry() => setState(() {
    _data = null;
    _error = null;
    _resolve();
  });

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.popUntil(context, (r) => r.isFirst);
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KuesionerScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPerkembanganScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GrafikScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBase,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _error != null
                  ? _AnalysisErrorView(error: _error, onRetry: _retry)
                  : _data != null
                  ? _ResultContent(data: _data!)
                  : _AnalysisErrorView(
                      error: 'Data tidak tersedia',
                      onRetry: _retry,
                    ),
            ),
            BottomNav(currentIndex: 1, onTap: _onNavTap),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result Content
// ─────────────────────────────────────────────────────────────────────────────

class _ResultContent extends StatelessWidget {
  final MlResultModel data;
  const _ResultContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = _themeFor(data.category);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero
          _HeroSection(data: data),

          const SizedBox(height: 24),

          // 2. Factor Pills
          _FactorPills(theme: theme),

          const SizedBox(height: 24),

          // 3. AI Analysis card
          if (data.pembukaan.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _AiAnalysisCard(data: data, theme: theme),
            ),
            const SizedBox(height: 24),
          ],

          // 4. Rekomendasi header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.accent,
                        theme.accent.withValues(alpha: .30),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.glow.withValues(alpha: .50),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Rekomendasi AI',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 5. Recommendation cards
          ...data.rekomendasi.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _RecommendationCard(
                item: e.value,
                index: e.key,
                theme: theme,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 6. Activity Wave
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ActivityWave(theme: theme),
          ),

          const SizedBox(height: 24),

          // 7. CTA Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _CtaButtons(theme: theme),
          ),

          const SizedBox(height: 16),

          // 8. History button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _HistoriButton(theme: theme),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
