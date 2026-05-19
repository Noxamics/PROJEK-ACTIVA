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

class KuesionerScreen extends ConsumerStatefulWidget {
  const KuesionerScreen({super.key});

  @override
  ConsumerState<KuesionerScreen> createState() => _KuesionerScreenState();
}

class _KuesionerScreenState extends ConsumerState<KuesionerScreen> {
  late final PageController _pageController;
  bool _showSelection = true;
  bool _isFetchingLatest = false;

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

    final success = await ref
        .read(questionnaireProvider.notifier)
        .submit(useMock: _useMockSurvey);

    if (success && mounted) {
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
    } else if (!success && mounted) {
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

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          // Background decorations
          _buildBackgroundDecorations(),

          SafeArea(
            child: Column(
              children: [
                // Topbar Container
                _buildTopbarContainer(state),

                // Content Container
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
    );
  }

  // ── Background Decorations ─────────────────────────────────────────────────

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        // Gradient background
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
        // Decorative circles
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
          // Header row
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

          // Progress bar with glow
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

          // Step indicator
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
                        ? const Color(0xFF5EEAD4) // Light teal
                        : Colors.white.withValues(alpha: 0.2),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.teal.withValues(alpha: 0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
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
                        ? const Color(0xFF5EEAD4) // Light teal
                        : isCompleted
                        ? const Color(0xFF0F766E) // Dark teal
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

  // ── Selection View ─────────────────────────────────────────────────────────

  Widget _buildSelectionView() {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 20, 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kuesioner Analisis',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pilih opsi di bawah untuk lanjut',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _selectionCard(
                        title: 'Mulai Kuesioner Baru',
                        desc: 'Lakukan analisis kondisi terbaru kamu hari ini.',
                        icon: Icons.assignment_rounded,
                        color: AppColors.teal,
                        onTap: _startNew,
                      ),
                      const SizedBox(height: 20),
                      _selectionCard(
                        title: 'Lihat Hasil Terakhir',
                        desc:
                            'Cek rangkuman dan rekomendasi kuesioner sebelumnya.',
                        icon: Icons.history_rounded,
                        color: AppColors.blue,
                        onTap: _viewLatest,
                        isLoading: _isFetchingLatest,
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.teal.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.teal,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Analisis ini membantu kami memberikan rekomendasi gaya hidup digital yang lebih baik.',
                                style: TextStyle(
                                  color: AppColors.textDark.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            BottomNav(
              currentIndex: 1,
              navTheme: NavTheme.light,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectionCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.textMuted,
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade300,
                size: 16,
              ),
          ],
        ),
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

// ═══════════════════════════════════════════════════════════════════════════════
// HALAMAN 1 — PENGGUNAAN DIGITAL
// Q1–Q5: Semua pilihan (option card)
// ═══════════════════════════════════════════════════════════════════════════════

class _PagePenggunaanDigital extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(questionnaireProvider).form;
    final notifier = ref.read(questionnaireProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          // Q1 — Lama pakai perangkat
          _QuestionBlock(
            number: 1,
            question:
                'Berapa lama kamu menggunakan perangkat digital hari ini?',
            hint: 'Total semua perangkat (HP, laptop, tablet, dll)',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Sangat Sedikit',
                  subtitle: 'Kurang dari 2 jam',
                  isSelected: form.deviceHoursPerDay == 1.5,
                  onTap: () => notifier.setDeviceHours(1.5),
                ),
                QuestionOptionCard(
                  label: 'Sedikit',
                  subtitle: 'Sekitar 2-4 jam',
                  isSelected: form.deviceHoursPerDay == 3.0,
                  onTap: () => notifier.setDeviceHours(3.0),
                ),
                QuestionOptionCard(
                  label: 'Sedang',
                  subtitle: 'Sekitar 4-7 jam',
                  isSelected: form.deviceHoursPerDay == 5.5,
                  onTap: () => notifier.setDeviceHours(5.5),
                ),
                QuestionOptionCard(
                  label: 'Lama',
                  subtitle: 'Sekitar 7-10 jam',
                  isSelected: form.deviceHoursPerDay == 8.5,
                  onTap: () => notifier.setDeviceHours(8.5),
                ),
                QuestionOptionCard(
                  label: 'Sangat Lama',
                  subtitle: 'Lebih dari 10 jam',
                  isSelected: form.deviceHoursPerDay == 12.0,
                  onTap: () => notifier.setDeviceHours(12.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Q2 — Buka HP
          _QuestionBlock(
            number: 2,
            question: 'Seberapa sering kamu membuka HP hari ini?',
            hint: 'Estimasi berapa kali kamu cek / unlock HP',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Jarang',
                  subtitle: 'Kurang dari 20 kali',
                  isSelected: form.phoneUnlocksPerDay == 10,
                  onTap: () => notifier.setPhoneUnlocks(10),
                ),
                QuestionOptionCard(
                  label: 'Kadang-kadang',
                  subtitle: 'Sekitar 20-50 kali',
                  isSelected: form.phoneUnlocksPerDay == 35,
                  onTap: () => notifier.setPhoneUnlocks(35),
                ),
                QuestionOptionCard(
                  label: 'Cukup Sering',
                  subtitle: 'Sekitar 50-100 kali',
                  isSelected: form.phoneUnlocksPerDay == 75,
                  onTap: () => notifier.setPhoneUnlocks(75),
                ),
                QuestionOptionCard(
                  label: 'Sering',
                  subtitle: 'Sekitar 100-200 kali',
                  isSelected: form.phoneUnlocksPerDay == 150,
                  onTap: () => notifier.setPhoneUnlocks(150),
                ),
                QuestionOptionCard(
                  label: 'Sangat Sering',
                  subtitle: 'Lebih dari 200 kali',
                  isSelected: form.phoneUnlocksPerDay == 250,
                  onTap: () => notifier.setPhoneUnlocks(250),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Q3 — Notifikasi
          _QuestionBlock(
            number: 3,
            question: 'Berapa banyak notifikasi yang kamu terima hari ini?',
            hint: 'Gabungan semua aplikasi: WA, IG, email, dll',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Hampir Tidak Ada',
                  subtitle: 'Kurang dari 50 notifikasi',
                  isSelected: form.notificationsPerDay == 30,
                  onTap: () => notifier.setNotifications(30),
                ),
                QuestionOptionCard(
                  label: 'Sedikit',
                  subtitle: 'Sekitar 50-200 notifikasi',
                  isSelected: form.notificationsPerDay == 100,
                  onTap: () => notifier.setNotifications(100),
                ),
                QuestionOptionCard(
                  label: 'Lumayan',
                  subtitle: 'Sekitar 200-500 notifikasi',
                  isSelected: form.notificationsPerDay == 300,
                  onTap: () => notifier.setNotifications(300),
                ),
                QuestionOptionCard(
                  label: 'Banyak',
                  subtitle: 'Sekitar 500-1000 notifikasi',
                  isSelected: form.notificationsPerDay == 700,
                  onTap: () => notifier.setNotifications(700),
                ),
                QuestionOptionCard(
                  label: 'Sangat Banyak',
                  subtitle: 'Lebih dari 1000 notifikasi',
                  isSelected: form.notificationsPerDay == 1100,
                  onTap: () => notifier.setNotifications(1100),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Q4 — Sosmed
          _QuestionBlock(
            number: 4,
            question: 'Berapa lama kamu menggunakan media sosial hari ini?',
            hint: 'Instagram, TikTok, Twitter, YouTube, dll',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Tidak Pakai',
                  subtitle: 'Hampir tidak pernah',
                  isSelected: form.socialMediaMinutes == 0,
                  onTap: () => notifier.setSocialMediaMinutes(0),
                ),
                QuestionOptionCard(
                  label: 'Kurang dari 1 Jam',
                  subtitle: 'Sekitar 30 menit',
                  isSelected: form.socialMediaMinutes == 30,
                  onTap: () => notifier.setSocialMediaMinutes(30),
                ),
                QuestionOptionCard(
                  label: '1-3 Jam',
                  subtitle: 'Sekitar 2 jam per hari',
                  isSelected: form.socialMediaMinutes == 120,
                  onTap: () => notifier.setSocialMediaMinutes(120),
                ),
                QuestionOptionCard(
                  label: '3-5 Jam',
                  subtitle: 'Sekitar 4 jam per hari',
                  isSelected: form.socialMediaMinutes == 240,
                  onTap: () => notifier.setSocialMediaMinutes(240),
                ),
                QuestionOptionCard(
                  label: 'Lebih dari 5 Jam',
                  subtitle: 'Sangat banyak waktu di sosmed',
                  isSelected: form.socialMediaMinutes == 400,
                  onTap: () => notifier.setSocialMediaMinutes(400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Q5 — Belajar/Kerja produktif
          _QuestionBlock(
            number: 5,
            question: 'Seberapa produktif kamu belajar atau bekerja hari ini?',
            hint: 'Waktu fokus tanpa distraksi',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Hampir Tidak Ada',
                  subtitle: 'Kurang dari 30 menit',
                  isSelected: form.studyMinutes == 10,
                  onTap: () => notifier.setStudyMinutes(10),
                ),
                QuestionOptionCard(
                  label: 'Sedikit',
                  subtitle: 'Sekitar 30 menit - 1 jam',
                  isSelected: form.studyMinutes == 60,
                  onTap: () => notifier.setStudyMinutes(60),
                ),
                QuestionOptionCard(
                  label: 'Cukup',
                  subtitle: 'Sekitar 1-3 jam',
                  isSelected: form.studyMinutes == 150,
                  onTap: () => notifier.setStudyMinutes(150),
                ),
                QuestionOptionCard(
                  label: 'Produktif',
                  subtitle: 'Sekitar 3-5 jam',
                  isSelected: form.studyMinutes == 300,
                  onTap: () => notifier.setStudyMinutes(300),
                ),
                QuestionOptionCard(
                  label: 'Sangat Produktif',
                  subtitle: 'Lebih dari 5 jam fokus',
                  isSelected: form.studyMinutes == 400,
                  onTap: () => notifier.setStudyMinutes(400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HALAMAN 2 — AKTIVITAS & TIDUR
// Q6: slider hari olahraga
// Q7: slider jam tidur
// Q8: pilihan kualitas tidur
// ═══════════════════════════════════════════════════════════════════════════════

class _PageAktivitasTidur extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(questionnaireProvider).form;
    final notifier = ref.read(questionnaireProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          // Q6 — Jam tidur (diutamakan dulu sesuai gambar)
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
                _buildInfoCard(
                  icon: Icons.info_outline_rounded,
                  color: AppColors.teal,
                  text: 'Rata-rata pengguna seusia Anda tidur 7.2 jam.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Q7 — Hari olahraga
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

          // Q8 — Kualitas tidur (pilihan)
          _QuestionBlock(
            number: 8,
            question: 'Bagaimana kualitas tidurmu secara umum?',
            hint: 'Pilih yang paling menggambarkan tidurmu',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Sangat Buruk',
                  subtitle: 'Sering terbangun, tidak segar',
                  isSelected: form.sleepQuality == 1.0,
                  onTap: () => notifier.setSleepQuality(1.0),
                ),
                QuestionOptionCard(
                  label: 'Buruk',
                  subtitle: 'Kadang terbangun, kurang segar',
                  isSelected: form.sleepQuality == 2.0,
                  onTap: () => notifier.setSleepQuality(2.0),
                ),
                QuestionOptionCard(
                  label: 'Cukup',
                  subtitle: 'Tidur cukup tapi tidak optimal',
                  isSelected: form.sleepQuality == 3.0,
                  onTap: () => notifier.setSleepQuality(3.0),
                ),
                QuestionOptionCard(
                  label: 'Baik',
                  subtitle: 'Tidur nyenyak, terasa segar',
                  isSelected: form.sleepQuality == 4.0,
                  onTap: () => notifier.setSleepQuality(4.0),
                ),
                QuestionOptionCard(
                  label: 'Sangat Baik',
                  subtitle: 'Tidur sangat nyenyak & berkualitas',
                  isSelected: form.sleepQuality == 5.0,
                  onTap: () => notifier.setSleepQuality(5.0),
                ),
              ],
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

// ═══════════════════════════════════════════════════════════════════════════════
// HALAMAN 3 — KONDISI MENTAL
// Q9: Anxiety 0–27
// Q10: Depresi  0–27
// Q11: Stres    1–10
// Q12: Happiness 0–10
// ═══════════════════════════════════════════════════════════════════════════════

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

          // Q9 — Anxiety (pilihan ganda, nilai ML: 1/7/14/21/27)
          _QuestionBlock(
            number: 9,
            question:
                'Seberapa sering kamu merasa cemas atau gelisah hari ini?',
            hint: 'Contoh: rasa takut, gugup, atau tidak bisa rileks',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Sangat Jarang',
                  subtitle: 'Hampir tidak pernah merasa cemas',
                  isSelected: form.anxietyScore == 1.0,
                  onTap: () => notifier.setAnxietyScore(1.0),
                ),
                QuestionOptionCard(
                  label: 'Jarang',
                  subtitle: 'Sesekali muncul rasa cemas',
                  isSelected: form.anxietyScore == 7.0,
                  onTap: () => notifier.setAnxietyScore(7.0),
                ),
                QuestionOptionCard(
                  label: 'Sedang',
                  subtitle: 'Kadang-kadang merasa cemas',
                  isSelected: form.anxietyScore == 14.0,
                  onTap: () => notifier.setAnxietyScore(14.0),
                ),
                QuestionOptionCard(
                  label: 'Sering',
                  subtitle: 'Cukup sering merasa cemas atau gelisah',
                  isSelected: form.anxietyScore == 21.0,
                  onTap: () => notifier.setAnxietyScore(21.0),
                ),
                QuestionOptionCard(
                  label: 'Sangat Sering',
                  subtitle: 'Hampir setiap saat merasa cemas',
                  isSelected: form.anxietyScore == 27.0,
                  onTap: () => notifier.setAnxietyScore(27.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Q10 — Depresi (pilihan ganda, nilai ML: 1/7/14/21/27)
          _QuestionBlock(
            number: 10,
            question:
                'Seberapa sering kamu merasa sedih atau tidak bersemangat hari ini?',
            hint: 'Pilih yang paling menggambarkan kondisimu',
            child: Column(
              children: [
                QuestionOptionCard(
                  label: 'Sangat Jarang',
                  subtitle: 'Hampir tidak pernah merasa sedih',
                  isSelected: form.depressionScore == 1.0,
                  onTap: () => notifier.setDepressionScore(1.0),
                ),
                QuestionOptionCard(
                  label: 'Jarang',
                  subtitle: 'Sesekali merasa kurang bersemangat',
                  isSelected: form.depressionScore == 7.0,
                  onTap: () => notifier.setDepressionScore(7.0),
                ),
                QuestionOptionCard(
                  label: 'Sedang',
                  subtitle: 'Kadang-kadang merasa sedih atau lesu',
                  isSelected: form.depressionScore == 14.0,
                  onTap: () => notifier.setDepressionScore(14.0),
                ),
                QuestionOptionCard(
                  label: 'Sering',
                  subtitle: 'Cukup sering merasa sedih atau tidak berenergi',
                  isSelected: form.depressionScore == 21.0,
                  onTap: () => notifier.setDepressionScore(21.0),
                ),
                QuestionOptionCard(
                  label: 'Sangat Sering',
                  subtitle: 'Hampir setiap saat merasa sedih atau putus asa',
                  isSelected: form.depressionScore == 27.0,
                  onTap: () => notifier.setDepressionScore(27.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Q11 — Stres (Scale Picker 1-10)
          _QuestionBlock(
            number: 11,
            question: 'Seberapa tinggi tingkat stresmu minggu ini?',
            hint: 'Pilih yang paling menggambarkan tingkat stresmu',
            icon: Icons.psychology_rounded,
            child: Column(
              children: [
                _FiveOptionPicker(
                  options: const [
                    _OptionData(label: 'Sangat Rendah', value: 1),
                    _OptionData(label: 'Rendah', value: 3),
                    _OptionData(label: 'Sedang', value: 5),
                    _OptionData(label: 'Tinggi', value: 7),
                    _OptionData(label: 'Sangat Tinggi', value: 10),
                  ],
                  selectedValue: form.stressLevel.round(),
                  lowLabel: 'Tenang',
                  highLabel: 'Sangat Stres',
                  invertColor: true, // tinggi = buruk (merah)
                  onChanged: (v) => notifier.setStressLevel(v.toDouble()),
                ),
                if (form.stressLevel >= 7) ...[
                  const SizedBox(height: 16),
                  _buildWarningCard(
                    'Tingkat stresmu berada di atas rata-rata. Cobalah untuk mengambil jeda sejenak.',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Q12 — Happiness (Scale Picker 1-10)
          _QuestionBlock(
            number: 12,
            question: 'Seberapa bahagia perasaanmu?',
            hint: 'Pilih yang menggambarkan suasana hatimu',
            icon: Icons.sentiment_satisfied_alt_rounded,
            child: _FiveOptionPicker(
              options: const [
                _OptionData(label: 'Sangat Sedih', value: 1),
                _OptionData(label: 'Sedih', value: 3),
                _OptionData(label: 'Biasa', value: 5),
                _OptionData(label: 'Bahagia', value: 7),
                _OptionData(label: 'Sangat Bahagia', value: 10),
              ],
              selectedValue: form.happinessScore.round(),
              lowLabel: 'Sedih',
              highLabel: 'Sangat Bahagia',
              invertColor: false, // tinggi = bagus (hijau)
              onChanged: (v) => notifier.setHappinessScore(v.toDouble()),
            ),
          ),
          const SizedBox(height: 24),

          // Motivational quote card
          _buildQuoteCard(),
          const SizedBox(height: 24),

          // Privacy note
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

  Widget _buildWarningCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.red.withValues(alpha: 0.8),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.red.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
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
          // Background pattern
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.format_quote_rounded,
              size: 100,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          // Content
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

// ═══════════════════════════════════════════════════════════════════════════════
// REUSABLE — QUESTION BLOCK
// ═══════════════════════════════════════════════════════════════════════════════

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
