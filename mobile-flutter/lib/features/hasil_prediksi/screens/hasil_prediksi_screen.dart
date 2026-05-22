// lib/features/hasil_prediksi/screens/hasil_prediksi_screen.dart
//
// Layout (REFACTORED v3):
//   - Gradient background: biru gelap (atas) → putih (bawah)
//   - Urutan konten di dalam dark section:
//       1. Top Bar
//       2. Score Orb + Mascot
//       3. Status Text
//       4. Divider
//       5. Factor Pills
//       6. Activity Wave
//       7. Divider
//       8. Analisis AI (dipindah ke ATAS rekomendasi)
//       9. Rekomendasi AI (glassmorphism cards)
//      10. CTA Buttons
//      11. History Button

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

// ─── Palette ──────────────────────────────────────────────────────────────────

const _white = Color(0xFFFFFFFF);

// Dark section (bagian atas)
const _darkTop = Color(0xFF081320);
const _darkMid = Color(0xFF0B1D33);
const _darkCard = Color(0xFF0F2040);

// Light bg untuk Scaffold
const _lightBg = Color(0xFFF7F9FC);

// ─── Per-Category Theme ───────────────────────────────────────────────────────

class _CategoryTheme {
  final Color accent;
  final Color accentDim;
  final Color bgBlend;
  final Color glow;
  final String statusLabel;
  final String subtitle;
  final String mascotAsset;

  const _CategoryTheme({
    required this.accent,
    required this.accentDim,
    required this.bgBlend,
    required this.glow,
    required this.statusLabel,
    required this.subtitle,
    required this.mascotAsset,
  });
}

const _themeRendah = _CategoryTheme(
  accent: Color(0xFF0CFFE1),
  accentDim: Color(0xFF0DD9C0),
  bgBlend: Color(0xFF062520),
  glow: Color(0xFF0CFFE1),
  statusLabel: 'Pola Hidup Sehat',
  subtitle: 'Hebat! Kamu menjaga keseimbangan digitalmu dengan baik.',
  mascotAsset: 'assets/images/Maskot_Rendah.png',
);

const _themeSedang = _CategoryTheme(
  accent: Color(0xFFFFB830),
  accentDim: Color(0xFFE0A020),
  bgBlend: Color(0xFF1E1500),
  glow: Color(0xFFFFB830),
  statusLabel: 'Perlu Perhatian',
  subtitle: 'Aktivitas digitalmu mulai perlu diseimbangkan.',
  mascotAsset: 'assets/images/Maskot_Sedang.png',
);

