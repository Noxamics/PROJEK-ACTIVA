import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_error_banner.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// true  = mock login (backend belum terhubung)
// false = real API Laravel
// ─────────────────────────────────────────────────────────────────────────────
const bool _useMockLogin = false;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  bool _emailValid = false;
  bool _passValid = false;
  bool _submitted = false;
  String? _emailError;
  String? _passwordError;

  // ── Shake animation ─────────────────────────────────────────────────────
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  // ── Float animation for mascot ──────────────────────────────────────────
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 6, end: -3), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 1),
      ],
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email wajib diisi';
    if (!_emailRegex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password wajib diisi';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  void _onEmailChanged(String val) {
    final trimmed = val.trim();
    setState(() {
      _emailValid = _emailRegex.hasMatch(trimmed);
      if (_submitted) _emailError = _validateEmail(trimmed);
    });
    ref.read(authProvider.notifier).clearError();
  }

  void _onPasswordChanged(String val) {
    setState(() {
      _passValid = val.length >= 6;
      if (_submitted) _passwordError = _validatePassword(val);
    });
    ref.read(authProvider.notifier).clearError();
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _submitted = true;
      _emailError = _validateEmail(email);
      _passwordError = _validatePassword(password);
    });

    if (_emailError != null || _passwordError != null) {
      _shakeController.forward(from: 0);
      HapticFeedback.mediumImpact();
      return;
    }

    bool success = false;
    if (_useMockLogin) {
      success = await ref
          .read(authProvider.notifier)
          .mockLogin(email: email, password: password);
    } else {
      success = await ref
          .read(authProvider.notifier)
          .login(email: email, password: password);
    }

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final errorMsg = authState.errorMessage;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1F3A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeroSection(),
            Expanded(
              child: _buildFormCard(isLoading: isLoading, errorMsg: errorMsg),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero Section ───────────────────────────────────────────────────────────

  Widget _buildHeroSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.40,
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0B1F3A),
                  Color(0xFF1E3A5F),
                  Color(0xFF0D3352),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // Organic wave shape 1
          Positioned(
            bottom: -12,
            left: -20,
            child: Container(
              width: MediaQuery.of(context).size.width + 40,
              height: 160,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0x2E0D9488), Color(0x1F7C83FD)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(80),
                  topRight: Radius.circular(60),
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(90),
                ),
              ),
            ),
          ),

          // Organic wave shape 2
          Positioned(
            bottom: -22,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 130,
              decoration: BoxDecoration(
                color: const Color(0xFF0D3352).withValues(alpha: 0.6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(80),
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(60),
                ),
              ),
            ),
          ),

          // Decorative blobs
          Positioned(
            top: 16,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0x147C83FD),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: -18,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0x1A0D9488),
                borderRadius: BorderRadius.circular(45),
              ),
            ),
          ),

          // Floating particles
          ..._buildParticles(),

          // Mascot + text — full width agar center sempurna
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // ← ini yang diubah
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20), // ← atur dari sini
                _buildMascot(),
                const SizedBox(height: 55),
                _buildHeroText(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles() {
    final particles = [
      _Particle(
        top: 28,
        left: 40,
        size: 5,
        color: const Color(0x800D9488),
        delay: 0,
      ),
      _Particle(
        top: 50,
        left: 80,
        size: 3,
        color: const Color(0x66FACC15),
        delay: 700,
      ),
      _Particle(
        top: 20,
        right: 60,
        size: 4,
        color: const Color(0x807C83FD),
        delay: 1200,
      ),
      _Particle(
        top: 65,
        right: 44,
        size: 3,
        color: const Color(0x802DD4BF),
        delay: 400,
      ),
      _Particle(
        top: 130,
        left: 24,
        size: 6,
        color: const Color(0x40FACC15),
        delay: 1800,
      ),
      _Particle(
        top: 140,
        right: 28,
        size: 4,
        color: const Color(0x4D7C83FD),
        delay: 1000,
      ),
    ];
    return particles.map((p) {
      return Positioned(
        top: p.top,
        left: p.left,
        right: p.right,
        child: _AnimatedParticle(particle: p),
      );
    }).toList();
  }

  Widget _buildMascot() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: SizedBox(
        width: 130,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft teal glow ring behind mascot
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0D9488).withValues(alpha: 0.20),
                    const Color(0xFF7C83FD).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Inner glow pulse ring
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
            ),
            // Maskot image asset
            Image.asset(
              'assets/images/Maskot.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            // Floating star decoration (top-right of mascot)
            Positioned(top: 2, right: 4, child: _buildStarDecor()),
          ],
        ),
      ),
    );
  }

  Widget _buildStarDecor() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, _) {
        final scale = 1.0 + 0.15 * _floatController.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFFFACC15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.white,
              size: 13,
            ),
          ),
        );
      },
    );
  }

  // ── Hero Text ──────────────────────────────────────────────────────────────
  // FIX 1 : "Selamat datang kembali" dihapus
  // FIX 2 : "digital wellness" → "kesehatan digital"
  // FIX 3 : SizedBox(width: double.infinity) memastikan center benar-benar tengah
  Widget _buildHeroText() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Lanjutkan Perjalanan\nKesehatan Digital Kamu',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFF0F9FF),
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pantau kebiasaan digitalmu hari ini bersama Activa.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0x8CF0F9FF),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Form Card ──────────────────────────────────────────────────────────────

  Widget _buildFormCard({required bool isLoading, required String? errorMsg}) {
    return Transform.translate(
      offset: const Offset(0, -32),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF0F9FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Color(0x380B1F3A),
              blurRadius: 40,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand pill tag
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D9488),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          'ACTIVA · MEASURE. IMPROVE. THRIVE.',
                          style: TextStyle(
                            color: Color(0xFF0D9488),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Error banner
                if (errorMsg != null) ...[
                  AuthErrorBanner(message: errorMsg),
                  const SizedBox(height: 16),
                ],

                // Email Field
                _buildFieldLabel('Email'),
                const SizedBox(height: 8),
                _buildPillField(
                  controller: _emailController,
                  hint: 'nama@email.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  onChanged: _onEmailChanged,
                ),
                const SizedBox(height: 16),

                // Password Field
                _buildFieldLabel('Password'),
                const SizedBox(height: 8),
                _buildPillField(
                  controller: _passwordController,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  errorText: _passwordError,
                  onChanged: _onPasswordChanged,
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: const Color(0xFF1E3A5F).withValues(alpha: 0.35),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Remember me + forgot password row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _rememberMe
                                  ? const Color(0xFF0D9488)
                                  : Colors.transparent,
                              border: Border.all(
                                color: const Color(0xFF0D9488),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: _rememberMe
                                ? const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ingat saya',
                            style: TextStyle(
                              color: const Color(
                                0xFF1E3A5F,
                              ).withValues(alpha: 0.75),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      ),
                      child: const Text(
                        'Lupa Password?',
                        style: TextStyle(
                          color: Color(0xFF0D9488),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Login Button
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  ),
                  child: _buildLoginButton(isLoading),
                ),
                const SizedBox(height: 22),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFF1E3A5F).withValues(alpha: 0.1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'atau',
                        style: TextStyle(
                          color: const Color(
                            0xFF1E3A5F,
                          ).withValues(alpha: 0.35),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFF1E3A5F).withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Register link
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Belum punya akun? ',
                            style: TextStyle(
                              color: const Color(
                                0xFF1E3A5F,
                              ).withValues(alpha: 0.5),
                            ),
                          ),
                          const TextSpan(
                            text: 'Daftar Sekarang',
                            style: TextStyle(
                              color: Color(0xFF0D9488),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // FIX 4: Hapus emoji ✨
                Center(
                  child: Text(
                    'Perubahan kecil dimulai hari ini',
                    style: TextStyle(
                      color: const Color(0xFF1E3A5F).withValues(alpha: 0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ), // Container
    ); // Transform.translate
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1E3A5F).withValues(alpha: 0.7),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildPillField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? errorText,
    Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: errorText != null
                  ? Colors.red.withValues(alpha: 0.5)
                  : const Color(0xFF1E3A5F).withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              Icon(
                prefixIcon,
                size: 18,
                color: const Color(0xFF1E3A5F).withValues(alpha: 0.4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1E3A5F),
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: const Color(0xFF1E3A5F).withValues(alpha: 0.3),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (suffixIcon != null) ...[
                suffixIcon,
                const SizedBox(width: 18),
              ],
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _onLogin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [
                    const Color(0xFF0D9488).withValues(alpha: 0.6),
                    const Color(0xFF1E7D72).withValues(alpha: 0.6),
                  ]
                : [const Color(0xFF0D9488), const Color(0xFF1E7D72)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: isLoading
                  ? const Color(0xFF0D9488).withValues(alpha: 0.0)
                  : const Color(0xFF0D9488).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: isLoading ? Offset.zero : const Offset(0, 8),
            ),
          ],
        ),
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
                    'Sedang masuk...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Particle helpers ───────────────────────────────────────────────────────

class _Particle {
  final double top;
  final double? left;
  final double? right;
  final double size;
  final Color color;
  final int delay;

  const _Particle({
    required this.top,
    this.left,
    this.right,
    required this.size,
    required this.color,
    required this.delay,
  });
}

class _AnimatedParticle extends StatefulWidget {
  final _Particle particle;
  const _AnimatedParticle({required this.particle});

  @override
  State<_AnimatedParticle> createState() => _AnimatedParticleState();
}

class _AnimatedParticleState extends State<_AnimatedParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _anim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.particle.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final dy = -10 * _anim.value;
        final opacity = 0.5 + 0.5 * _anim.value;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: widget.particle.size,
              height: widget.particle.size,
              decoration: BoxDecoration(
                color: widget.particle.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
