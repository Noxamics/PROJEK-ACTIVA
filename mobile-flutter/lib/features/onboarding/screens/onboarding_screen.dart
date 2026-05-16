import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/announcement_provider.dart';
import '../models/announcement_model.dart';

// ─────────────────────────────────────────────────────────────
//  DigitalLife Analyzer – Onboarding Screen (3 slides)
//  Requires: google_fonts
// ─────────────────────────────────────────────────────────────

// ── Colour tokens (inline — tidak perlu import app_colors) ───
const _kNavy = Color(0xFF0B1133);
const _kTeal = Color(0xFF0EA982);
const _kGreen = Color(0xFF1BC06A);
const _kBgWrap = Color(0xFFD6E4F0);
const _kBgCard = Color(0xFFE8EEF8);
const _kDotInactive = Color(0x260B1133); // 15 % navy

// ─────────────────────────────────────────────────────────────
//  Data model
// ─────────────────────────────────────────────────────────────
class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.description,
    required this.illustration,
  });
  final String title;
  final String description;
  final Widget illustration;
}

// ─────────────────────────────────────────────────────────────
//  OnboardingScreen
// ─────────────────────────────────────────────────────────────
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _slides = const [
    _OnboardingData(
      title: 'Analisis Kebiasaan\nDigitalmu',
      description:
          'Isi kuesioner singkat dan sistem AI kami akan menghitung Digital Dependence Score kamu secara akurat.',
      illustration: _IllusAnalysis(),
    ),
    _OnboardingData(
      title: 'Pantau Tren\nPerkembanganmu',
      description:
          'Lihat grafik tren ketergantungan digital kamu dari waktu ke waktu dan bandingkan dengan periode sebelumnya.',
      illustration: _IllusTrend(),
    ),
    _OnboardingData(
      title: 'Dapatkan Insight\n& Rekomendasi AI',
      description:
          'Chatbot AI kami memberikan rekomendasi personal berdasarkan score dan kebiasaan digital kamu secara langsung.',
      illustration: _IllusInsight(),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateOut();
    }
  }

  void _skip() => _navigateOut();

  void _navigateOut() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  bool get _isLastPage => _currentPage == _slides.length - 1;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgWrap,
      body: SafeArea(
        child: Column(
          children: [
            // ── Announcements Section ─────────────────────────
            _buildAnnouncements(),

            // ── Slide area ────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _OnboardingCard(data: _slides[i]),
              ),
            ),

            // ── Bottom controls ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot indicator
                  _DotRow(total: _slides.length, active: _currentPage),
                  const SizedBox(height: 20),

                  // Buttons
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isLastPage
                        ? _StartButton(key: const ValueKey('start'), onTap: _navigateOut)
                        : _NavRow(key: const ValueKey('nav'), onSkip: _skip, onNext: _nextPage),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncements() {
    final announcementAsync = ref.watch(announcementProvider);

    return announcementAsync.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kTeal.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.campaign_outlined, color: _kTeal, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'PENGUMUMAN TERBARU',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _kTeal,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 45,
                child: PageView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kNavy,
                          ),
                        ),
                        Text(
                          item.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: _kNavy.withOpacity(0.6),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Single onboarding card (fills the PageView slot)
// ─────────────────────────────────────────────────────────────
class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({required this.data});
  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _kBgCard,
          borderRadius: BorderRadius.circular(32),
        ),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        child: Column(
          children: [
            // Illustration box
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: _kNavy,
                borderRadius: BorderRadius.circular(22),
              ),
              child: data.illustration,
            ),

            const SizedBox(height: 28),

            // Title
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _kNavy,
                height: 1.28,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              data.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: _kNavy.withOpacity(0.55),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Dot row indicator
