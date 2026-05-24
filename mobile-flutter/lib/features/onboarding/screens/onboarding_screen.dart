import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/screens/login_screen.dart';
import '../providers/announcement_provider.dart';

// ─────────────────────────────────────────────────────────────
//  Activa – Premium Onboarding Screen (4 slides)
//  Mascot images: assets/images/maskot1..4.png
//  Requires: google_fonts, flutter_riverpod
// ─────────────────────────────────────────────────────────────

// ── Colour tokens ─────────────────────────────────────────────
const _kNavyDark = Color(0xFF0A1628);
const _kTeal = Color(0xFF0D9488);
const _kTealLight = Color(0xFF5EEAD4);
const _kYellow = Color(0xFFFACC15);
const _kPurple = Color(0xFF7C83FD);
const _kStarWhite = Color(0xFFFFFFFF);

// Consistent subtitle colour across all slides
const _kSubtitle = Color(0xFF8BBFD4);

// ─────────────────────────────────────────────────────────────
//  Slide data model
// ─────────────────────────────────────────────────────────────
class _SlideData {
  const _SlideData({
    required this.tag,
    required this.tagColor,
    required this.tagBg,
    required this.headline,
    required this.subtitle,
    required this.mascotAsset,
    required this.backgroundBuilder,
    required this.contentBg,
    required this.headlineColor,
    required this.subtitleColor,
    required this.nextBtnColor,
    required this.skipColor,
    required this.dotActiveColor,
    required this.dotInactiveColor,
    this.isLastSlide = false,
  });

  final String tag;
  final Color tagColor;
  final Color tagBg;
  final String headline;
  final String subtitle;
  final String mascotAsset;
  final Widget Function(BuildContext) backgroundBuilder;
  final Color contentBg;
  final Color headlineColor;
  final Color subtitleColor;
  final Color nextBtnColor;
  final Color skipColor;
  final Color dotActiveColor;
  final Color dotInactiveColor;
  final bool isLastSlide;
}