const _themeTinggi = _CategoryTheme(
  accent: Color(0xFFFF4D6A),
  accentDim: Color(0xFFE03050),
  bgBlend: Color(0xFF200D16),
  glow: Color(0xFFFF4D6A),
  statusLabel: 'Risiko Ketergantungan',
  subtitle: 'Aktivitas digitalmu sangat intens.\nSaatnya memberi dirimu jeda.',
  mascotAsset: 'assets/images/Maskot_Tinggi.png',
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
          ..color = accent.withValues(alpha: op * 0.20)
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
    const sw = 7.0;
    const start = -math.pi / 2;

    for (var i = 0; i < 40; i++) {
      final a = i / 40 * math.pi * 2 - math.pi / 2;
      canvas.drawCircle(
        Offset(c.dx + (r + 11) * math.cos(a), c.dy + (r + 11) * math.sin(a)),
        1.0,
        Paint()..color = accent.withValues(alpha: 0.18),
      );
    }

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

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      start,
      sweep,
      false,
      Paint()
        ..color = accent.withValues(alpha: 0.22 * glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw + 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

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

// ─── Mascot Widgets ───────────────────────────────────────────────────────────

class _MascotImage extends StatelessWidget {
  final String asset;
  final double size;
  final double t;
  const _MascotImage({required this.asset, required this.size, this.t = 0});

  @override
  Widget build(BuildContext context) {
    final offset = math.sin(t * math.pi * 2) * 5;
    return Transform.translate(
      offset: Offset(0, offset),
      child: Image.asset(asset, width: size, height: size, fit: BoxFit.contain),
    );
  }
}

class _MiniMascot extends StatelessWidget {
  final String asset;
  final double size;
  const _MiniMascot({required this.asset, required this.size});

  @override
  Widget build(BuildContext context) =>
      Image.asset(asset, width: size, height: size, fit: BoxFit.contain);
}

// ─── Shared: Accent Divider ───────────────────────────────────────────────────

class _AccentDivider extends StatelessWidget {
  final Color accent;
  const _AccentDivider({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  accent.withValues(alpha: .25),
                  accent.withValues(alpha: .40),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: .60),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: .40),
                  accent.withValues(alpha: .25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared: Dark Section Header ──────────────────────────────────────────────

class _DarkSectionHeader extends StatelessWidget {
  final String title;
  final _CategoryTheme theme;
  final Widget? trailing;
  const _DarkSectionHeader({
    required this.title,
    required this.theme,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.accent, theme.accent.withValues(alpha: .25)],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: _white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: .2,
          ),
        ),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UNIFIED DARK SECTION  (gradient biru → putih)
// ─────────────────────────────────────────────────────────────────────────────

class _UnifiedDarkSection extends StatefulWidget {
  final MlResultModel data;
  const _UnifiedDarkSection({required this.data});

  @override
  State<_UnifiedDarkSection> createState() => _UnifiedDarkSectionState();
}

class _UnifiedDarkSectionState extends State<_UnifiedDarkSection>
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
      40,
      (_) => _FP(
        rng.nextDouble(),
        rng.nextDouble(),
        rng.nextDouble() * 2.5 + 0.8,
        (rng.nextDouble() - .5) * .3,
        (rng.nextDouble() - .5) * .3,
        rng.nextDouble() * .30 + .08,
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
                // ── GRADIENT BIRU GELAP (atas) → PUTIH (bawah) ──────────
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _darkTop,                                        // biru gelap
                    _darkMid,                                        // biru sedang
                    Color.lerp(_darkMid, theme.bgBlend, 0.40)!,     // biru+blend
                    const Color(0xFF0D3255),                         // biru medium
                    const Color(0xFF1A5A8A),                         // biru terang
                    const Color(0xFF5B9EC9),                         // biru muda
                    const Color(0xFFB8D9EF),                         // biru sangat muda
                    const Color(0xFFE8F4FB),                         // almost white
                    const Color(0xFFFFFFFF),                         // putih murni
                  ],
                  stops: const [0.0, 0.12, 0.25, 0.38, 0.52, 0.66, 0.80, 0.91, 1.0],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.glow.withValues(alpha: .12 * _glowA.value),
                    blurRadius: 40,
                    spreadRadius: 2,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Ambient blur orbs (hanya di area atas/gelap) ──────
                  Positioned(
                    top: -60,
                    right: -60,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.accent.withValues(alpha: .07 * _glowA.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.accent.withValues(alpha: .04 * _glowA.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Floating particles (hanya area atas ~50%) ─────────
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 500,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(0),
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

                  // ── Content ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 52, 20, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 1. TOP BAR ─────────────────────────────────
                        _TopBar(theme: theme),

                        const SizedBox(height: 28),

                        // ── 2. SCORE ORB ───────────────────────────────
                        _ScoreRow(
                          displayScore: displayScore,
                          category: _capitalize(data.category),
                          pct: _progressA.value * pct,
                          theme: theme,
                          glow: _glowA.value,
                          particleT: _particle.value,
                        ),

                        const SizedBox(height: 16),

                        // ── 3. STATUS TEXT ─────────────────────────────
                        Text(
                          'Digital Balance: ${theme.statusLabel}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .2,
                            shadows: [
                              Shadow(
                                color: theme.accent.withValues(
                                  alpha: .22 * _glowA.value,
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
                          style: TextStyle(
                            color: _white.withValues(alpha: .55),
                            fontSize: 12.5,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── 4. DIVIDER ─────────────────────────────────
                        _AccentDivider(accent: theme.accent),

                        const SizedBox(height: 24),

                        // ── 5. FACTOR PILLS ────────────────────────────
                        _DarkSectionHeader(
                          title: 'Faktor Risiko',
                          theme: theme,
                        ),
                        const SizedBox(height: 14),
                        _DarkFactorPills(theme: theme),

                        const SizedBox(height: 24),

                        // ── 7. DIVIDER ─────────────────────────────────
                        _AccentDivider(accent: theme.accent),

                        const SizedBox(height: 24),

                        // ── 8. ANALISIS AI (dipindah ke ATAS rekomendasi) ─
                        if (data.pembukaan.isNotEmpty) ...[
                          _AiAnalysisHeader(theme: theme),
                          const SizedBox(height: 14),
                          _DarkAiCard(
                            data: data,
                            theme: theme,
                            glow: _glowA.value,
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── 9. REKOMENDASI AI ──────────────────────────
                        _RekoHeader(theme: theme),
                        const SizedBox(height: 14),
                        ...data.rekomendasi.asMap().entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _GlassRecommendationCard(
                              item: e.value,
                              index: e.key,
                              theme: theme,
                              glow: _glowA.value,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── 10. DIVIDER ────────────────────────────────
                        _AccentDividerLight(accent: theme.accent),

                        const SizedBox(height: 24),

                        // ── 11. CTA BUTTONS ────────────────────────────
                        _DarkCtaButtons(theme: theme, glow: _glowA.value),

                        const SizedBox(height: 12),

                        // ── 12. HISTORY BUTTON ─────────────────────────
                        _DarkHistoriButton(theme: theme),
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

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final _CategoryTheme theme;
  const _TopBar({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavBtn(onTap: () => Navigator.pop(context), accent: theme.accent),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hasil Analisis',
              style: TextStyle(
                color: _white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Machine Learning AI',
              style: TextStyle(
                color: _white.withValues(alpha: .45),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: .8,
              ),
            ),
          ],
        ),
        const Spacer(),
        _MiniMascot(asset: theme.mascotAsset, size: 42),
      ],
    );
  }
}

// ─── Score Row ────────────────────────────────────────────────────────────────

class _ScoreRow extends StatelessWidget {
  final int displayScore;
  final String category;
  final double pct;
  final _CategoryTheme theme;
  final double glow;
  final double particleT;

  const _ScoreRow({
    required this.displayScore,
    required this.category,
    required this.pct,
    required this.theme,
    required this.glow,
    required this.particleT,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MascotImage(asset: theme.mascotAsset, size: 60, t: particleT),
              const SizedBox(height: 6),
              _Sparkle(size: 8, color: theme.accent, phase: .2, t: particleT),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _ScoreOrb(
          score: displayScore,
          category: category,
          pct: pct,
          theme: theme,
          glow: glow,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Sparkle(size: 14, color: theme.accent, phase: 0, t: particleT),
              const SizedBox(height: 10),
              _Sparkle(
                size: 9,
                color: theme.accent.withValues(alpha: .6),
                phase: .4,
                t: particleT,
              ),
              const SizedBox(height: 6),
              _Sparkle(
                size: 6,
                color: theme.accent.withValues(alpha: .35),
                phase: .7,
                t: particleT,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── AI Analysis Header ───────────────────────────────────────────────────────

class _AiAnalysisHeader extends StatelessWidget {
  final _CategoryTheme theme;
  const _AiAnalysisHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.accent, theme.accent.withValues(alpha: .25)],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Analisis AI',
          style: TextStyle(
            color: _white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: .2,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.accent.withValues(alpha: .10),
            border: Border.all(color: theme.accent.withValues(alpha: .20)),
          ),
          child: Text(
            'Powered by AI',
            style: TextStyle(
              color: theme.accent,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: .4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Rekomendasi Header ───────────────────────────────────────────────────────

class _RekoHeader extends StatelessWidget {
  final _CategoryTheme theme;
  const _RekoHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.accent, theme.accent.withValues(alpha: .25)],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Rekomendasi AI',
          style: const TextStyle(
            color: _white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: .2,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.accent.withValues(alpha: .15),
            border: Border.all(color: theme.accent.withValues(alpha: .30)),
          ),
          child: Text(
            'AI Powered',
            style: TextStyle(
              color: theme.accentDim,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: .4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Glassmorphism Recommendation Card ────────────────────────────────────────

class _GlassRecommendationCard extends StatelessWidget {
  final RecommendationItem item;
  final int index;
  final _CategoryTheme theme;
  final double glow;

  const _GlassRecommendationCard({
    required this.item,
    required this.index,
    required this.theme,
    required this.glow,
  });

  static const _tagMeta = <String, (IconData, String)>{
    'social_media': (Icons.smartphone_rounded, 'Screen Time Tinggi'),
    'sleep': (Icons.nightlight_round, 'Kurang Tidur'),
    'exercise': (Icons.directions_run_rounded, 'Aktivitas Fisik'),
    'notification': (Icons.notifications_off_rounded, 'Notifikasi Berlebih'),
    'notifications': (Icons.notifications_off_rounded, 'Notifikasi Berlebih'),
    'screen_time': (Icons.timer_off_rounded, 'Screen Time'),
    'stress': (Icons.favorite_rounded, 'Kelola Stres'),
    'general': (Icons.auto_awesome_rounded, 'Rekomendasi'),
  };

  @override
  Widget build(BuildContext context) {
    final meta = _tagMeta[item.tag] ?? _tagMeta['general']!;
    final icon = meta.$1;
    final title = meta.$2;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        // Card di area terang: pakai putih dengan border accent
        color: _white.withValues(alpha: .85),
        border: Border.all(
          color: theme.accent.withValues(alpha: .25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.glow.withValues(alpha: .08 * glow),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 12,
            bottom: 12,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.accent.withValues(alpha: .90),
                    theme.accent.withValues(alpha: .25),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.glow.withValues(alpha: .30),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.accent.withValues(alpha: .12),
                    border: Border.all(
                      color: theme.accent.withValues(alpha: .22),
                    ),
                  ),
                  child: Icon(icon, color: theme.accentDim, size: 20),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.accentDim,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.isi,
                        style: const TextStyle(
                          color: Color(0xFF2C3E50),
                          fontSize: 12.5,
                          height: 1.55,
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

// ─── AI Analysis Card ─────────────────────────────────────────────────────────

class _DarkAiCard extends StatelessWidget {
  final MlResultModel data;
  final _CategoryTheme theme;
  final double glow;
  const _DarkAiCard({
    required this.data,
    required this.theme,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: _darkCard.withValues(alpha: .70),
        border: Border.all(color: theme.accent.withValues(alpha: .18)),
        boxShadow: [
          BoxShadow(
            color: theme.glow.withValues(alpha: .10 * glow),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.accent.withValues(alpha: .10),
                    border: Border.all(
                      color: theme.accent.withValues(alpha: .20),
                    ),
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    color: theme.accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analisis AI',
                      style: TextStyle(
                        color: _white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Powered by Activa Intelligence',
                      style: TextStyle(
                        color: theme.accent.withValues(alpha: .70),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: .5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _MiniMascot(asset: theme.mascotAsset, size: 30),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: _white.withValues(alpha: .06)),
            const SizedBox(height: 12),
            Text(
              data.pembukaan,
              style: TextStyle(
                color: _white.withValues(alpha: .72),
                fontSize: 13,
                height: 1.70,
                letterSpacing: .1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Accent Divider (versi terang untuk area putih) ───────────────────────────

class _AccentDividerLight extends StatelessWidget {
  final Color accent;
  const _AccentDividerLight({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  accent.withValues(alpha: .20),
                  accent.withValues(alpha: .35),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: .50),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: .35),
                  accent.withValues(alpha: .20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Dark Factor Pills ────────────────────────────────────────────────────────

class _DarkFactorPills extends StatelessWidget {
  final _CategoryTheme theme;
  const _DarkFactorPills({required this.theme});

  static const _pills = [
    (Icons.smartphone_rounded, 'Screen Time'),
    (Icons.nightlight_round, 'Malam Hari'),
    (Icons.bed_rounded, 'Kurang Tidur'),
    (Icons.notifications_rounded, 'Notifikasi'),
    (Icons.sports_esports_rounded, 'Gaming'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _pills.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final (icon, label) = _pills[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: _darkCard.withValues(alpha: .80),
              border: Border.all(
                color: theme.accent.withValues(alpha: .22),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.glow.withValues(alpha: .06),
                  blurRadius: 6,
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
                    color: _white.withValues(alpha: .80),
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



// ─── CTA Buttons (area putih — warna disesuaikan) ────────────────────────────

class _DarkCtaButtons extends StatelessWidget {
  final _CategoryTheme theme;
  final double glow;
  const _DarkCtaButtons({required this.theme, required this.glow});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary CTA
        Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [theme.accent, theme.accentDim.withValues(alpha: .80)],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.glow.withValues(alpha: .30 * glow),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
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
        const SizedBox(height: 10),
        // Secondary CTA
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: _white,
            border: Border.all(
              color: theme.accent.withValues(alpha: .50),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.glow.withValues(alpha: .10 * glow),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KuesionerScreen()),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, color: theme.accentDim, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Ulangi Analisis',
                    style: TextStyle(
                      color: theme.accentDim,
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

// ─── History Button (area putih) ──────────────────────────────────────────────

class _DarkHistoriButton extends StatelessWidget {
  final _CategoryTheme theme;
  const _DarkHistoriButton({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFF0F4F8),
        border: Border.all(
          color: const Color(0xFFCDD8E3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoriScreen()),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_rounded, color: theme.accentDim, size: 22),
              const SizedBox(width: 10),
              const Text(
                'Lihat Riwayat Analisis',
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 14,
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

// ─── Nav Button ───────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Color accent;
  const _NavBtn({required this.onTap, required this.accent});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: .08),
        border: Border.all(color: accent.withValues(alpha: .22)),
      ),
      child: Icon(Icons.arrow_back_ios_new_rounded, color: accent, size: 14),
    ),
  );
}

// ─── Score Orb ────────────────────────────────────────────────────────────────

class _ScoreOrb extends StatelessWidget {
  final int score;
  final String category;
  final double pct;
  final _CategoryTheme theme;
  final double glow;
  const _ScoreOrb({
    required this.score,
    required this.category,
    required this.pct,
    required this.theme,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    const orbSize = 186.0;
    const innerSize = orbSize * 0.62;

    return SizedBox(
      width: orbSize,
      height: orbSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: orbSize,
            height: orbSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.glow.withValues(alpha: .18 * glow),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(orbSize, orbSize),
            painter: _RingPainter(
              progress: pct,
              accent: theme.accent,
              glow: glow,
            ),
          ),
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color.lerp(_darkMid, theme.accent, 0.04)!, _darkMid],
              ),
              border: Border.all(
                color: theme.accent.withValues(alpha: .16),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.glow.withValues(alpha: .10 * glow),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 8,
                  left: 12,
                  child: Container(
                    width: innerSize * .4,
                    height: innerSize * .26,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _white.withValues(alpha: .05),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        color: theme.accent,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -3,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: theme.glow.withValues(alpha: .45 * glow),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: theme.accent.withValues(alpha: .12),
                        border: Border.all(
                          color: theme.accent.withValues(alpha: .28),
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
          colors: [_darkTop, _darkMid],
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
                  color: _darkCard,
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
                  color: _white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tidak dapat memuat hasil analisis.\nCoba kembali ke kuesioner.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _white.withValues(alpha: .60),
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
                    borderRadius: BorderRadius.circular(16),
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
                        borderRadius: BorderRadius.circular(16),
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
// Main Screen
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
      backgroundColor: _lightBg,
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _UnifiedDarkSection(data: data),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}