// ─────────────────────────────────────────────────────────────
class _DotRow extends StatelessWidget {
  const _DotRow({required this.total, required this.active});
  final int total;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == active;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isActive ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive ? _kTeal : _kDotInactive,
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Navigation row (Lewati + Lanjut)
// ─────────────────────────────────────────────────────────────
class _NavRow extends StatelessWidget {
  const _NavRow({super.key, required this.onSkip, required this.onNext});
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Skip
        TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(
            foregroundColor: _kNavy.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          child: Text(
            'LEWATI',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Next
        _PillButton(
          label: 'LANJUT',
          color: _kNavy,
          onTap: onNext,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Start button (last slide, full width)
// ─────────────────────────────────────────────────────────────
class _StartButton extends StatelessWidget {
  const _StartButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _PillButton(
        label: 'MULAI SEKARANG',
        color: _kTeal,
        onTap: onTap,
        fullWidth: true,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Reusable pill button
// ─────────────────────────────────────────────────────────────
class _PillButton extends StatefulWidget {
  const _PillButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) async {
          await _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.fullWidth ? 0 : 22,
            vertical: 13,
          ),
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Illustration 1 – Analisis Kebiasaan Digital
// ─────────────────────────────────────────────────────────────
class _IllusAnalysis extends StatelessWidget {
  const _IllusAnalysis();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AnalysisPainter(),
    );
  }
}

class _AnalysisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── Avatar circle (top) ──────────────────────────────────
    final circleBg = Paint()..color = _kTeal.withOpacity(0.15);
    canvas.drawCircle(Offset(cx, cy - 44), 28, circleBg);
    final circleFg = Paint()..color = _kTeal.withOpacity(0.55);
    canvas.drawCircle(Offset(cx, cy - 44), 18, circleFg);

    // ── Profile card (bottom) ────────────────────────────────
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 26), width: 160, height: 68),
      const Radius.circular(12),
    );
    final cardPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(cardRect, cardPaint);
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = _kTeal.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Badge row inside card
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 76, cy + 6, 44, 10),
      const Radius.circular(5),
    );
    canvas.drawRRect(badgeRect, Paint()..color = _kTeal.withOpacity(0.7));

    // Text lines
    _drawLine(canvas, Offset(cx - 76, cy + 22), 72, Colors.white.withOpacity(0.25), 7);
    _drawLine(canvas, Offset(cx - 76, cy + 34), 52, Colors.white.withOpacity(0.15), 7);

    // Mini score card (right side)
    final scoreRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx + 10, cy + 6, 46, 46),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      scoreRect,
      Paint()..color = _kGreen.withOpacity(0.2),
    );
    canvas.drawRRect(
      scoreRect,
      Paint()
        ..color = _kGreen.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Score text "92"
    final tp = TextPainter(
      text: TextSpan(
        text: '92',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _kGreen,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx + 10 + (46 - tp.width) / 2, cy + 6 + (46 - tp.height) / 2));

    // AI badge (top-right of avatar)
    final aiBadge = Paint()
      ..color = _kTeal.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + 38, cy - 62), 12, aiBadge);
    canvas.drawCircle(
      Offset(cx + 38, cy - 62),
      12,
      Paint()
        ..color = _kTeal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final aiTp = TextPainter(
      text: TextSpan(
        text: 'AI',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: _kTeal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    aiTp.paint(canvas, Offset(cx + 38 - aiTp.width / 2, cy - 62 - aiTp.height / 2));
  }

  void _drawLine(Canvas canvas, Offset start, double width, Color color, double height) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(start.dx, start.dy, width, height),
        const Radius.circular(3.5),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────
//  Illustration 2 – Pantau Tren
// ─────────────────────────────────────────────────────────────
class _IllusTrend extends StatelessWidget {
  const _IllusTrend();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _TrendPainter());
  }
}