// ─────────────────────────────────────────────────────────────
//  OnboardingScreen
// ─────────────────────────────────────────────────────────────
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  late final AnimationController _particleCtrl;

  // ── Slide definitions ─────────────────────────────────────
  late final List<_SlideData> _slides = [
    // SLIDE 1 — Digital Awareness
    _SlideData(
      tag: 'Digital Awareness',
      tagColor: _kTealLight,
      tagBg: const Color(0x260D9488),
      headline: 'Kenali pola\ndigitalmu',
      subtitle:
          'Kebiasaan kecil setiap hari bisa\nmemengaruhi fokus dan tidurmu.',
      mascotAsset: 'assets/images/Maskot1.png',
      backgroundBuilder: (_) => const _S1Background(),
      contentBg: _kNavyDark,
      headlineColor: _kStarWhite,
      subtitleColor: _kSubtitle,
      nextBtnColor: _kTeal,
      skipColor: _kStarWhite,
      dotActiveColor: _kTeal,
      dotInactiveColor: const Color(0x40FFFFFF),
    ),

    // SLIDE 2 — Self Reflection
    _SlideData(
      tag: 'Self Reflection',
      tagColor: _kTealLight,
      tagBg: const Color(0x257C83FD),
      headline: 'Tidak semua\nscreen time itu buruk',
      subtitle:
          'Activa membantu memahami\nkebiasaan digitalmu tanpa menghakimi.',
      mascotAsset: 'assets/images/Maskot2.png',
      backgroundBuilder: (_) => const _S2Background(),
      contentBg: _kNavyDark,
      headlineColor: _kStarWhite,
      subtitleColor: _kSubtitle,
      nextBtnColor: _kTeal,
      skipColor: _kStarWhite,
      dotActiveColor: _kTeal,
      dotInactiveColor: const Color(0x40FFFFFF),
    ),

    // SLIDE 3 — Digital Balance
    _SlideData(
      tag: 'Digital Balance',
      tagColor: _kTealLight,
      tagBg: const Color(0x200D9488),
      headline: 'Kadang kita\nhanya perlu jeda',
      subtitle: 'Screen time, tidur, dan media sosial\nbisa lebih seimbang.',
      mascotAsset: 'assets/images/Maskot3.png',
      backgroundBuilder: (_) => const _S3Background(),
      contentBg: const Color(0xFF0A1628),
      headlineColor: _kStarWhite,
      subtitleColor: _kSubtitle,
      nextBtnColor: _kTeal,
      skipColor: _kStarWhite,
      dotActiveColor: _kTeal,
      dotInactiveColor: const Color(0x40FFFFFF),
    ),

    // SLIDE 4 — Start Journey
    _SlideData(
      tag: 'Mulai Sekarang',
      tagColor: _kYellow,
      tagBg: const Color(0x26FACC15),
      headline: 'Mulai perjalanan\ndigital wellness kamu',
      subtitle:
          'Pantau perkembangan dan pahami\npola digitalmu bersama Activa.',
      mascotAsset: 'assets/images/Maskot4.png',
      backgroundBuilder: (_) => const _S4Background(),
      contentBg: const Color(0xFF0A1628),
      headlineColor: _kStarWhite,
      subtitleColor: _kSubtitle,
      nextBtnColor: _kTeal,
      skipColor: const Color(0x66FFFFFF),
      dotActiveColor: _kTeal,
      dotInactiveColor: const Color(0x40FFFFFF),
      isLastSlide: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateOut();
    }
  }

  void _skip() => _navigateOut();

  void _navigateOut() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageCtrl,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (ctx, i) => _OnboardingPage(
                data: _slides[i],
                slideIndex: i,
                currentIndex: _currentPage,
                totalSlides: _slides.length,
                onNext: _nextPage,
                onSkip: _skip,
                announcementWidget: i == 0
                    ? _AnnouncementBanner(ref: ref)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Single onboarding page
// ─────────────────────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.slideIndex,
    required this.currentIndex,
    required this.totalSlides,
    required this.onNext,
    required this.onSkip,
    this.announcementWidget,
  });

  final _SlideData data;
  final int slideIndex;
  final int currentIndex;
  final int totalSlides;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Widget? announcementWidget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        data.backgroundBuilder(context),
        Column(
          children: [
            _TopBar(skipColor: data.skipColor, onSkip: onSkip),
            if (announcementWidget != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: announcementWidget!,
              ),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: _MascotZone(
                asset: data.mascotAsset,
                slideIndex: slideIndex,
              ),
            ),
            _ContentPanel(
              data: data,
              currentIndex: currentIndex,
              totalSlides: totalSlides,
              onNext: onNext,
              onSkip: onSkip,
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Top bar — logo always uses original SVG colours (no filter)
// ─────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.skipColor, required this.onSkip});

  final Color skipColor;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo — no colorFilter so the original SVG colours are preserved
          SvgPicture.asset('assets/logo/NewLogoPutih_fixed.svg', height: 32),
          GestureDetector(
            onTap: onSkip,
            child: Text(
              'Lewati',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: skipColor.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Mascot zone with subtle float animation
// ─────────────────────────────────────────────────────────────
class _MascotZone extends StatefulWidget {
  const _MascotZone({required this.asset, required this.slideIndex});
  final String asset;
  final int slideIndex;

  @override
  State<_MascotZone> createState() => _MascotZoneState();
}

class _MascotZoneState extends State<_MascotZone>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _float = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _float.value), child: child),
      child: Center(
        child: Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _kTeal.withOpacity(0.25),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Image.asset(
            widget.asset,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported_outlined,
              color: Colors.white24,
              size: 80,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Content wave panel
// ─────────────────────────────────────────────────────────────
class _ContentPanel extends StatelessWidget {
  const _ContentPanel({
    required this.data,
    required this.currentIndex,
    required this.totalSlides,
    required this.onNext,
    required this.onSkip,
  });

  final _SlideData data;
  final int currentIndex;
  final int totalSlides;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: data.contentBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        border: Border(
          top: BorderSide(color: _kTeal.withOpacity(0.15), width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TagChip(label: data.tag, color: data.tagColor, bg: data.tagBg),
          const SizedBox(height: 12),
          Text(
            data.headline,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: data.headlineColor,
              height: 1.18,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: data.subtitleColor,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 18),
          if (!data.isLastSlide)
            _NavRow(
              currentIndex: currentIndex,
              totalSlides: totalSlides,
              dotActiveColor: data.dotActiveColor,
              dotInactiveColor: data.dotInactiveColor,
              nextBtnColor: data.nextBtnColor,
              onNext: onNext,
            )
          else
            _LastSlideNav(
              currentIndex: currentIndex,
              totalSlides: totalSlides,
              dotActiveColor: data.dotActiveColor,
              dotInactiveColor: data.dotInactiveColor,
              onStart: onNext,
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Tag chip
// ─────────────────────────────────────────────────────────────
class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.color, required this.bg});
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Nav row
// ─────────────────────────────────────────────────────────────
class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.currentIndex,
    required this.totalSlides,
    required this.dotActiveColor,
    required this.dotInactiveColor,
    required this.nextBtnColor,
    required this.onNext,
  });

  final int currentIndex;
  final int totalSlides;
  final Color dotActiveColor;
  final Color dotInactiveColor;
  final Color nextBtnColor;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _DotIndicator(
          total: totalSlides,
          active: currentIndex,
          activeColor: dotActiveColor,
          inactiveColor: dotInactiveColor,
        ),
        _CircleNextButton(color: nextBtnColor, onTap: onNext),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Last slide nav
// ─────────────────────────────────────────────────────────────
class _LastSlideNav extends StatelessWidget {
  const _LastSlideNav({
    required this.currentIndex,
    required this.totalSlides,
    required this.dotActiveColor,
    required this.dotInactiveColor,
    required this.onStart,
  });

  final int currentIndex;
  final int totalSlides;
  final Color dotActiveColor;
  final Color dotInactiveColor;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _DotIndicator(
              total: totalSlides,
              active: currentIndex,
              activeColor: dotActiveColor,
              inactiveColor: dotInactiveColor,
            ),
            const SizedBox(),
          ],
        ),
        const SizedBox(height: 16),
        _StartButton(onTap: onStart),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Dot indicator
// ─────────────────────────────────────────────────────────────
class _DotIndicator extends StatelessWidget {
  const _DotIndicator({
    required this.total,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int total;
  final int active;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i == active;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Circular next button
// ─────────────────────────────────────────────────────────────
class _CircleNextButton extends StatefulWidget {
  const _CircleNextButton({required this.color, required this.onTap});
  final Color color;
  final VoidCallback onTap;

  @override
  State<_CircleNextButton> createState() => _CircleNextButtonState();
}

class _CircleNextButtonState extends State<_CircleNextButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Start (CTA) button — full width
// ─────────────────────────────────────────────────────────────
class _StartButton extends StatefulWidget {
  const _StartButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _kTeal.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Mulai Sekarang',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.east_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Announcement banner (slide 1 only)
// ─────────────────────────────────────────────────────────────
class _AnnouncementBanner extends StatelessWidget {
  const _AnnouncementBanner({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(announcementProvider);
    return async.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kTeal.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.campaign_outlined, color: _kTeal, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'PENGUMUMAN TERBARU',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: _kTeal,
                      letterSpacing: 0.9,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 42,
                child: PageView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final item = list[i];
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
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          item.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: Colors.white60,
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

// ═════════════════════════════════════════════════════════════
//  BACKGROUNDS
// ═════════════════════════════════════════════════════════════

// ── S1: Navy/Teal with floating particles ─────────────────────
class _S1Background extends StatelessWidget {
  const _S1Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D2040), Color(0xFF1E3A5F), Color(0xFF0F4A4A)],
            ),
          ),
        ),
        const _FloatingOrbs(
          orbs: [
            _OrbData(
              left: 0.08,
              top: 0.12,
              size: 80,
              color: Color(0x200D9488),
              delay: 0,
            ),
            _OrbData(
              left: 0.72,
              top: 0.05,
              size: 50,
              color: Color(0x207C83FD),
              delay: 800,
            ),
            _OrbData(
              left: 0.55,
              top: 0.35,
              size: 30,
              color: Color(0x30FACC15),
              delay: 400,
            ),
            _OrbData(
              left: 0.82,
              top: 0.28,
              size: 14,
              color: Color(0x805EEAD4),
              delay: 1200,
            ),
            _OrbData(
              left: 0.12,
              top: 0.50,
              size: 10,
              color: Color(0x80FFFFFF),
              delay: 600,
            ),
            _OrbData(
              left: 0.45,
              top: 0.08,
              size: 6,
              color: Color(0x805EEAD4),
              delay: 200,
            ),
          ],
        ),
      ],
    );
  }
}

// ── S2: Navy + purple accent ──────────────────────────────────
class _S2Background extends StatelessWidget {
  const _S2Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D1A35), Color(0xFF1A2A55), Color(0xFF0E1A40)],
            ),
          ),
        ),
        // Purple glow accent top-right
        Positioned(
          right: -40,
          top: -20,
          child: Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x207C83FD),
            ),
          ),
        ),
        // Teal glow blob bottom-left
        Positioned(
          left: -30,
          bottom: 100,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kTeal.withOpacity(0.10),
            ),
          ),
        ),
        const _FloatingOrbs(
          orbs: [
            _OrbData(
              left: 0.72,
              top: 0.06,
              size: 8,
              color: Color(0x707C83FD),
              delay: 0,
            ),
            _OrbData(
              left: 0.15,
              top: 0.18,
              size: 5,
              color: Color(0x505EEAD4),
              delay: 500,
            ),
            _OrbData(
              left: 0.55,
              top: 0.10,
              size: 6,
              color: Color(0x500D9488),
              delay: 250,
            ),
            _OrbData(
              left: 0.88,
              top: 0.28,
              size: 10,
              color: Color(0x307C83FD),
              delay: 900,
            ),
            _OrbData(
              left: 0.30,
              top: 0.40,
              size: 4,
              color: Color(0x60FFFFFF),
              delay: 700,
            ),
            _OrbData(
              left: 0.82,
              top: 0.08,
              size: 14,
              color: Color(0x405EEAD4),
              delay: 1200,
            ),
          ],
        ),
      ],
    );
  }
}

