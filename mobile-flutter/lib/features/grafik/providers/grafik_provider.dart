// lib/features/grafik/providers/grafik_provider.dart
//
// Provider yang meng-expose GrafikData ke GrafikScreen.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../faker/grafik_faker.dart';
import '../services/grafik_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class GrafikState {
  final GrafikData data;
  final GrafikPeriod period;
  final bool isLoading;
  final String? errorMessage;

  const GrafikState({
    required this.data,
    required this.period,
    required this.isLoading,
    this.errorMessage,
  });

  GrafikState copyWith({
    GrafikData? data,
    GrafikPeriod? period,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GrafikState(
      data: data ?? this.data,
      period: period ?? this.period,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class GrafikNotifier extends Notifier<GrafikState> {
  @override
  GrafikState build() {
    // Mulai mengambil data secara asynchronous saat inisialisasi
    Future.microtask(() => fetchGrafikData(GrafikPeriod.week));

    return const GrafikState(
      data: GrafikData(
        entries: [],
        kategori: GrafikKategori(low: 0, medium: 0, high: 0),
      ),
      period: GrafikPeriod.week,
      isLoading: true,
    );
  }

  /// Fetch data grafik dari API berdasarkan periode
  Future<void> fetchGrafikData(GrafikPeriod period) async {
    state = state.copyWith(isLoading: true, clearError: true, period: period);

    try {
      final service = ref.read(grafikServiceProvider);
      final data = await service.getGrafikData(period);
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
}

// ── Provider ──────────────────────────────────────────────────────────────────

final grafikProvider = NotifierProvider<GrafikNotifier, GrafikState>(
  GrafikNotifier.new,
);
