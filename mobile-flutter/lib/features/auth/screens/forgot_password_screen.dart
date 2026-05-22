import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/forgot_password_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_error_banner.dart';
import 'otp_screen.dart';

// ── Color constants ───────────────────────────────────────────────────────────
const _kNavy      = Color(0xFF1E3A5F);
const _kDarkNavy  = Color(0xFF0B1F3A);
const _kTeal      = Color(0xFF0D9488);
const _kIceWhite  = Color(0xFFF0F9FF);
const _kMint      = Color(0xFF99F6E4);
const _kPurple    = Color(0xFF7C83FD);

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  bool _emailValid = false;

  // ── Animation controllers ─────────────────────────────────────────────────
  late final AnimationController _heroFadeCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _cardSlideCtrl;
  late final AnimationController _buttonPressCtrl;
  late final AnimationController _particleCtrl;

  late final Animation<double> _heroFade;
  late final Animation<Offset> _floatOffset;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;
  late final Animation<double> _buttonScale;
  late final Animation<double> _particleRotate;

  @override
  void initState() {
    super.initState();

    _heroFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _heroFade = CurvedAnimation(parent: _heroFadeCtrl, curve: Curves.easeOut);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatOffset = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: const Offset(0, -0.04),
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _cardSlideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardSlideCtrl, curve: Curves.easeOutCubic));
    _cardFade = CurvedAnimation(parent: _cardSlideCtrl, curve: Curves.easeOut);

    _buttonPressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _buttonScale = _buttonPressCtrl;

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _particleRotate = CurvedAnimation(parent: _particleCtrl, curve: Curves.linear);

    // Stagger entry animations
    _heroFadeCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardSlideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _heroFadeCtrl.dispose();
    _floatCtrl.dispose();
    _cardSlideCtrl.dispose();
    _buttonPressCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  void _onEmailChanged(String val) {
    setState(() => _emailValid = val.contains('@') && val.contains('.'));
    ref.read(forgotPasswordProvider.notifier).clearError();
  }

  Future<void> _onSendOtp() async {
    if (!_emailValid) return;

    await _buttonPressCtrl.reverse();
    await _buttonPressCtrl.forward();

    final success = await ref
        .read(forgotPasswordProvider.notifier)
        .sendOtp(_emailController.text.trim());

    if (success && mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => const OtpScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 420),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(forgotPasswordProvider);
    final isLoading = state.isLoading;
    final errorMsg  = state.errorMessage;
    final screenH   = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: _kDarkNavy,
      body: Stack(
        children: [
          // ── Particle background ────────────────────────────────────────────
          Positioned.fill(child: _ParticleBackground(animation: _particleRotate)),

          // ── Main layout ───────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Hero section
                SizedBox(
                  height: screenH * 0.35,
                  child: _buildHeroSection(),
                ),

                // Form card
                Expanded(
                  child: _buildFormCard(
                    isLoading: isLoading,
                    errorMsg: errorMsg,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Section ───────────────────────────────────────────────────────────

  Widget _buildHeroSection() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Gradient background (identik register) ─────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D2040),
                Color(0xFF1E3A5F),
                Color(0xFF0F5050),
              ],
            ),
          ),
        ),

        // ── Soft orbs (identik register) ───────────────────────────────
        Positioned(
          top: 20,
          right: -20,
          child: _OrbWidget(80, _kTeal.withValues(alpha: 0.20)),
        ),
        Positioned(
          top: 10,
          left: -10,
          child: _OrbWidget(60, _kPurple.withValues(alpha: 0.18)),
        ),
        Positioned(
          bottom: 50,
          right: 40,
          child: _OrbWidget(40, const Color(0xFACC15).withValues(alpha: 0.20)),
        ),

        // ── Wave / U-terbalik bottom clip ──────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: _AuthWaveClipper(),
            child: Container(height: 40, color: _kIceWhite),
          ),
        ),

        // ── Content ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: back button + text
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button glass
                    _GlassBackButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(height: 14),

                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _kTeal.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _kMint.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_reset_rounded,
                            color: _kMint,
                            size: 13,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Pemulihan Akun',
                            style: TextStyle(
                              color: _kMint,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Headline
                    const Text(
                      'Lupa\nPassword?',
                      style: TextStyle(
                        color: _kIceWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Tenang, kami bantu kamu\nkembali ke Activa.',
                      style: TextStyle(
                        color: _kIceWhite.withValues(alpha: 0.62),
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),

              // Right: icon circle (pengganti mascot)
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                  border: Border.all(
                    color: _kMint.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: _kMint,
                  size: 38,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Form Card ──────────────────────────────────────────────────────────────

  Widget _buildFormCard({
    required bool isLoading,
    required String? errorMsg,
  }) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _kIceWhite,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 28),
                  decoration: BoxDecoration(
                    color: _kNavy.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Error banner
              if (errorMsg != null) ...[
                AuthErrorBanner(message: errorMsg),
                const SizedBox(height: 20),
              ],

              // Email label
              const Text(
                'Alamat Email',
                style: TextStyle(
                  color: _kNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),

              // Email input
              _PremiumEmailField(
                controller: _emailController,
                isValid: _emailValid,
                onChanged: _onEmailChanged,
              ),

              const SizedBox(height: 16),

              // OTP info card (glassmorphism style)
              _OtpInfoCard(),

              const SizedBox(height: 32),

              // Primary button
              ScaleTransition(
                scale: _buttonScale,
                child: _GradientOtpButton(
                  isLoading: isLoading,
                  isEnabled: _emailValid && !isLoading,
                  onPressed: _onSendOtp,
                ),
              ),

              const SizedBox(height: 24),

              // Footer link
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Ingat password?  ',
                          style: TextStyle(
                            color: _kNavy.withValues(alpha: 0.45),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const TextSpan(
                          text: 'Masuk sekarang',
                          style: TextStyle(
                            color: _kTeal,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
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

// ── Glassmorphism back button ─────────────────────────────────────────────────

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 19,
        ),
      ),
    );
  }
}

// ── Premium email input field ─────────────────────────────────────────────────

class _PremiumEmailField extends StatefulWidget {
  const _PremiumEmailField({
    required this.controller,
    required this.isValid,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isValid;
  final ValueChanged<String> onChanged;

  @override
  State<_PremiumEmailField> createState() => _PremiumEmailFieldState();
}

class _PremiumEmailFieldState extends State<_PremiumEmailField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = _focused
        ? _kTeal
        : widget.isValid
            ? _kTeal.withValues(alpha: 0.45)
            : _kNavy.withValues(alpha: 0.14);

    final shadowColor = _focused
        ? _kTeal.withValues(alpha: 0.18)
        : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            color: _kNavy,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'nama@email.com',
            hintStyle: TextStyle(
              color: _kNavy.withValues(alpha: 0.32),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.mail_outline_rounded,
              color: _focused ? _kTeal : _kNavy.withValues(alpha: 0.38),
              size: 20,
            ),
            suffixIcon: widget.isValid
                ? const Icon(Icons.check_circle_rounded, color: _kTeal, size: 18)
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// ── OTP info card ─────────────────────────────────────────────────────────────

class _OtpInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _kTeal.withValues(alpha: 0.08),
            _kMint.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _kTeal.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _kTeal.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: _kTeal,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Kode OTP berlaku selama 10 menit. '
              'Cek folder spam jika tidak ada di inbox.',
              style: TextStyle(
                color: _kTeal,
                fontSize: 12.5,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gradient OTP send button ──────────────────────────────────────────────────

class _GradientOtpButton extends StatelessWidget {
  const _GradientOtpButton({
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
  });

  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          gradient: isEnabled
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [_kTeal, Color(0xFF0A7A70), _kNavy],
                  stops: [0.0, 0.55, 1.0],
                )
              : LinearGradient(
                  colors: [
                    _kTeal.withValues(alpha: 0.38),
                    _kNavy.withValues(alpha: 0.38),
                  ],
                ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: _kTeal.withValues(alpha: 0.40),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: _kNavy.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Mengirim OTP...',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, color: Colors.white, size: 17),
                    SizedBox(width: 8),
                    Text(
                      'Kirim Kode OTP',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Particle background ───────────────────────────────────────────────────────

class _ParticleBackground extends StatelessWidget {
  const _ParticleBackground({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => CustomPaint(
        painter: _ParticlePainter(animation.value),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.t);
  final double t;

  static final _particles = List.generate(18, (i) {
    final rng = math.Random(i * 7 + 13);
    return _Particle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      r: 1.2 + rng.nextDouble() * 2.4,
      speed: 0.04 + rng.nextDouble() * 0.08,
      phase: rng.nextDouble() * math.pi * 2,
      alpha: 0.06 + rng.nextDouble() * 0.12,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final yOff = math.sin(t * math.pi * 2 * p.speed + p.phase) * 18;
      final paint = Paint()
        ..color = _kMint.withValues(alpha: p.alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height + yOff),
        p.r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.r,
    required this.speed,
    required this.phase,
    required this.alpha,
  });
  final double x, y, r, speed, phase, alpha;
}

// ── Orb decoration ────────────────────────────────────────────────────────────
class _OrbWidget extends StatelessWidget {
  const _OrbWidget(this.size, this.color);
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// ── Wave clipper (U terbalik) ─────────────────────────────────────────────────
class _AuthWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = Path();
    p.moveTo(0, s.height);
    p.lineTo(0, s.height * 0.5);
    p.quadraticBezierTo(
      s.width * 0.5, 0,
      s.width, s.height * 0.5,
    );
    p.lineTo(s.width, s.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}