// ── S3: Deep night with twinkling stars ───────────────────────
class _S3Background extends StatelessWidget {
  const _S3Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF060E1F), Color(0xFF0D1B3E), Color(0xFF091A30)],
            ),
          ),
        ),
        const _StarField(),
        Positioned(
          right: 40,
          top: 80,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
            ),
            child: const Center(
              child: Text('🌙', style: TextStyle(fontSize: 22)),
            ),
          ),
        ),
        const _FloatingOrbs(
          orbs: [
            _OrbData(
              left: -0.08,
              top: 0.22,
              size: 120,
              color: Color(0x100D9488),
              delay: 0,
            ),
            _OrbData(
              left: 0.75,
              top: 0.12,
              size: 80,
              color: Color(0x107C83FD),
              delay: 700,
            ),
          ],
        ),
      ],
    );
  }
}

// ── S4: Deep premium dark ─────────────────────────────────────
class _S4Background extends StatelessWidget {
  const _S4Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A1628), Color(0xFF1E3A5F), Color(0xFF0D3333)],
            ),
          ),
        ),
        const _HoloCards(),
        const _FloatingOrbs(
          orbs: [
            _OrbData(
              left: 0.45,
              top: 0.07,
              size: 8,
              color: Color(0x80FACC15),
              delay: 300,
            ),
            _OrbData(
              left: 0.86,
              top: 0.42,
              size: 6,
              color: Color(0x805EEAD4),
              delay: 1100,
            ),
            _OrbData(
              left: 0.14,
              top: 0.50,
              size: 5,
              color: Color(0x80FFFFFF),
              delay: 700,
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Holographic floating stat cards (S4)
//
//  Layout changes:
//  • "Screen Time" → bottom area, center-right  (left: 0.45, top: 0.55)
//  • "Sleep Score" → top-right                  (left: 0.58, top: 0.12)
//  • "Focus"       → top-left                   (left: 0.04, top: 0.22)
// ─────────────────────────────────────────────────────────────
class _HoloCards extends StatelessWidget {
  const _HoloCards();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Screen Time — repositioned to bottom center-right
        _HoloCard(
          label: 'Screen Time',
          value: '4h 12m',
          valueColor: _kTealLight,
          left: 0.45,
          top: 0.55,
          delay: 0,
        ),
        // Sleep Score — stays top-right
        _HoloCard(
          label: 'Sleep Score',
          value: '82%',
          valueColor: _kYellow,
          left: 0.60,
          top: 0.12,
          delay: 600,
        ),
        // Focus — moved slightly to top-left to balance layout
        _HoloCard(
          label: 'Focus',
          value: '↑ 12%',
          valueColor: const Color(0xFFA5B4FC),
          left: 0.04,
          top: 0.22,
          delay: 300,
        ),
      ],
    );
  }
}

