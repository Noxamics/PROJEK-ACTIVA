import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/forgot_password_provider.dart';
import '../widgets/auth_error_banner.dart';
import 'reset_password_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Design Constants
// ─────────────────────────────────────────────────────────────────────────────

class _OtpDesign {
  static const Color navyDeep = Color(0xFF0A1628);
  static const Color navyMid = Color(0xFF0D2040);
  static const Color teal = Color(0xFF00C9B8);
  static const Color tealGlow = Color(0xFF00E5D3);
  static const Color tealDim = Color(0xFF007A71);
  static const Color bgWhite = Color(0xFFF4F7FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0D1B2A);
  static const Color textMuted = Color(0xFF7A8EA8);

  static const double radiusLg = 24.0;
  static const double radiusMd = 16.0;
  static const double radiusSm = 12.0;

  static const Duration animFast = Duration(milliseconds: 220);
  static const Duration animMed = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 800);
}

// ─────────────────────────────────────────────────────────────────────────────
//  Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with TickerProviderStateMixin {
  // Controllers & focus nodes
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // Countdown
  int _secondsLeft = 60;
  bool _canResend = false;
  Timer? _timer;

  // Animations
  late AnimationController _glowPulse;
  late AnimationController _particleController;
  late AnimationController _mascotBreath;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    _glowPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _mascotBreath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowPulse.dispose();
    _particleController.dispose();
    _mascotBreath.dispose();
    _shakeController.dispose();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  // ── Countdown ───────────────────────────────────────────────────────────────

  void _startCountdown() {
    setState(() {
      _secondsLeft = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  // ── OTP helpers ─────────────────────────────────────────────────────────────

  String get _otpCode => _controllers.map((c) => c.text).join();
  bool get _isOtpComplete => _otpCode.length == 6;

  String _formatCountdown() {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _onVerify() async {
    if (!_isOtpComplete) {
      _shakeController.forward(from: 0);
      return;
    }

    final success = await ref
        .read(forgotPasswordProvider.notifier)
        .verifyOtp(_otpCode);

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
      );
    }
  }

  Future<void> _onResend() async {
    if (!_canResend) return;
    final email = ref.read(forgotPasswordProvider).email;
    for (final c in _controllers) c.clear();
    _focusNodes[0].requestFocus();

    final success = await ref
        .read(forgotPasswordProvider.notifier)
        .sendOtp(email);
    if (success) _startCountdown();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordProvider);
    final email = state.email;
    final isLoading = state.isLoading;
    final errorMsg = state.errorMessage;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _OtpDesign.navyDeep,
        body: Stack(
          children: [
            // Background particles
            _FloatingParticles(controller: _particleController),

            // Main layout
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ── Dark Navy Hero Section with wave at bottom ──────────
                  Stack(
                    children: [
                      _HeroSection(
                        email: email,
                        glowPulse: _glowPulse,
                        mascotBreath: _mascotBreath,
                        onBack: () => Navigator.pop(context),
                      ),
                      // Small wave overlay at bottom (same as login)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ClipPath(
                          clipper: _WaveClipper(),
                          child: Container(height: 40, color: _OtpDesign.bgWhite),
                        ),
                      ),
                    ],
                  ),

                  // ── White form section (plain, no clip) ──────────────────
                  Expanded(
                    child: Container(
                      color: _OtpDesign.bgWhite,
                      child: _FormSection(
                        controllers: _controllers,
                        focusNodes: _focusNodes,
                        isLoading: isLoading,
                        errorMsg: errorMsg,
                        isOtpComplete: _isOtpComplete,
                        secondsLeft: _secondsLeft,
                        canResend: _canResend,
                        shakeAnim: _shakeAnim,
                        onVerify: _onVerify,
                        onResend: _onResend,
                        onChanged: (index, val) {
                          if (val.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (val.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          setState(() {});
                        },
                        formatCountdown: _formatCountdown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Hero Section (dark top area)
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.email,
    required this.glowPulse,
    required this.mascotBreath,
    required this.onBack,
  });

  final String email;
  final AnimationController glowPulse;
  final AnimationController mascotBreath;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_OtpDesign.navyDeep, _OtpDesign.navyMid],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          _BackButton(onTap: onBack),
          const SizedBox(height: 20),

          // Glow orb + mascot
          Center(
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Orb
                _GlowOrb(controller: glowPulse),

                // Mascot floating companion
                Positioned(
                  right: -18,
                  top: -12,
                  child: _MascotCompanion(controller: mascotBreath),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Cek Email Kamu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle with email highlight
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Color(0xFFAFC5DC),
                fontSize: 14,
                height: 1.6,
              ),
              children: [
                const TextSpan(
                  text:
                      'Kami mengirimkan kode OTP 6 digit untuk melanjutkan perjalanan digital wellness kamu ke ',
                ),
                TextSpan(
                  text: email.isNotEmpty ? email : '...',
                  style: const TextStyle(
                    color: _OtpDesign.tealGlow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Back Button
// ─────────────────────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.18),
              Colors.white.withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: _OtpDesign.teal.withValues(alpha: 0.15),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Glow Orb
// ─────────────────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        final outerGlow = 30.0 + t * 18.0;
        final innerGlow = 18.0 + t * 10.0;

        return SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring glow
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _OtpDesign.teal.withValues(alpha: 0.18 + t * 0.1),
                      blurRadius: outerGlow,
                      spreadRadius: outerGlow * 0.4,
                    ),
                  ],
                  gradient: RadialGradient(
                    colors: [
                      _OtpDesign.teal.withValues(alpha: 0.06),
                      _OtpDesign.teal.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              // Mid ring
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _OtpDesign.teal.withValues(alpha: 0.3 + t * 0.15),
                    width: 1.5,
                  ),
                ),
              ),
              // Core orb
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _OtpDesign.teal.withValues(alpha: 0.9),
                      const Color(0xFF007A6E),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _OtpDesign.teal.withValues(alpha: 0.5),
                      blurRadius: innerGlow,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Mascot Companion
// ─────────────────────────────────────────────────────────────────────────────

class _MascotCompanion extends StatelessWidget {
  const _MascotCompanion({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final breathY = math.sin(controller.value * math.pi) * 4.0;
        return Transform.translate(
          offset: Offset(0, breathY),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF1DE9B6), Color(0xFF00BCD4)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _OtpDesign.teal.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Wave Card Clipper
// ─────────────────────────────────────────────────────────────────────────────

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.5, 0,
      size.width, size.height * 0.5,
    );
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _WaveCard extends StatelessWidget {
  const _WaveCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: _OtpDesign.bgWhite),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Form Section
// ─────────────────────────────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.controllers,
    required this.focusNodes,
    required this.isLoading,
    required this.errorMsg,
    required this.isOtpComplete,
    required this.secondsLeft,
    required this.canResend,
    required this.shakeAnim,
    required this.onVerify,
    required this.onResend,
    required this.onChanged,
    required this.formatCountdown,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isLoading;
  final String? errorMsg;
  final bool isOtpComplete;
  final int secondsLeft;
  final bool canResend;
  final Animation<double> shakeAnim;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final void Function(int index, String val) onChanged;
  final String Function() formatCountdown;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error banner
          if (errorMsg != null) ...[
            AuthErrorBanner(message: errorMsg!),
            const SizedBox(height: 20),
          ],

          // Label
          const Text(
            'Masukkan Kode OTP',
            style: TextStyle(
              color: _OtpDesign.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Periksa folder spam jika tidak menemukan email.',
            style: TextStyle(color: _OtpDesign.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // OTP boxes with shake
          AnimatedBuilder(
            animation: shakeAnim,
            builder: (_, child) {
              final dx = math.sin(shakeAnim.value * math.pi * 6) * 8;
              return Transform.translate(
                offset: Offset(dx, 0),
                child: child,
              );
            },
            child: _OtpBoxRow(
              controllers: controllers,
              focusNodes: focusNodes,
              onChanged: onChanged,
            ),
          ),

          const SizedBox(height: 36),

          // Verify button
          _VerifyButton(
            isLoading: isLoading,
            isOtpComplete: isOtpComplete,
            onTap: onVerify,
          ),

          const SizedBox(height: 28),

          // Countdown / Resend
          _CountdownSection(
            secondsLeft: secondsLeft,
            canResend: canResend,
            onResend: onResend,
            formatCountdown: formatCountdown,
          ),

          const SizedBox(height: 24),

          // Decorative bottom blobs
          const _BottomDecoration(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  OTP Box Row
// ─────────────────────────────────────────────────────────────────────────────

class _OtpBoxRow extends StatelessWidget {
  const _OtpBoxRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String val) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (i) => _OtpBox(
          controller: controllers[i],
          focusNode: focusNodes[i],
          index: i,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _OtpBox extends StatefulWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.index,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int index;
  final void Function(int index, String val) onChanged;

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _hasFocus = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFilled = widget.controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: _OtpDesign.animFast,
      curve: Curves.easeOut,
      width: 46,
      height: 58,
      decoration: BoxDecoration(
        color: _hasFocus
            ? Colors.white
            : hasFilled
                ? const Color(0xFFEDF9F8)
                : Colors.white,
        borderRadius: BorderRadius.circular(_OtpDesign.radiusMd),
        border: Border.all(
          color: _hasFocus
              ? _OtpDesign.teal
              : hasFilled
                  ? _OtpDesign.tealDim
                  : const Color(0xFFDDE4EE),
          width: _hasFocus ? 2.0 : 1.5,
        ),
        boxShadow: [
          if (_hasFocus)
            BoxShadow(
              color: _OtpDesign.teal.withValues(alpha: 0.28),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          color: _hasFocus ? _OtpDesign.teal : _OtpDesign.textDark,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (val) => widget.onChanged(widget.index, val),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Verify Button
// ─────────────────────────────────────────────────────────────────────────────

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({
    required this.isLoading,
    required this.isOtpComplete,
    required this.onTap,
  });

  final bool isLoading;
  final bool isOtpComplete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = !isLoading && isOtpComplete;

    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: _OtpDesign.animFast,
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_OtpDesign.radiusMd),
          gradient: LinearGradient(
            colors: active
                ? [_OtpDesign.navyMid, _OtpDesign.teal]
                : [
                    _OtpDesign.navyMid.withValues(alpha: 0.5),
                    _OtpDesign.teal.withValues(alpha: 0.5),
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _OtpDesign.teal.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: _OtpDesign.navyDeep.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Memverifikasi...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Verifikasi OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
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
//  Countdown / Resend Section
// ─────────────────────────────────────────────────────────────────────────────

class _CountdownSection extends StatelessWidget {
  const _CountdownSection({
    required this.secondsLeft,
    required this.canResend,
    required this.onResend,
    required this.formatCountdown,
  });

  final int secondsLeft;
  final bool canResend;
  final VoidCallback onResend;
  final String Function() formatCountdown;

  @override
  Widget build(BuildContext context) {
    if (canResend) {
      return Center(
        child: GestureDetector(
          onTap: onResend,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_OtpDesign.radiusMd),
              border: Border.all(
                color: _OtpDesign.teal.withValues(alpha: 0.4),
              ),
              color: _OtpDesign.teal.withValues(alpha: 0.08),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: _OtpDesign.teal,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Kirim Ulang OTP',
                  style: TextStyle(
                    color: _OtpDesign.teal,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Countdown text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.timer_outlined,
              color: _OtpDesign.textMuted,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'Kirim ulang kode dalam ${formatCountdown()}',
              style: const TextStyle(
                color: _OtpDesign.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Animated progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: secondsLeft / 60.0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            builder: (_, value, __) {
              return Stack(
                children: [
                  // Track
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE4EE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          colors: [_OtpDesign.teal, Color(0xFF00E5D3)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _OtpDesign.teal.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Bottom Decoration (blurred circles, depth)
// ─────────────────────────────────────────────────────────────────────────────

class _BottomDecoration extends StatelessWidget {
  const _BottomDecoration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -20,
            bottom: 0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _OtpDesign.teal.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: -10,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _OtpDesign.navyMid.withValues(alpha: 0.07),
              ),
            ),
          ),
          Center(
            child: Text(
              '🔒 Terenkripsi & Aman',
              style: TextStyle(
                color: _OtpDesign.textMuted.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Floating Particles Background
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingParticles extends StatelessWidget {
  const _FloatingParticles({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final size = MediaQuery.of(context).size;

        return CustomPaint(
          size: size,
          painter: _ParticlePainter(t: t),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.t});
  final double t;

  static final List<_Particle> _particles = List.generate(14, (i) {
    final rng = math.Random(i * 7 + 3);
    return _Particle(
      xBase: rng.nextDouble(),
      yBase: rng.nextDouble() * 0.55, // only in dark top section
      radius: rng.nextDouble() * 2.5 + 1.0,
      speed: rng.nextDouble() * 0.3 + 0.15,
      phase: rng.nextDouble(),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _OtpDesign.teal.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    for (final p in _particles) {
      final progress = (t + p.phase) % 1.0;
      final y =
          (p.yBase - progress * p.speed * 0.4 + 1.0) % 0.6;
      final x =
          p.xBase + math.sin((t + p.phase) * math.pi * 2) * 0.025;
      final opacity =
          (math.sin(progress * math.pi)).clamp(0.0, 1.0) * 0.4;

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.radius,
        paint..color = _OtpDesign.teal.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

class _Particle {
  const _Particle({
    required this.xBase,
    required this.yBase,
    required this.radius,
    required this.speed,
    required this.phase,
  });
  final double xBase;
  final double yBase;
  final double radius;
  final double speed;
  final double phase;
}