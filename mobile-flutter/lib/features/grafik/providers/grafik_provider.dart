// lib/features/grafik/providers/grafik_provider.dart
//
// Provider yang meng-expose GrafikData ke GrafikScreen.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../faker/grafik_faker.dart';
import '../services/grafik_service.dart';
import '../../auth/providers/auth_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class GrafikState {
  final GrafikData data;
  final GrafikPeriod period;
  final bool isLoading;
  final String? errorMessage;

  /// Bulan yang dipilih untuk tampilan Bulanan (1–12)
  final int selectedMonth;

  /// Tahun yang dipilih untuk tampilan Bulanan
  final int selectedYear;

  const GrafikState({
    required this.data,
    required this.period,
    required this.isLoading,
    this.errorMessage,
    required this.selectedMonth,
    required this.selectedYear,
  });

  GrafikState copyWith({
    GrafikData? data,
    GrafikPeriod? period,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? selectedMonth,
    int? selectedYear,
  }) {
    return GrafikState(
      data: data ?? this.data,
      period: period ?? this.period,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class GrafikNotifier extends Notifier<GrafikState> {
  @override
  GrafikState build() {
    ref.watch(isAuthenticatedProvider);

    final now = DateTime.now();

    // Mulai mengambil data secara asynchronous saat inisialisasi
    Future.microtask(() => fetchGrafikData(GrafikPeriod.week));

    return GrafikState(
      data: const GrafikData(
        entries: [],
        kategori: GrafikKategori(low: 0, medium: 0, high: 0),
      ),
      period: GrafikPeriod.week,
      isLoading: true,
      selectedMonth: now.month,
      selectedYear: now.year,
    );
  }

  /// Fetch data grafik dari API berdasarkan periode
  Future<void> fetchGrafikData(GrafikPeriod period) async {
    state = state.copyWith(isLoading: true, clearError: true, period: period);

    try {
      final service = ref.read(grafikServiceProvider);

      final GrafikData data;
      if (period == GrafikPeriod.month) {
        data = await service.getGrafikData(
          period,
          month: state.selectedMonth,
          year: state.selectedYear,
        );
      } else {
        data = await service.getGrafikData(period);
      }

      state = state.copyWith(isLoading: false, data: data);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Ganti periode dan ambil data baru.
  void setPeriod(GrafikPeriod period) {
    fetchGrafikData(period);
  }

  /// Ganti bulan yang dipilih (untuk tampilan Bulanan) dan fetch ulang data.
  void setMonth(int month, int year) {
    state = state.copyWith(selectedMonth: month, selectedYear: year);
    fetchGrafikData(GrafikPeriod.month);
  }

  /// Navigasi ke bulan sebelumnya
  void previousMonth() {
    int m = state.selectedMonth - 1;
    int y = state.selectedYear;
    if (m < 1) {
      m = 12;
      y--;
    }
    setMonth(m, y);
  }

  /// Navigasi ke bulan berikutnya
  void nextMonth() {
    final now = DateTime.now();
    int m = state.selectedMonth + 1;
    int y = state.selectedYear;
    if (m > 12) {
      m = 1;
      y++;
    }
    // Jangan izinkan navigasi ke bulan di masa depan
    if (y > now.year || (y == now.year && m > now.month)) return;
    setMonth(m, y);
  }

  /// Cek apakah bisa navigasi ke bulan berikutnya
  bool get canGoNextMonth {
    final now = DateTime.now();
    int m = state.selectedMonth + 1;
    int y = state.selectedYear;
    if (m > 12) {
      m = 1;
      y++;
    }
    return !(y > now.year || (y == now.year && m > now.month));
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final grafikProvider = NotifierProvider<GrafikNotifier, GrafikState>(
  GrafikNotifier.new,
);