class _HoloCard extends StatefulWidget {
  const _HoloCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.left,
    required this.top,
    required this.delay,
  });
  final String label;
  final String value;
  final Color valueColor;
  final double left;
  final double top;
  final int delay;

  @override
  State<_HoloCard> createState() => _HoloCardState();
}

class _HoloCardState extends State<_HoloCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2600 + widget.delay),
    )..repeat(reverse: true);
    _float = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      left: size.width * widget.left,
      top: size.height * widget.top,
      child: AnimatedBuilder(
        animation: _float,
        builder: (_, child) =>
            Transform.translate(offset: Offset(0, _float.value), child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _kTeal.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kTeal.withOpacity(0.28), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: widget.valueColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Floating orbs (animated particles)
// ─────────────────────────────────────────────────────────────
class _OrbData {
  const _OrbData({
    required this.left,
    required this.top,
    required this.size,
    required this.color,
    required this.delay,
  });
  final double left;
  final double top;
  final double size;
  final Color color;
  final int delay;
}

class _FloatingOrbs extends StatelessWidget {
  const _FloatingOrbs({required this.orbs});
  final List<_OrbData> orbs;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: orbs.map((o) => _SingleOrb(data: o)).toList(),
    );
  }
}

class _SingleOrb extends StatefulWidget {
  const _SingleOrb({required this.data});
  final _OrbData data;