class _TrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Chart frame
    final frame = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 10), width: size.width * 0.78, height: 90),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      frame,
      Paint()..color = Colors.white.withOpacity(0.06),
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..color = _kTeal.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Bar chart
    final barW = 16.0;
    final barGap = 18.0;
    final baseY = cy + 50.0;
    final barData = [
      (height: 40.0, color: Colors.white.withOpacity(0.18)),
      (height: 30.0, color: _kTeal.withOpacity(0.5)),
      (height: 50.0, color: Colors.white.withOpacity(0.25)),
      (height: 68.0, color: _kTeal),
    ];
    double bx = cx - (barData.length * (barW + barGap) - barGap) / 2;
    for (final d in barData) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, baseY - d.height, barW, d.height),
          const Radius.circular(4),
        ),
        Paint()..color = d.color,
      );
      bx += barW + barGap;
    }

    // Line overlay
    final points = [
      Offset(cx - 60, baseY - 30),
      Offset(cx - 26, baseY - 22),
      Offset(cx + 8, baseY - 40),
      Offset(cx + 42, baseY - 68),
    ];
    final linePaint = Paint()
      ..color = _kGreen
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);
    canvas.drawCircle(points.last, 5, Paint()..color = _kGreen);

    // Badge chip (top)
    final chipRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 46), width: 140, height: 22),
      const Radius.circular(11),
    );
    canvas.drawRRect(chipRect, Paint()..color = _kTeal.withOpacity(0.15));
    canvas.drawRRect(
      chipRect,
      Paint()
        ..color = _kTeal.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    final chipTp = TextPainter(
      text: TextSpan(
        text: 'Score menurun 8% ↓',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _kTeal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    chipTp.paint(canvas, Offset(cx - chipTp.width / 2, cy - 46 - chipTp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────
//  Illustration 3 – Insight & Rekomendasi AI
// ─────────────────────────────────────────────────────────────
class _IllusInsight extends StatelessWidget {
  const _IllusInsight();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _InsightPainter());
  }
}

class _InsightPainter extends CustomPainter {
  void _drawLine(Canvas canvas, Offset start, double width, Color color, double height) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(start.dx, start.dy, width, height),
        const Radius.circular(3.5),
      ),
      Paint()..color = color,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Main card
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.8, height: 110),
      const Radius.circular(14),
    );
    canvas.drawRRect(cardRect, Paint()..color = Colors.white.withOpacity(0.06));
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = _kTeal.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Text lines (left side)
    _drawLine(canvas, Offset(cx - size.width * 0.37, cy - 28), 80, Colors.white.withOpacity(0.2), 8);
    _drawLine(canvas, Offset(cx - size.width * 0.37, cy - 16), 56, Colors.white.withOpacity(0.12), 6);
    _drawLine(canvas, Offset(cx - size.width * 0.37, cy - 7), 64, Colors.white.withOpacity(0.12), 6);

    // Checkbox (right side)
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx + size.width * 0.1, cy - 36, 38, 38),
      const Radius.circular(8),
    );
    canvas.drawRRect(boxRect, Paint()..color = _kTeal.withOpacity(0.25));
    canvas.drawRRect(
      boxRect,
      Paint()
        ..color = _kTeal.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Checkmark
    final checkPaint = Paint()
      ..color = _kTeal
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final bx = cx + size.width * 0.1;
    final by = cy - 36;
    final checkPath = Path()
      ..moveTo(bx + 8, by + 20)
      ..lineTo(bx + 14, by + 26)
      ..lineTo(bx + 28, by + 14);
    canvas.drawPath(checkPath, checkPaint);

    // CTA bar (bottom of card)
    final ctaRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        cx - size.width * 0.37,
        cy + 14,
        size.width * 0.74,
        24,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(ctaRect, Paint()..color = _kTeal.withOpacity(0.85));

    final ctaTp = TextPainter(
      text: TextSpan(
        text: 'Lihat Rekomendasi AI',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    ctaTp.paint(canvas, Offset(cx - ctaTp.width / 2, cy + 14 + (24 - ctaTp.height) / 2));

    // Notification badge (top-right)
    canvas.drawCircle(
      Offset(cx + size.width * 0.32, cy - 52),
      14,
      Paint()..color = _kGreen,
    );
    final badgeTp = TextPainter(
      text: TextSpan(
        text: '3',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    badgeTp.paint(
      canvas,
      Offset(
        cx + size.width * 0.32 - badgeTp.width / 2,
        cy - 52 - badgeTp.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}