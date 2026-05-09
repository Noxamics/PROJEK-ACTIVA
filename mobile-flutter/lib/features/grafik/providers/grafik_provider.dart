// lib/features/grafik/providers/grafik_provider.dart
//
// Provider yang meng-expose GrafikData ke GrafikScreen.
// Saat backend siap, hanya file ini yang perlu diubah:
//   1. Ganti GrafikFaker.generate() → await GrafikService.fetch(period)
//   2. Ubah AsyncValue<GrafikData> jika perlu handle loading/error dari API
//   Tidak ada perubahan di widget atau screen.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../faker/grafik_faker.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class GrafikState {
  final GrafikData data;
  final GrafikPeriod period;

  const GrafikState({required this.data, required this.period});

  GrafikState copyWith({GrafikData? data, GrafikPeriod? period}) {
    return GrafikState(data: data ?? this.data, period: period ?? this.period);
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class GrafikNotifier extends Notifier<GrafikState> {
  @override
  GrafikState build() {
    // Default: tampilkan data 7 hari pertama kali
    return GrafikState(
      data: GrafikFaker.generate(period: GrafikPeriod.week),
      period: GrafikPeriod.week,
    );
  }

  /// Ganti periode dan regenerate data.
  /// TODO (backend): ganti GrafikFaker.generate() dengan service call di sini.
  void setPeriod(GrafikPeriod period) {
    state = state.copyWith(
      period: period,
      data: GrafikFaker.generate(period: period),

      // ── Contoh saat sudah pakai API: ──────────────────────────────────────
      // data: await GrafikService.fetchByPeriod(period),
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final grafikProvider = NotifierProvider<GrafikNotifier, GrafikState>(
  GrafikNotifier.new,
);