  @override
  State<_SingleOrb> createState() => _SingleOrbState();
}

class _SingleOrbState extends State<_SingleOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3200 + widget.data.delay),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      left: size.width * widget.data.left,
      top: size.height * widget.data.top,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, -10 * _anim.value),
          child: Opacity(
            opacity: 0.5 + 0.5 * _anim.value,
            child: Container(
              width: widget.data.size,
              height: widget.data.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.data.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Star field (S3 night mode)
// ─────────────────────────────────────────────────────────────
class _StarField extends StatelessWidget {
  const _StarField();

  static const _stars = [
    (l: 0.12, t: 0.06, s: 2.0, d: 0),
    (l: 0.68, t: 0.11, s: 3.0, d: 400),
    (l: 0.38, t: 0.18, s: 2.0, d: 800),
    (l: 0.84, t: 0.24, s: 4.0, d: 200),
    (l: 0.22, t: 0.30, s: 2.0, d: 1200),
    (l: 0.54, t: 0.08, s: 3.0, d: 600),
    (l: 0.90, t: 0.40, s: 2.0, d: 1800),
    (l: 0.06, t: 0.38, s: 2.0, d: 900),
    (l: 0.77, t: 0.35, s: 3.0, d: 100),
    (l: 0.30, t: 0.45, s: 2.0, d: 1500),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: _stars
          .map((s) => _TwinkleStar(left: s.l, top: s.t, size: s.s, delay: s.d))
          .toList(),
    );
  }
}

class _TwinkleStar extends StatefulWidget {
  const _TwinkleStar({
    required this.left,
    required this.top,
    required this.size,
    required this.delay,
  });
  final double left;
  final double top;
  final double size;
  final int delay;

  @override
  State<_TwinkleStar> createState() => _TwinkleStarState();
}

class _TwinkleStarState extends State<_TwinkleStar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800 + widget.delay),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrSize = MediaQuery.of(context).size;
    return Positioned(
      left: scrSize.width * widget.left,
      top: scrSize.height * widget.top,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Opacity(
          opacity: 0.2 + 0.8 * _ctrl.value,
          child: Container(
            width: widget.size * (0.8 + 0.4 * _ctrl.value),
            height: widget.size * (0.8 + 0.4 * _ctrl.value),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
