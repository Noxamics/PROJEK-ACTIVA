//lib/features/kuisioner/screens/kuesioner_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/questionnaire_provider.dart';
import '../widgets/question_option_card.dart';
import '../widgets/question_slider.dart';
import '../../hasil_prediksi/screens/hasil_prediksi_screen.dart';
import '../../hasil_prediksi/providers/result_provider.dart';

import '../../../shared/widgets/bottom_nav.dart';
import '../../profil/screens/profil_screen.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';

// true  = hitung lokal (backend belum siap)
// false = kirim ke Laravel → data masuk MongoDB
const bool _useMockSurvey = false;

// ── Palette constants ─────────────────────────────────────────────────────────
const _kNavy = Color(0xFF1E3A5F);
const _kDeepNavy = Color(0xFF0B1F3A);
const _kTeal = Color(0xFF0D9488);
const _kIce = Color(0xFFF0F9FF);
const _kPurple = Color(0xFF7C83FD);
const _kCyan = Color(0xFF67E8F9);

class KuesionerScreen extends ConsumerStatefulWidget {
  const KuesionerScreen({super.key});

  @override
  ConsumerState<KuesionerScreen> createState() => _KuesionerScreenState();
}

class _KuesionerScreenState extends ConsumerState<KuesionerScreen> {
  late final PageController _pageController;
  bool _showSelection = true;
  bool _isFetchingLatest = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionnaireProvider.notifier).reset(keepResult: true);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _onNavTap(int index) {
    if (index == 1) return;

    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LaporanPerkembanganScreen(),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GrafikScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilScreen()),
        );
        break;
    }
  }

  void _startNew() {
    setState(() => _showSelection = false);
    ref.read(questionnaireProvider.notifier).reset();
  }

  Future<void> _viewLatest() async {
    final existingResult = ref.read(questionnaireProvider).result;
    if (existingResult != null && !_isFetchingLatest) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HasilPrediksiScreen(result: existingResult),
        ),
      );
      return;
    }

    setState(() => _isFetchingLatest = true);
    final result = await ref
        .read(questionnaireProvider.notifier)
        .fetchLatestResult();
    setState(() => _isFetchingLatest = false);

    if (result != null && mounted) {
      ref.read(resultProvider.notifier).setResult(result);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HasilPrediksiScreen(result: result)),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada data kuesioner sebelumnya'),
          backgroundColor: AppColors.amber,
        ),
      );
    }
  }

  void _nextPage() {
    final state = ref.read(questionnaireProvider);
    bool isPageValid = false;

    if (state.currentPage == 0) {
      isPageValid = state.form.isPage1Complete;
    } else if (state.currentPage == 1) {
      isPageValid = state.form.isPage2Complete;
    } else {
      isPageValid = state.form.isPage3Complete;
    }

    if (!isPageValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mohon isi semua pertanyaan di halaman ini sebelum lanjut.',
          ),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (state.isLastPage) {
      _submit();
    } else {
      ref.read(questionnaireProvider.notifier).nextPage();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    final state = ref.read(questionnaireProvider);
    if (_showSelection) {
      Navigator.pop(context);
      return;
    }

    if (state.currentPage > 0) {
      ref.read(questionnaireProvider.notifier).prevPage();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _showSelection = true);
    }
  }

  Future<void> _submit() async {
    final state = ref.read(questionnaireProvider);
    if (!state.form.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ada pertanyaan yang terlewat. Mohon periksa kembali.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref
        .read(questionnaireProvider.notifier)
        .submit(useMock: _useMockSurvey);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      final result = ref.read(questionnaireProvider).result;
      if (result != null) {
        ref.read(resultProvider.notifier).setResult(result);
      }
      ref.read(questionnaireProvider.notifier).reset(keepResult: true);
      setState(() => _showSelection = true);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HasilPrediksiScreen(result: result)),
      );
    } else {
      final error =
          ref.read(questionnaireProvider).errorMessage ??
          'Gagal memproses data';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_showSelection) return _buildSelectionView();

    final state = ref.watch(questionnaireProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.bgLight,
          body: Stack(
            children: [
              _buildBackgroundDecorations(),
              SafeArea(
                child: Column(
                  children: [
                    _buildTopbarContainer(state),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgLight,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _PagePenggunaanDigital(),
                              _PageAktivitasTidur(),
                              _PageKondisiMental(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildBottomBar(state),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isSubmitting) const _SubmittingOverlay(),
      ],
    );
  }

  // ── Background Decorations ─────────────────────────────────────────────────

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.textDark,
                AppColors.textDark.withValues(alpha: 0.95),
              ],
            ),
          ),
        ),
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal.withValues(alpha: 0.15),
            ),
          ),
        ),
        Positioned(
          top: 100,
          left: -50,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue.withValues(alpha: 0.1),
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: 80,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.amber.withValues(alpha: 0.1),
            ),
          ),
        ),
      ],
    );
  }

  // ── Topbar Container ───────────────────────────────────────────────────────

  Widget _buildTopbarContainer(QuestionnaireState state) {
    const titles = [
      'Penggunaan Digital',
      'Aktivitas & Tidur',
      'Kondisi Mental',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _prevPage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kuesioner Digital',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      titles[state.currentPage],
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Halaman ${state.currentPage + 1} dari ${QuestionnaireState.totalPages}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                height: 8,
                width:
                    MediaQuery.of(context).size.width *
                        ((state.currentPage + 1) /
                            QuestionnaireState.totalPages) -
                    40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.teal.withValues(alpha: 0.7),
                      AppColors.teal,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStepIndicator(state),
        ],
      ),
    );
  }

  // ── Step Indicator ─────────────────────────────────────────────────────────

  Widget _buildStepIndicator(QuestionnaireState state) {
    const steps = [
      'Penggunaan\nDigital',
      'Aktivitas &\nTidur',
      'Kondisi\nMental',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length, (index) {
        final isActive = index == state.currentPage;
        final isCompleted = index < state.currentPage;

        return Row(
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? AppColors.teal
                        : isCompleted
                        ? const Color(0xFF5EEAD4)
                        : Colors.white.withValues(alpha: 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: isActive
                            ? AppColors.teal.withValues(alpha: 0.5)
                            : AppColors.teal.withValues(alpha: 0.0),
                        blurRadius: 12,
                        offset: isActive ? const Offset(0, 4) : Offset.zero,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive || isCompleted
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFF5EEAD4)
                        : isCompleted
                        ? const Color(0xFF0F766E)
                        : Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            if (index < steps.length - 1) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 28),
                width: 40,
                height: 2,
                color: index < state.currentPage
                    ? const Color(0xFF5EEAD4)
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ],
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // SELECTION VIEW — Redesigned premium wellness landing
  // ══════════════════════════════════════════════════════════════════════════════

  Widget _buildSelectionView() {
    return Scaffold(
      backgroundColor: _kDeepNavy,
      body: Column(
        children: [
          // ── Dark navy header — compact, like dashboard topbar ───────────
          _buildSelectionHeader(),

          // ── Wave + white card area — fills remaining space ──────────────
          Expanded(
            child: Stack(
              children: [
                _buildWaveContentArea(),

                // Bottom nav pinned at the very bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BottomNav(
                    currentIndex: 1,
                    navTheme: NavTheme.light,
                    onTap: _onNavTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header (dark navy area) ────────────────────────────────────────────────

  Widget _buildSelectionHeader() {
    // Compact header — hanya wraps kontennya, tidak Expanded
    return SafeArea(
      bottom: false,
      child: ClipRect(
        child: SizedBox(
          // Tinggi fixed mirip dashboard topbar: cukup untuk back btn + title
          height: 160,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Glow orb kiri atas
              Positioned(
                top: -40,
                left: -40,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kTeal.withValues(alpha: 0.18),
                  ),
                ),
              ),
              // Glow orb kanan
              Positioned(
                top: 10,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kPurple.withValues(alpha: 0.18),
                  ),
                ),
              ),
              // Partikel kecil
              Positioned(top: 20, left: 120, child: _dot(4, _kCyan)),
              Positioned(top: 55, left: 60, child: _dot(3, _kPurple)),
              Positioned(top: 30, right: 110, child: _dot(3, _kCyan)),
              Positioned(top: 100, right: 60, child: _dot(2, _kPurple)),

              // Konten utama
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Baris: back button + label chip + mascot
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _kCyan.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: _kCyan,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Label chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _kCyan.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: _kCyan.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _kCyan,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Activa AI',
                                style: TextStyle(
                                  color: _kCyan,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Mascot
                        _buildMascot(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title + subtitle
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Kuesioner ',
                            style: TextStyle(
                              color: _kIce,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                          TextSpan(
                            text: 'Analisis',
                            style: TextStyle(
                              color: _kCyan,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kenali pola digitalmu hari ini',
                      style: TextStyle(
                        color: _kIce.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: 0.7),
    ),
  );

  Widget _buildMascot() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kTeal, _kPurple],
        ),
        boxShadow: [
          BoxShadow(
            color: _kTeal.withValues(alpha: 0.45),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
child: ClipOval(
  child: Transform.scale(
    scale: 0.8, // sesuaikan nilai ini, 1.0 = ukuran normal
    child: Image.asset(
      'Assets/images/maskot.png',
      width: 72,
      height: 72,
      fit: BoxFit.cover,
    ),
  ),
),
),
    );
  }

  // ── Wave + white content area ──────────────────────────────────────────────

  Widget _buildWaveContentArea() {
    return SizedBox.expand(
      child: Stack(
        children: [
          // ── Ice white background — fills entire area ───────────────────
          Positioned.fill(child: Container(color: _kIce)),

          // ── Wave identik dengan dashboard _HeroHeader ──────────────────
          // Blok navy solid di atas, ClipPath ice white memotong bawahnya
          // membentuk kurva U terbalik (quadraticBezier) — sama dengan dashboard.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                Container(height: 52, color: _kDeepNavy),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipPath(
                    clipper: _KuesionerWaveClipper(),
                    child: Container(height: 40, color: _kIce),
                  ),
                ),
              ],
            ),
          ),

          // ── Card content — starts below the wave peak ──────────────────
          Positioned(
            top: 52,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
              child: Column(
                children: [
                  _selectionCard(
                    title: 'Mulai Kuesioner Baru',
                    desc:
                        'Lakukan analisis kondisi digital terbaru kamu hari ini.',
                    icon: Icons.assignment_rounded,
                    accentColor: _kTeal,
                    onTap: _startNew,
                    isPrimary: true,
                  ),
                  const SizedBox(height: 14),
                  _selectionCard(
                    title: 'Lihat Hasil Terakhir',
                    desc: 'Cek insight dan rekomendasi sebelumnya.',
                    icon: Icons.history_rounded,
                    accentColor: _kNavy,
                    onTap: _viewLatest,
                    isLoading: _isFetchingLatest,
                  ),
                  const SizedBox(height: 14),
                  _buildAiInfoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card 1 & 2 ─────────────────────────────────────────────────────────────

  Widget _selectionCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          // Primary card: dark navy; secondary: white
          color: isPrimary ? _kNavy : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isPrimary
                ? _kCyan.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? _kTeal.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isPrimary
                    ? _kTeal.withValues(alpha: 0.2)
                    : accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: isPrimary ? _kCyan : accentColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 18),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPrimary) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _kTeal.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _kCyan,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Tersedia Sekarang',
                            style: TextStyle(
                              color: _kCyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      color: isPrimary ? _kIce : _kDeepNavy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      color: isPrimary
                          ? _kIce.withValues(alpha: 0.55)
                          : Colors.black.withValues(alpha: 0.45),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Arrow / loader
            if (isLoading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.textMuted,
                ),
              )
            else
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? _kTeal.withValues(alpha: 0.25)
                      : _kDeepNavy.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: isPrimary ? _kCyan : _kDeepNavy.withValues(alpha: 0.4),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── AI Info Card ───────────────────────────────────────────────────────────

  Widget _buildAiInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kTeal.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kTeal.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _kTeal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🧠', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activa AI Insight',
                  style: TextStyle(
                    color: _kTeal,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Analisis ini membantu Activa memahami pola digitalmu dan memberikan insight yang lebih personal.',
                  style: TextStyle(
                    color: _kDeepNavy.withValues(alpha: 0.65),
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────────────────────────

  Widget _buildBottomBar(QuestionnaireState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: state.isLoading ? null : _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: AppColors.teal.withValues(alpha: 0.3),
          ),
          child: state.isLoading
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
                      'Memproses...',
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
                    Text(
                      state.isLastPage ? 'Lihat Hasil Analisis' : 'Selanjutnya',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      state.isLastPage
                          ? Icons.analytics_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WAVE CLIPPER — Copy persis dari dashboard _BottomWaveClipper
// Menghasilkan kurva U terbalik (busur ke atas) yang sama dengan header dashboard
// ══════════════════════════════════════════════════════════════════════════════

class _KuesionerWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = Path();

    // Mulai dari kiri bawah
    p.moveTo(0, s.height);

    // Naik ke kiri atas
    p.lineTo(0, s.height * 0.5);

    // Kurva quadratic: control point di puncak tengah → bentuk U terbalik
    p.quadraticBezierTo(
      s.width * 0.5, // control x — titik tarikan kurva (tengah)
      0, // control y — puncak lengkungan (atas)
      s.width, // end x — ujung kanan
      s.height * 0.5, // end y — kembali ke tengah kanan
    );

    // Turun ke kanan bawah lalu tutup
    p.lineTo(s.width, s.height);
    p.close();

    return p;
  }

  @override
  bool shouldReclip(_KuesionerWaveClipper old) => false;
}

// ══════════════════════════════════════════════════════════════════════════════
// HALAMAN 1 — PENGGUNAAN DIGITAL
// ══════════════════════════════════════════════════════════════════════════════

class _PagePenggunaanDigital extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(questionnaireProvider).form;
    final notifier = ref.read(questionnaireProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          _QuestionBlock(
            number: 1,
            question:
                'Berapa lama kamu menggunakan perangkat digital hari ini?',
            hint: 'Total semua perangkat (HP, laptop, tablet, dll)',
            child: FiveOptionGridPicker(
              options: const [
                GridOptionData(
                  label: 'Sangat Sedikit',
                  description: 'Kurang dari 2 jam total penggunaan perangkat.',
                  value: 1.5,
                ),
                GridOptionData(
                  label: 'Sedikit',
                  description: 'Sekitar 2–4 jam penggunaan perangkat.',
                  value: 3.0,
                ),
                GridOptionData(
                  label: 'Sedang',
                  description: 'Sekitar 4–7 jam penggunaan perangkat.',
                  value: 5.5,
                ),
                GridOptionData(
                  label: 'Lama',
                  description: 'Sekitar 7–10 jam penggunaan perangkat.',
                  value: 8.5,
                ),
                GridOptionData(
                  label: 'Sangat Lama',
                  description: 'Lebih dari 10 jam penggunaan perangkat.',
                  value: 12.0,
                ),
              ],
              selectedValue: form.deviceHoursPerDay,
              onChanged: (v) => notifier.setDeviceHours(v as double),
            ),
          ),
          const SizedBox(height: 28),

          _QuestionBlock(
            number: 2,
            question: 'Seberapa sering kamu membuka HP hari ini?',
            hint: 'Estimasi berapa kali kamu cek / unlock HP',
            child: FiveOptionGridPicker(
              options: const [
                GridOptionData(
                  label: 'Jarang',
                  description: 'Kurang dari 20 kali membuka HP hari ini.',
                  value: 10,
                ),
                GridOptionData(
                  label: 'Kadang-kadang',
                  description: 'Sekitar 20–50 kali membuka HP.',
                  value: 35,
                ),
                GridOptionData(
                  label: 'Cukup Sering',
                  description: 'Sekitar 50–100 kali membuka HP.',
                  value: 75,
                ),
                GridOptionData(
                  label: 'Sering',
                  description: 'Sekitar 100–200 kali membuka HP.',
                  value: 150,
                ),
                GridOptionData(
                  label: 'Sangat Sering',
                  description: 'Lebih dari 200 kali membuka HP.',
                  value: 250,
                ),
              ],
              selectedValue: form.phoneUnlocksPerDay,
              onChanged: (v) => notifier.setPhoneUnlocks(v as int),
            ),
          ),
          const SizedBox(height: 28),

          _QuestionBlock(
            number: 3,
            question: 'Berapa banyak notifikasi yang kamu terima hari ini?',
            hint: 'Gabungan semua aplikasi: WA, IG, email, dll',
            child: FiveOptionGridPicker(
              options: const [
                GridOptionData(
                  label: 'Hampir Tidak Ada',
                  description: 'Kurang dari 50 notifikasi sepanjang hari.',
                  value: 30,
                ),
                GridOptionData(
                  label: 'Sedikit',
                  description: 'Sekitar 50–200 notifikasi hari ini.',
                  value: 100,
                ),
                GridOptionData(
                  label: 'Lumayan',
                  description: 'Sekitar 200–500 notifikasi hari ini.',
                  value: 300,
                ),
                GridOptionData(
                  label: 'Banyak',
                  description: 'Sekitar 500–1000 notifikasi hari ini.',
                  value: 700,
                ),
                GridOptionData(
                  label: 'Sangat Banyak',
                  description: 'Lebih dari 1000 notifikasi hari ini.',
                  value: 1100,
                ),
              ],
              selectedValue: form.notificationsPerDay,
              onChanged: (v) => notifier.setNotifications(v as int),
            ),
          ),
          const SizedBox(height: 28),

          _QuestionBlock(
            number: 4,
            question: 'Berapa lama kamu menggunakan media sosial hari ini?',
            hint: 'Instagram, TikTok, Twitter, YouTube, dll',
            child: FiveOptionGridPicker(
              options: const [
                GridOptionData(
                  label: 'Tidak Pakai',
                  description: 'Hampir tidak pernah membuka media sosial.',
                  value: 0,
                ),
                GridOptionData(
                  label: 'Kurang dari 1 Jam',
                  description: 'Sekitar 30 menit di media sosial.',
                  value: 30,
                ),
                GridOptionData(
                  label: '1–3 Jam',
                  description: 'Sekitar 2 jam per hari di media sosial.',
                  value: 120,
                ),
                GridOptionData(
                  label: '3–5 Jam',
                  description: 'Sekitar 4 jam per hari di media sosial.',
                  value: 240,
                ),
                GridOptionData(
                  label: 'Lebih dari 5 Jam',
                  description: 'Sangat banyak waktu dihabiskan di sosmed.',
                  value: 400,
                ),
              ],
              selectedValue: form.socialMediaMinutes,
              onChanged: (v) => notifier.setSocialMediaMinutes(v as int),
            ),
          ),
          const SizedBox(height: 28),

          _QuestionBlock(
            number: 5,
            question: 'Seberapa produktif kamu belajar atau bekerja hari ini?',
            hint: 'Waktu fokus tanpa distraksi',
            child: FiveOptionGridPicker(
              options: const [
                GridOptionData(
                  label: 'Hampir Tidak Ada',
                  description: 'Kurang dari 30 menit waktu fokus hari ini.',
                  value: 10,
                ),
                GridOptionData(
                  label: 'Sedikit',
                  description: 'Sekitar 30 menit hingga 1 jam waktu fokus.',
                  value: 60,
                ),
                GridOptionData(
                  label: 'Cukup',
                  description:
                      'Sekitar 1–3 jam waktu belajar atau kerja fokus.',
                  value: 150,
                ),
                GridOptionData(
                  label: 'Produktif',
                  description:
                      'Sekitar 3–5 jam waktu belajar atau kerja fokus.',
                  value: 300,
                ),
                GridOptionData(
                  label: 'Sangat Produktif',
                  description: 'Lebih dari 5 jam waktu fokus penuh hari ini.',
                  value: 400,
                ),
              ],
              selectedValue: form.studyMinutes,
              onChanged: (v) => notifier.setStudyMinutes(v as int),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HALAMAN 2 — AKTIVITAS & TIDUR
// ══════════════════════════════════════════════════════════════════════════════

class _PageAktivitasTidur extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(questionnaireProvider).form;
    final notifier = ref.read(questionnaireProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          _QuestionBlock(
            number: 6,
            question: 'Berapa jam kamu tidur per malam?',
            hint: 'Rata-rata dalam 7 hari terakhir',
            icon: Icons.nights_stay_rounded,
            child: Column(
              children: [
                QuestionSlider(
                  value: form.sleepHours,
                  min: 3,
                  max: 11,
                  divisions: 16,
                  unit: 'jam',
                  minLabel: '3 Jam',
                  maxLabel: '11 Jam',
                  activeColor: AppColors.teal,
                  qualityLabel: _getSleepQualityLabel(form.sleepHours),
                  onChanged: (v) => notifier.setSleepHours(v),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _QuestionBlock(
            number: 7,
            question: 'Berapa hari kamu berolahraga minggu ini?',
            hint: 'Olahraga minimal 30 menit, termasuk jalan kaki',
            icon: Icons.fitness_center_rounded,
            child: Column(
              children: [
                QuestionSlider(
                  value: form.physicalActivityDays.toDouble(),
                  min: 0,
                  max: 7,
                  divisions: 7,
                  unit: 'hari',
                  minLabel: '0 Hari',
                  maxLabel: '7 Hari',
                  activeColor: AppColors.blue,
                  qualityLabel: _getActivityQualityLabel(
                    form.physicalActivityDays,
                  ),
                  onChanged: (v) => notifier.setPhysicalActivityDays(v.round()),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  icon: Icons.flash_on_rounded,
                  color: AppColors.amber,
                  text: '3 hari olahraga menurunkan resiko stress 15%.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _QuestionBlock(
            number: 8,
            question: 'Bagaimana kualitas tidurmu secara umum?',
            hint: 'Pilih yang paling menggambarkan tidurmu',
            child: FiveOptionGridPicker(
              options: const [
                GridOptionData(
                  label: 'Sangat Buruk',
                  description:
                      'Sering terbangun dan tidak merasa segar pagi ini.',
                  value: 1.0,
                ),
                GridOptionData(
                  label: 'Buruk',
                  description: 'Kadang terbangun, kurang segar saat bangun.',
                  value: 2.0,
                ),
                GridOptionData(
                  label: 'Cukup',
                  description: 'Tidur cukup namun belum terasa optimal.',
                  value: 3.0,
                ),
                GridOptionData(
                  label: 'Baik',
                  description: 'Tidur nyenyak dan merasa segar saat bangun.',
                  value: 4.0,
                ),
                GridOptionData(
                  label: 'Sangat Baik',
                  description: 'Tidur sangat nyenyak dan berkualitas tinggi.',
                  value: 5.0,
                ),
              ],
              selectedValue: form.sleepQuality,
              onChanged: (v) => notifier.setSleepQuality(v as double),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getSleepQualityLabel(double hours) {
    if (hours < 5) return 'KURANG TIDUR';
    if (hours < 7) return 'TIDUR CUKUP';
    if (hours <= 9) return 'KUALITAS OPTIMAL';
    return 'TIDUR BERLEBIH';
  }

  String _getActivityQualityLabel(int days) {
    if (days == 0) return 'TIDAK AKTIF';
    if (days <= 2) return 'KONSISTENSI RENDAH';
    if (days <= 4) return 'KONSISTENSI MENENGAH';
    if (days <= 6) return 'KONSISTENSI TINGGI';
    return 'SANGAT AKTIF';
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textDark.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HALAMAN 3 — KONDISI MENTAL
// ══════════════════════════════════════════════════════════════════════════════

class _PageKondisiMental extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(questionnaireProvider).form;
    final notifier = ref.read(questionnaireProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          _buildDisclaimer(),
          const SizedBox(height: 32),

          _QuestionBlock(
            number: 9,
            question:
                'Seberapa sering kamu merasa cemas atau gelisah hari ini?',
            hint: 'Contoh: rasa takut, gugup, atau tidak bisa rileks',
            child: FiveOptionGridPicker(
              options: const [
                GridOptionData(
                  label: 'Sangat Jarang',
                  description: 'Hampir tidak pernah merasa cemas.',
                  value: 1.0,
                ),
                GridOptionData(
                  label: 'Jarang',
                  description: 'Sesekali muncul rasa cemas.',
                  value: 7.0,
                ),
                GridOptionData(
                  label: 'Sedang',
                  description: 'Kadang-kadang merasa cemas.',
                  value: 14.0,
                ),
                GridOptionData(
                  label: 'Sering',
                  description: 'Cukup sering merasa cemas atau gelisah.',
                  value: 21.0,
                ),
                GridOptionData(
                  label: 'Sangat Sering',
                  description: 'Hampir setiap saat merasa cemas.',
                  value: 27.0,
                ),
              ],
              selectedValue: form.anxietyScore,
              onChanged: (v) => notifier.setAnxietyScore(v as double),
            ),
          ),
          const SizedBox(height: 32),

          _QuestionBlock(
            number: 10,
            question:
                'Seberapa sering kamu merasa sedih atau tidak bersemangat hari ini?',
            hint: 'Pilih yang paling menggambarkan kondisimu',
            child: FiveOptionGridPicker(
              options: const [
                GridOptionData(
                  label: 'Sangat Jarang',
                  description: 'Hampir tidak pernah merasa sedih.',
                  value: 1.0,
                ),
                GridOptionData(
                  label: 'Jarang',
                  description: 'Sesekali merasa kurang bersemangat.',
                  value: 7.0,
                ),
                GridOptionData(
                  label: 'Sedang',
                  description: 'Kadang-kadang merasa sedih atau lesu.',
                  value: 14.0,
                ),
                GridOptionData(
                  label: 'Sering',
                  description:
                      'Cukup sering merasa sedih atau tidak berenergi.',
                  value: 21.0,
                ),
                GridOptionData(
                  label: 'Sangat Sering',
                  description:
                      'Hampir setiap saat merasa sedih atau putus asa.',
                  value: 27.0,
                ),
              ],
              selectedValue: form.depressionScore,
              onChanged: (v) => notifier.setDepressionScore(v as double),
            ),
          ),
          const SizedBox(height: 28),

          _QuestionBlock(
            number: 11,
            question: 'Seberapa tinggi tingkat stresmu minggu ini?',
            hint: 'Pilih yang paling menggambarkan tingkat stresmu',
            icon: Icons.psychology_rounded,
            child: FiveOptionGridPicker(
              options: const [
                GridOptionData(
                  label: 'Sangat Rendah',
                  description: 'Merasa tenang dan hampir tidak ada tekanan.',
                  value: 1.0,
                ),
                GridOptionData(
                  label: 'Rendah',
                  description:
                      'Sedikit tekanan namun masih terkendali dengan baik.',
                  value: 3.0,
                ),
                GridOptionData(
                  label: 'Sedang',
                  description:
                      'Ada tekanan yang terasa namun masih bisa diatasi.',
                  value: 5.0,
                ),
                GridOptionData(
                  label: 'Tinggi',
                  description: 'Merasa cukup tertekan dan sulit untuk rileks.',
                  value: 7.0,
                ),
                GridOptionData(
                  label: 'Sangat Tinggi',
                  description:
                      'Tekanan sangat berat dan mengganggu aktivitas sehari-hari.',
                  value: 10.0,
                ),
              ],
              selectedValue: form.stressLevel,
              onChanged: (v) => notifier.setStressLevel(v as double),
            ),
          ),
          const SizedBox(height: 28),

          _QuestionBlock(
            number: 12,
            question: 'Seberapa bahagia perasaanmu?',
            hint: 'Pilih yang menggambarkan suasana hatimu',
            icon: Icons.sentiment_satisfied_alt_rounded,
            child: FiveOptionGridPicker(
              options: const [
                GridOptionData(
                  label: 'Sangat Sedih',
                  description:
                      'Merasa sangat tidak bahagia atau hampa hari ini.',
                  value: 1.0,
                ),
                GridOptionData(
                  label: 'Sedih',
                  description:
                      'Suasana hati kurang baik dan kurang bersemangat.',
                  value: 3.0,
                ),
                GridOptionData(
                  label: 'Biasa',
                  description:
                      'Perasaan netral, tidak sedih namun tidak gembira.',
                  value: 5.0,
                ),
                GridOptionData(
                  label: 'Bahagia',
                  description: 'Merasa cukup bahagia dan bersemangat hari ini.',
                  value: 7.0,
                ),
                GridOptionData(
                  label: 'Sangat Bahagia',
                  description:
                      'Merasa sangat gembira dan penuh energi positif.',
                  value: 10.0,
                ),
              ],
              selectedValue: form.happinessScore,
              onChanged: (v) => notifier.setHappinessScore(v as double),
            ),
          ),
          const SizedBox(height: 24),

          _buildQuoteCard(),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Data Anda aman dan akan digunakan untuk memberikan rekomendasi kesehatan personal. Klik tombol di bawah untuk memproses hasil akhir.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.8),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.amber.withValues(alpha: 0.12),
            AppColors.amber.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.favorite_rounded, color: AppColors.amber, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hampir selesai! Mari lihat kondisi emosionalmu.',
                  style: TextStyle(
                    color: AppColors.textDark.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jawab dengan jujur. Semua jawaban bersifat rahasia.',
                  style: TextStyle(
                    color: AppColors.textDark.withValues(alpha: 0.6),
                    fontSize: 12,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.amber.withValues(alpha: 0.3),
            AppColors.teal.withValues(alpha: 0.4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.format_quote_rounded,
              size: 100,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '"Kebahagiaan dimulai dari rasa syukur."',
                  style: TextStyle(
                    color: AppColors.textDark.withValues(alpha: 0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '- Activa Wellness',
                  style: TextStyle(
                    color: AppColors.textDark.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

// ══════════════════════════════════════════════════════════════════════════════
// SUBMITTING OVERLAY
// ══════════════════════════════════════════════════════════════════════════════

class _SubmittingOverlay extends StatefulWidget {
  const _SubmittingOverlay();

  @override
  State<_SubmittingOverlay> createState() => _SubmittingOverlayState();
}

class _SubmittingOverlayState extends State<_SubmittingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _stepCtrl;
  late final Animation<double> _pulseAnim;

  int _currentStep = 0;

  static const _steps = [
    (Icons.upload_rounded, 'Mengirim data kuesioner ke server...'),
    (
      Icons.psychology_rounded,
      'Model AI sedang menganalisis pola digitalmu...',
    ),
    (Icons.auto_graph_rounded, 'Menghitung skor ketergantungan digital...'),
    (
      Icons.check_circle_outline_rounded,
      'Menyiapkan hasil & rekomendasi untukmu...',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _stepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cycleSteps();
  }

  void _cycleSteps() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 2200));
      if (!mounted) break;
      setState(() => _currentStep = (_currentStep + 1) % _steps.length);
      _stepCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _stepCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kDeepNavy.withValues(alpha: 0.97),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kTeal.withValues(alpha: 0.08),
                    boxShadow: [
                      BoxShadow(
                        color: _kTeal.withValues(
                          alpha: _pulseAnim.value * 0.35,
                        ),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    color: _kTeal.withValues(alpha: _pulseAnim.value),
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Sedang Menganalisis...',
                style: TextStyle(
                  color: _kIce,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mohon tunggu, jangan tutup aplikasi ini',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _kIce.withValues(alpha: 0.45),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 36),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: _kNavy.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kIce.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: List.generate(_steps.length, (i) {
                    final isDone = i < _currentStep;
                    final isActive = i == _currentStep;
                    final color = isDone || isActive
                        ? _kTeal
                        : _kIce.withValues(alpha: 0.2);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (isDone || isActive)
                                  ? _kTeal.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              border: Border.all(
                                color: color,
                                width: isActive ? 2 : 1.5,
                              ),
                            ),
                            child: isDone
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: _kTeal,
                                    size: 16,
                                  )
                                : Icon(_steps[i].$1, color: color, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _steps[i].$2,
                              style: TextStyle(
                                color: isActive
                                    ? _kIce
                                    : isDone
                                    ? _kTeal.withValues(alpha: 0.7)
                                    : _kIce.withValues(alpha: 0.3),
                                fontSize: 13,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (isActive)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _kTeal,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 28),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / _steps.length,
                  minHeight: 4,
                  backgroundColor: _kTeal.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(_kTeal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REUSABLE — QUESTION BLOCK
// ══════════════════════════════════════════════════════════════════════════════

class _QuestionBlock extends StatelessWidget {
  final int number;
  final String question;
  final String? hint;
  final IconData? icon;
  final Widget child;

  const _QuestionBlock({
    required this.number,
    required this.question,
    required this.child,
    this.hint,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.teal, size: 18),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          if (hint != null) ...[
            const SizedBox(height: 6),
            Text(
              hint!,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════��════════════
// DATA CLASS FOR 5 OPTIONS
// ═══════════════════════════════════════════════════════════════════════════════

class _OptionData {
  final String label;
  final int value;

  const _OptionData({required this.label, required this.value});
}

// ═══════════════════════════════════════════════════════════════════════════════
// 5 OPTION PICKER WITH PYRAMID LAYOUT
// Layout: 1 kiri, 2 kanan, 3 bawah 1, 4 bawah 2, 5 center bawah
// ═══════════════════════════════════════════════════════════════════════════════

class _FiveOptionPicker extends StatelessWidget {
  final List<_OptionData> options;
  final int selectedValue;
  final String? lowLabel;
  final String? highLabel;
  final bool invertColor;
  final ValueChanged<int> onChanged;

  const _FiveOptionPicker({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.lowLabel,
    this.highLabel,
    this.invertColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Labels row
        if (lowLabel != null || highLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lowLabel ?? '',
                  style: TextStyle(
                    color: invertColor ? AppColors.green : AppColors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  highLabel ?? '',
                  style: TextStyle(
                    color: invertColor ? AppColors.red : AppColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

        // Row 1: Options 1 & 2
        Row(
          children: [
            Expanded(child: _buildOptionButton(options[0], 0)),
            const SizedBox(width: 10),
            Expanded(child: _buildOptionButton(options[1], 1)),
          ],
        ),
        const SizedBox(height: 10),

        // Row 2: Options 3 & 4
        Row(
          children: [
            Expanded(child: _buildOptionButton(options[2], 2)),
            const SizedBox(width: 10),
            Expanded(child: _buildOptionButton(options[3], 3)),
          ],
        ),
        const SizedBox(height: 10),

        // Row 3: Option 5 (centered)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: _buildOptionButton(options[4], 4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionButton(_OptionData option, int index) {
    final isSelected = option.value == selectedValue;
    final color = _getColorForIndex(index);

    return GestureDetector(
      onTap: () => onChanged(option.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            option.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    // 5 options: 0=lowest, 1, 2=middle, 3, 4=highest
    if (invertColor) {
      // For stress: low = good (green), high = bad (red)
      switch (index) {
        case 0:
          return AppColors.green;
        case 1:
          return AppColors.green.withValues(alpha: 0.8);
        case 2:
          return AppColors.amber;
        case 3:
          return AppColors.red.withValues(alpha: 0.8);
        case 4:
          return AppColors.red;
        default:
          return AppColors.amber;
      }
    } else {
      // For happiness: low = bad (red), high = good (green)
      switch (index) {
        case 0:
          return AppColors.red;
        case 1:
          return AppColors.red.withValues(alpha: 0.8);
        case 2:
          return AppColors.amber;
        case 3:
          return AppColors.green.withValues(alpha: 0.8);
        case 4:
          return AppColors.green;
        default:
          return AppColors.amber;
      }
    }
  }
}
