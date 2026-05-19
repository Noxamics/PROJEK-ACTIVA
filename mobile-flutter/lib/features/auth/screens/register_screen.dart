import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/theme/app_colors.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_error_banner.dart';

// ─────────────────────────────────────────────────────────────
//  Activa – Premium Multi-Step Register Screen
//  Step 1: Account Info  |  Step 2: Personal Profile
// ─────────────────────────────────────────────────────────────

const bool _useMockRegister = false;

// ── Design tokens (selaras dengan onboarding) ─────────────────
const _kNavy = Color(0xFF1E3A5F);
const _kNavyDark = Color(0xFF0A1628);
const _kTeal = Color(0xFF0D9488);
const _kTealLight = Color(0xFF5EEAD4);
const _kIce = Color(0xFFF0F9FF);
const _kPurple = Color(0xFF7C83FD);
const _kTextDark = Color(0xFF0F172A);
const _kTextMuted = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);
const _kWhite = Color(0xFFFFFFFF);

// ─────────────────────────────────────────────────────────────
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  // ── Step ──────────────────────────────────────────────────
  int _step = 0; // 0 = step 1, 1 = step 2

  // ── Controllers ───────────────────────────────────────────
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _konfCtrl = TextEditingController();
  final _pageCtrl = PageController();

  // ── Step 2 state ──────────────────────────────────────────
  DateTime? _tglLahir;
  String _gender = 'Laki-laki';
  String _pendidikan = 'Sarjana';
  String _role = 'Pelajar/Mahasiswa';
  String _income = 'Rendah';
  String _region = 'Asia';

  // ── Validation ────────────────────────────────────────────
  bool _submitted = false;
  String? _namaErr, _emailErr, _passErr, _konfErr, _tglErr;

  // ── Google ────────────────────────────────────────────────
  bool _googleVerified = false;
  bool _googleLoading = false;
  String? _googleErr;
  final _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId:
        '1015245613521-m6fice524tsb1ufv7je101m9n04rdlem.apps.googleusercontent.com',
  );

  // ── Animations ────────────────────────────────────────────
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;
  late final AnimationController _heroCtrl;
  late final Animation<double> _heroAnim;

  // ── Focus nodes ───────────────────────────────────────────
  final _namaFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _konfFocus = FocusNode();

  static final _emailRx = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // ── Options ───────────────────────────────────────────────
  static const _genderOpts = ['Laki-laki', 'Perempuan'];
  static const _pendidikanOpts = [
    'SMA/SMK/Sederajat',
    'Sarjana',
    'Magister',
    'Doktor',
  ];
  static const _regionOpts = [
    'Afrika',
    'Asia',
    'Eropa',
    'Timur Tengah',
    'Amerika Utara',
    'Amerika Selatan',
  ];
  static const _roleOpts = [
    'Pelajar/Mahasiswa',
    'Karyawan Penuh waktu',
    'Karyawan Paruh waktu',
    'Pengurus rumah tangga',
    'Tidak bekerja/sedang mencari kerja',
  ];
  static const _incomeOpts = [
    'Rendah',
    'Menengah Bawah',
    'Menengah Atas',
    'Tinggi',
  ];

  // ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeOut));

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heroAnim = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic);
    _heroCtrl.forward();

    for (final fn in [_namaFocus, _emailFocus, _passFocus, _konfFocus]) {
      fn.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _konfCtrl.dispose();
    _pageCtrl.dispose();
    _shakeCtrl.dispose();
    _heroCtrl.dispose();
    _namaFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _konfFocus.dispose();
    super.dispose();
  }

  // ── Google ────────────────────────────────────────────────
  Future<void> _verifyGoogle() async {
    setState(() {
      _googleLoading = true;
      _googleErr = null;
    });
    try {
      await _googleSignIn.signOut();
      final acc = await _googleSignIn.signIn();
      if (acc != null) {
        setState(() {
          _googleVerified = true;
          _emailCtrl.text = acc.email;
          if (_namaCtrl.text.isEmpty) _namaCtrl.text = acc.displayName ?? '';
          _emailErr = null;
          _namaErr = null;
        });
        HapticFeedback.mediumImpact();
      } else {
        setState(() => _googleErr = 'Verifikasi dibatalkan');
      }
    } catch (_) {
      setState(() => _googleErr = 'Gagal verifikasi Google. Coba lagi.');
    } finally {
      setState(() => _googleLoading = false);
    }
  }

  // ── Validators ────────────────────────────────────────────
  String? _vNama(String v) {
    if (v.isEmpty) return 'Nama lengkap wajib diisi';
    if (v.length < 3) return 'Nama minimal 3 karakter';
    if (RegExp(r'[0-9]').hasMatch(v))
      return 'Nama tidak boleh mengandung angka';
    return null;
  }

  String? _vEmail(String v) {
    if (v.isEmpty) return 'Email wajib diisi';
    if (!_emailRx.hasMatch(v)) return 'Format email tidak valid';
    return null;
  }

  String? _vPass(String v) {
    if (v.isEmpty) return 'Password wajib diisi';
    if (v.length < 8) return 'Minimal 8 karakter';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Tambahkan huruf besar';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Tambahkan huruf kecil';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Tambahkan angka';
    return null;
  }

  String? _vKonf(String v) {
    if (v.isEmpty) return 'Konfirmasi password wajib diisi';
    if (v != _passCtrl.text) return 'Password tidak cocok';
    return null;
  }

  String? _vTgl() {
    if (_tglLahir == null) return 'Tanggal lahir wajib diisi';
    final age = DateTime.now().difference(_tglLahir!).inDays ~/ 365;
    if (age < 10 || age > 120) return 'Umur harus antara 10–120 tahun';
    return null;
  }

  int get _age => _tglLahir == null
      ? 0
      : DateTime.now().difference(_tglLahir!).inDays ~/ 365;

  // Password strength
  int get _passStrength {
    final p = _passCtrl.text;
    int s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'[a-z]').hasMatch(p)) s++;
    if (RegExp(r'[0-9]').hasMatch(p)) s++;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(p)) s++;
    return s;
  }

  // Computed validity for checkmarks
  bool get _namaOk => _vNama(_namaCtrl.text.trim()) == null;
  bool get _emailOk => _vEmail(_emailCtrl.text.trim()) == null;
  bool get _passOk => _vPass(_passCtrl.text) == null;
  bool get _konfOk => _vKonf(_konfCtrl.text) == null;

  // ── Step navigation ───────────────────────────────────────
  void _goNext() {
    if (!_googleVerified) {
      setState(
        () => _googleErr = 'Verifikasi Google wajib dilakukan terlebih dahulu',
      );
      _shakeCtrl.forward(from: 0);
      HapticFeedback.mediumImpact();
      return;
    }

    final nama = _namaCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    setState(() {
      _submitted = true;
      _namaErr = _vNama(nama);
      _emailErr = _vEmail(email);
      _passErr = _vPass(_passCtrl.text);
      _konfErr = _vKonf(_konfCtrl.text);
    });

    if (_namaErr != null ||
        _emailErr != null ||
        _passErr != null ||
        _konfErr != null) {
      _shakeCtrl.forward(from: 0);
      HapticFeedback.mediumImpact();
      return;
    }

    setState(() {
      _step = 1;
      _submitted = false;
    });
    _pageCtrl.animateToPage(
      1,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
    _heroCtrl
      ..reset()
      ..forward();
  }

  void _goBack() {
    setState(() => _step = 0);
    _pageCtrl.animateToPage(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
    _heroCtrl
      ..reset()
      ..forward();
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _tglErr = _vTgl();
    });

    if (_tglErr != null) {
      _shakeCtrl.forward(from: 0);
      HapticFeedback.mediumImpact();
      return;
    }

    ref.read(authProvider.notifier).clearError();

    final gMap = {'Laki-laki': 'Male', 'Perempuan': 'Female'};
    final rMap = {
      'Afrika': 'Africa',
      'Asia': 'Asia',
      'Eropa': 'Europe',
      'Timur Tengah': 'Middle East',
      'Amerika Utara': 'North America',
      'Amerika Selatan': 'South America',
    };
    final eMap = {
      'SMA/SMK/Sederajat': 'High School',
      'Sarjana': 'Bachelor',
      'Magister': 'Master',
      'Doktor': 'PhD',
    };
    final iMap = {
      'Rendah': 'Low',
      'Menengah Bawah': 'Lower-Mid',
      'Menengah Atas': 'Upper-Mid',
      'Tinggi': 'High',
    };
    final roMap = {
      'Pelajar/Mahasiswa': 'Student',
      'Karyawan Penuh waktu': 'Full-time',
      'Karyawan Paruh waktu': 'Part-time',
      'Pengurus rumah tangga': 'Caregiver',
      'Tidak bekerja/sedang mencari kerja': 'Unemployed',
    };

    bool success = false;
    if (_useMockRegister) {
      success = await ref
          .read(authProvider.notifier)
          .mockRegister(
            name: _namaCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            gender: gMap[_gender] ?? 'Male',
            educationLevel: eMap[_pendidikan] ?? 'Bachelor',
            region: rMap[_region] ?? 'Asia',
            dateOfBirth: _tglLahir,
            dailyRole: roMap[_role] ?? 'Student',
            incomeLevel: iMap[_income] ?? 'Low',
          );
    } else {
      success = await ref
          .read(authProvider.notifier)
          .register(
            name: _namaCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            passwordConfirmation: _konfCtrl.text,
            gender: gMap[_gender] ?? 'Male',
            educationLevel: eMap[_pendidikan] ?? 'Bachelor',
            region: rMap[_region] ?? 'Asia',
            dateOfBirth: _tglLahir,
            dailyRole: roMap[_role] ?? 'Student',
            incomeLevel: iMap[_income] ?? 'Low',
          );
    }

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final errorMsg = authState.errorMessage;

    return Scaffold(
      backgroundColor: _kIce,
      body: Column(
        children: [
          // ── Hero gradient header ─────────────────────────
          _HeroHeader(
            step: _step,
            heroAnim: _heroAnim,
            onBack: _step == 1 ? _goBack : null,
          ),

          // ── Form pages ───────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1
                _Step1Form(
                  namaCtrl: _namaCtrl,
                  emailCtrl: _emailCtrl,
                  passCtrl: _passCtrl,
                  konfCtrl: _konfCtrl,
                  namaFocus: _namaFocus,
                  emailFocus: _emailFocus,
                  passFocus: _passFocus,
                  konfFocus: _konfFocus,
                  namaErr: _namaErr,
                  emailErr: _emailErr,
                  passErr: _passErr,
                  konfErr: _konfErr,
                  namaOk: _namaOk,
                  emailOk: _emailOk,
                  passOk: _passOk,
                  konfOk: _konfOk,
                  passStrength: _passStrength,
                  googleVerified: _googleVerified,
                  googleLoading: _googleLoading,
                  googleErr: _googleErr,
                  onVerifyGoogle: _verifyGoogle,
                  errorMsg: errorMsg,
                  isLoading: isLoading,
                  shakeAnim: _shakeAnim,
                  shakeCtrl: _shakeCtrl,
                  onNamaChanged: (v) {
                    if (_submitted) setState(() => _namaErr = _vNama(v.trim()));
                    ref.read(authProvider.notifier).clearError();
                  },
                  onPassChanged: (v) {
                    if (_submitted)
                      setState(() {
                        _passErr = _vPass(v);
                        if (_konfCtrl.text.isNotEmpty)
                          _konfErr = _vKonf(_konfCtrl.text);
                      });
                    ref.read(authProvider.notifier).clearError();
                  },
                  onKonfChanged: (v) {
                    if (_submitted) setState(() => _konfErr = _vKonf(v));
                    ref.read(authProvider.notifier).clearError();
                  },
                  onNext: _goNext,
                  onLoginTap: () => Navigator.pop(context),
                ),

                // Step 2
                _Step2Form(
                  tglLahir: _tglLahir,
                  tglErr: _tglErr,
                  age: _age,
                  gender: _gender,
                  pendidikan: _pendidikan,
                  role: _role,
                  income: _income,
                  region: _region,
                  genderOpts: _genderOpts,
                  pendidikanOpts: _pendidikanOpts,
                  roleOpts: _roleOpts,
                  incomeOpts: _incomeOpts,
                  regionOpts: _regionOpts,
                  errorMsg: errorMsg,
                  isLoading: isLoading,
                  shakeAnim: _shakeAnim,
                  onTglTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _tglLahir ?? DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.light(primary: _kTeal),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null)
                      setState(() {
                        _tglLahir = picked;
                        _tglErr = null;
                      });
                  },
                  onGenderChanged: (v) =>
                      setState(() => _gender = v ?? _gender),
                  onPendidikanChanged: (v) =>
                      setState(() => _pendidikan = v ?? _pendidikan),
                  onRoleChanged: (v) => setState(() => _role = v ?? _role),
                  onIncomeChanged: (v) =>
                      setState(() => _income = v ?? _income),
                  onRegionChanged: (v) =>
                      setState(() => _region = v ?? _region),
                  onSubmit: isLoading ? null : _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  HERO HEADER — curved gradient with mascot & progress
// ═════════════════════════════════════════════════════════════
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.step, required this.heroAnim, this.onBack});

  final int step;
  final Animation<double> heroAnim;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      height: step == 0 ? 240 + topPad : 200 + topPad,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background
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

          // Soft orbs
          Positioned(
            top: 20,
            right: -20,
            child: _Orb(80, const Color(0x200D9488)),
          ),
          Positioned(
            top: topPad + 10,
            left: -10,
            child: _Orb(60, const Color(0x187C83FD)),
          ),
          Positioned(
            bottom: 30,
            right: 40,
            child: _Orb(40, const Color(0x20FACC15)),
          ),

          // Wave bottom clip
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _BottomWaveClipper(),
              child: Container(height: 40, color: _kIce),
            ),
          ),

          // Content
          Positioned.fill(
            child: SafeArea(
              child: FadeTransition(
                opacity: heroAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(heroAnim),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back button
                        if (onBack != null) ...[
                          GestureDetector(
                            onTap: onBack,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                        ],

                        // Text content
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Progress chips
                              Row(
                                children: [
                                  _ProgressChip(active: step == 0, label: '1'),
                                  const SizedBox(width: 6),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: step == 1 ? 20 : 12,
                                    height: 2,
                                    color: step == 1
                                        ? _kTealLight
                                        : Colors.white.withOpacity(0.3),
                                  ),
                                  const SizedBox(width: 6),
                                  _ProgressChip(active: step == 1, label: '2'),
                                  const SizedBox(width: 10),
                                  Text(
                                    step == 0 ? '1 dari 2' : '2 dari 2',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white54,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                step == 0
                                    ? 'Mari mulai\nperjalananmu'
                                    : 'Ceritakan\ntentang dirimu',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                step == 0
                                    ? 'Beberapa langkah lagi untuk\nmemahami pola digitalmu.'
                                    : 'Bantu Activa memahami\nprofil digitalmu lebih baik.',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Mascot
                        Image.asset(
                          step == 0
                              ? 'assets/images/maskot3.png'
                              : 'assets/images/maskot4.png',
                          height: 100,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox(width: 80),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Logo top-left
          Positioned(
            top: topPad + 14,
            left: onBack != null ? 76 : 24,
            child: SvgPicture.asset(
              'assets/logo/NewLogoPutih_fixed.svg',
              height: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb(this.size, this.color);
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

class _ProgressChip extends StatelessWidget {
  const _ProgressChip({required this.active, required this.label});
  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 28 : 24,
      height: 24,
      decoration: BoxDecoration(
        color: active ? _kTeal : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: active ? Colors.white : Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = Path();
    p.moveTo(0, s.height * 0.5);
    p.quadraticBezierTo(s.width * 0.5, 0, s.width, s.height * 0.5);
    p.lineTo(s.width, s.height);
    p.lineTo(0, s.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(_) => false;
}

// ═════════════════════════════════════════════════════════════
//  STEP 1 — Account Information
// ═════════════════════════════════════════════════════════════
class _Step1Form extends StatelessWidget {
  const _Step1Form({
    required this.namaCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.konfCtrl,
    required this.namaFocus,
    required this.emailFocus,
    required this.passFocus,
    required this.konfFocus,
    required this.namaErr,
    required this.emailErr,
    required this.passErr,
    required this.konfErr,
    required this.namaOk,
    required this.emailOk,
    required this.passOk,
    required this.konfOk,
    required this.passStrength,
    required this.googleVerified,
    required this.googleLoading,
    required this.googleErr,
    required this.onVerifyGoogle,
    required this.errorMsg,
    required this.isLoading,
    required this.shakeAnim,
    required this.shakeCtrl,
    required this.onNamaChanged,
    required this.onPassChanged,
    required this.onKonfChanged,
    required this.onNext,
    required this.onLoginTap,
  });

  final TextEditingController namaCtrl, emailCtrl, passCtrl, konfCtrl;
  final FocusNode namaFocus, emailFocus, passFocus, konfFocus;
  final String? namaErr, emailErr, passErr, konfErr;
  final bool namaOk, emailOk, passOk, konfOk;
  final int passStrength;
  final bool googleVerified, googleLoading;
  final String? googleErr;
  final VoidCallback onVerifyGoogle;
  final String? errorMsg;
  final bool isLoading;
  final Animation<double> shakeAnim;
  final AnimationController shakeCtrl;
  final ValueChanged<String> onNamaChanged, onPassChanged, onKonfChanged;
  final VoidCallback onNext, onLoginTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      child: Column(
        children: [
          // Error banner
          if (errorMsg != null) ...[
            AuthErrorBanner(message: errorMsg!),
            const SizedBox(height: 12),
          ],

          // ── Floating card ─────────────────────────────────
          _FormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(
                  icon: Icons.person_outline_rounded,
                  label: 'Informasi Akun',
                ),
                const SizedBox(height: 18),

                // Google verify card
                _GoogleVerifyCard(
                  verified: googleVerified,
                  loading: googleLoading,
                  error: googleErr,
                  email: emailCtrl.text,
                  onVerify: onVerifyGoogle,
                ),
                const SizedBox(height: 14),

                // Nama
                _PremiumField(
                  label: 'Nama Lengkap',
                  hint: 'Nama lengkapmu',
                  icon: Icons.badge_outlined,
                  controller: namaCtrl,
                  focusNode: namaFocus,
                  errorText: namaErr,
                  isValid: namaOk,
                  onChanged: onNamaChanged,
                ),
                const SizedBox(height: 12),

                // Email (locked if google verified)
                _PremiumField(
                  label: 'Email',
                  hint: 'email@contoh.com',
                  icon: Icons.email_outlined,
                  controller: emailCtrl,
                  focusNode: emailFocus,
                  errorText: emailErr,
                  isValid: emailOk,
                  readOnly: googleVerified,
                  suffixWidget: googleVerified
                      ? const Icon(
                          Icons.lock_outline_rounded,
                          color: _kTeal,
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(height: 12),

                // Password row
                Row(
                  children: [
                    Expanded(
                      child: _PremiumField(
                        label: 'Password',
                        hint: 'Min. 8 karakter',
                        icon: Icons.lock_outline_rounded,
                        controller: passCtrl,
                        focusNode: passFocus,
                        isPassword: true,
                        errorText: passErr,
                        isValid: passOk,
                        onChanged: onPassChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PremiumField(
                        label: 'Konfirmasi',
                        hint: 'Ulangi password',
                        icon: Icons.lock_outline_rounded,
                        controller: konfCtrl,
                        focusNode: konfFocus,
                        isPassword: true,
                        errorText: konfErr,
                        isValid: konfOk,
                        onChanged: onKonfChanged,
                      ),
                    ),
                  ],
                ),

                // Password strength bar
                if (passCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _PasswordStrengthBar(strength: passStrength),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CTA Button
          AnimatedBuilder(
            animation: shakeAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(shakeAnim.value, 0),
              child: child,
            ),
            child: _GradientButton(
              label: 'Lanjutkan',
              icon: Icons.arrow_forward_rounded,
              onTap: isLoading ? null : onNext,
              isLoading: isLoading,
            ),
          ),

          const SizedBox(height: 20),
          _LoginLink(onTap: onLoginTap),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  STEP 2 — Personal Profile
// ═════════════════════════════════════════════════════════════
class _Step2Form extends StatelessWidget {
  const _Step2Form({
    required this.tglLahir,
    required this.tglErr,
    required this.age,
    required this.gender,
    required this.pendidikan,
    required this.role,
    required this.income,
    required this.region,
    required this.genderOpts,
    required this.pendidikanOpts,
    required this.roleOpts,
    required this.incomeOpts,
    required this.regionOpts,
    required this.errorMsg,
    required this.isLoading,
    required this.shakeAnim,
    required this.onTglTap,
    required this.onGenderChanged,
    required this.onPendidikanChanged,
    required this.onRoleChanged,
    required this.onIncomeChanged,
    required this.onRegionChanged,
    required this.onSubmit,
  });

  final DateTime? tglLahir;
  final String? tglErr;
  final int age;
  final String gender, pendidikan, role, income, region;
  final List<String> genderOpts,
      pendidikanOpts,
      roleOpts,
      incomeOpts,
      regionOpts;
  final String? errorMsg;
  final bool isLoading;
  final Animation<double> shakeAnim;
  final VoidCallback onTglTap;
  final ValueChanged<String?> onGenderChanged,
      onPendidikanChanged,
      onRoleChanged,
      onIncomeChanged,
      onRegionChanged;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      child: Column(
        children: [
          if (errorMsg != null) ...[
            AuthErrorBanner(message: errorMsg!),
            const SizedBox(height: 12),
          ],

          _FormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(
                  icon: Icons.person_pin_outlined,
                  label: 'Profil Diri',
                ),
                const SizedBox(height: 18),

                // Tanggal Lahir
                _DatePickerField(
                  date: tglLahir,
                  age: age,
                  error: tglErr,
                  onTap: onTglTap,
                ),
                const SizedBox(height: 12),

                // Gender + Pendidikan side by side
                Row(
                  children: [
                    Expanded(
                      child: _PremiumDropdown(
                        label: 'Gender',
                        value: gender,
                        items: genderOpts,
                        onChanged: onGenderChanged,
                        icon: Icons.wc_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PremiumDropdown(
                        label: 'Pendidikan',
                        value: pendidikan,
                        items: pendidikanOpts,
                        onChanged: onPendidikanChanged,
                        icon: Icons.school_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Peran sehari-hari
                _PremiumDropdown(
                  label: 'Peran Sehari-hari',
                  value: role,
                  items: roleOpts,
                  onChanged: onRoleChanged,
                  icon: Icons.work_outline_rounded,
                ),
                const SizedBox(height: 12),

                // Tingkat pendapatan
                _PremiumDropdown(
                  label: 'Tingkat Pendapatan',
                  value: income,
                  items: incomeOpts,
                  onChanged: onIncomeChanged,
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(height: 12),

                // Wilayah
                _PremiumDropdown(
                  label: 'Wilayah/Tempat Tinggal',
                  value: region,
                  items: regionOpts,
                  onChanged: onRegionChanged,
                  icon: Icons.public_outlined,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          AnimatedBuilder(
            animation: shakeAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(shakeAnim.value, 0),
              child: child,
            ),
            child: _GradientButton(
              label: 'Selesai & Daftar',
              icon: Icons.check_circle_outline_rounded,
              onTap: onSubmit,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  SHARED COMPONENTS
// ═════════════════════════════════════════════════════════════

// ── Floating form card ────────────────────────────────────────
class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _kTeal.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Section title ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _kTeal.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _kTeal, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: _kTextDark,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Premium text field ────────────────────────────────────────
class _PremiumField extends StatefulWidget {
  const _PremiumField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.focusNode,
    this.isPassword = false,
    this.isValid = false,
    this.readOnly = false,
    this.errorText,
    this.onChanged,
    this.suffixWidget,
  });

  final String label, hint;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isPassword, isValid, readOnly;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final Widget? suffixWidget;

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final focused = widget.focusNode.hasFocus;
    final hasErr = widget.errorText != null;

    final borderColor = hasErr
        ? Colors.red.shade400
        : focused
        ? _kTeal
        : widget.isValid
        ? _kTeal.withOpacity(0.5)
        : _kBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.plusJakartaSans(
            color: focused ? _kTeal : _kTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.readOnly ? const Color(0xFFF8FFFE) : _kWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: focused ? 1.5 : 1),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: _kTeal.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: widget.isPassword && _obscure,
            readOnly: widget.readOnly,
            onChanged: widget.onChanged,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: _kTextDark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                color: _kBorder,
                fontSize: 13,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: focused ? _kTeal : _kBorder,
                size: 17,
              ),
              suffixIcon: widget.isPassword
                  ? GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _kBorder,
                        size: 17,
                      ),
                    )
                  : widget.isValid
                  ? Icon(Icons.check_circle_rounded, color: _kTeal, size: 17)
                  : widget.suffixWidget != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: widget.suffixWidget,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
          ),
        ),
        if (hasErr) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade400,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                widget.errorText!,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.red.shade400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Google verify card ────────────────────────────────────────
class _GoogleVerifyCard extends StatelessWidget {
  const _GoogleVerifyCard({
    required this.verified,
    required this.loading,
    required this.error,
    required this.email,
    required this.onVerify,
  });

  final bool verified, loading;
  final String? error, email;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    if (verified) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kTeal.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kTeal.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kTeal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: _kTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Akun Google Terverifikasi',
                    style: GoogleFonts.plusJakartaSans(
                      color: _kTeal,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    email ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      color: _kTextMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onVerify,
              child: Text(
                'Ganti',
                style: GoogleFonts.plusJakartaSans(
                  color: _kTeal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FFFE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: error != null ? Colors.red.shade300 : _kBorder,
              width: error != null ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _kNavyDark.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.security_outlined,
                  color: _kNavy.withOpacity(0.5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verifikasi Google (Wajib)',
                      style: GoogleFonts.plusJakartaSans(
                        color: _kTextDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Untuk keamanan akun Activa-mu',
                      style: GoogleFonts.plusJakartaSans(
                        color: _kTextMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: loading ? null : onVerify,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _kNavyDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Hubungkan',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 2),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade400,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  error!,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.red.shade400,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Password strength bar ─────────────────────────────────────
class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.strength});
  final int strength; // 0–5

  static const _labels = [
    '',
    'Sangat Lemah',
    'Lemah',
    'Cukup',
    'Kuat',
    'Sangat Kuat',
  ];
  static const _colors = [
    Colors.transparent,
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFFFACC15),
    Color(0xFF22C55E),
    Color(0xFF0D9488),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 4 ? 4 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < strength ? _colors[strength] : _kBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          }),
        ),
        if (strength > 0) ...[
          const SizedBox(height: 4),
          Text(
            _labels[strength],
            style: GoogleFonts.plusJakartaSans(
              color: _colors[strength],
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Date picker field ─────────────────────────────────────────
class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.date,
    required this.age,
    required this.error,
    required this.onTap,
  });
  final DateTime? date;
  final int age;
  final String? error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Lahir',
          style: GoogleFonts.plusJakartaSans(
            color: _kTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _kWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: error != null
                    ? Colors.red.shade400
                    : date != null
                    ? _kTeal.withOpacity(0.5)
                    : _kBorder,
                width: (date != null || error != null) ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cake_outlined,
                  color: date != null ? _kTeal : _kBorder,
                  size: 17,
                ),
                const SizedBox(width: 10),
                Text(
                  date != null
                      ? '${date!.day.toString().padLeft(2, '0')} / ${date!.month.toString().padLeft(2, '0')} / ${date!.year}'
                      : 'DD / MM / YYYY',
                  style: GoogleFonts.plusJakartaSans(
                    color: date != null ? _kTextDark : _kBorder,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (date != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _kTeal.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$age thn',
                      style: GoogleFonts.plusJakartaSans(
                        color: _kTeal,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade400,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  error!,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.red.shade400,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Premium dropdown ──────────────────────────────────────────
class _PremiumDropdown extends StatelessWidget {
  const _PremiumDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
  });
  final String label, value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: _kTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: _kWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _kBorder,
                size: 18,
              ),
              style: GoogleFonts.plusJakartaSans(
                color: _kTextDark,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: _kWhite,
              borderRadius: BorderRadius.circular(14),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Row(
                        children: [
                          Icon(icon, color: _kTeal.withOpacity(0.6), size: 14),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(e, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Gradient CTA button ───────────────────────────────────────
class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isLoading,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 140),
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
          widget.onTap?.call();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.onTap == null
                  ? [_kTeal.withOpacity(0.5), _kTeal.withOpacity(0.4)]
                  : [const Color(0xFF0D9488), const Color(0xFF0F766E)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.onTap != null
                ? [
                    BoxShadow(
                      color: _kTeal.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : [],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(widget.icon, color: Colors.white, size: 18),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Login link ────────────────────────────────────────────────
class _LoginLink extends StatelessWidget {
  const _LoginLink({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
          children: [
            TextSpan(
              text: 'Sudah punya akun? ',
              style: GoogleFonts.plusJakartaSans(color: _kTextMuted),
            ),
            TextSpan(
              text: 'Masuk',
              style: GoogleFonts.plusJakartaSans(
                color: _kTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
