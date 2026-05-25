import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/laporan_model.dart';
import '../../../core/network/api_client.dart'; // sesuaikan path
import '../../../core/network/api_endpoints.dart'; // sesuaikan path
import '../../auth/providers/auth_provider.dart';

// ── State ──────────────────────────────────────────────────────────────────

class LaporanState {
  final LaporanModel? data;
  final bool isLoading;
  final String? error;

  const LaporanState({this.data, this.isLoading = false, this.error});

  LaporanState copyWith({LaporanModel? data, bool? isLoading, String? error}) =>
      LaporanState(
        data: data ?? this.data,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────

class LaporanNotifier extends StateNotifier<LaporanState> {
  final ApiClient _api;

  LaporanNotifier(this._api) : super(const LaporanState());

  Future<void> fetchLaporan() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.get(ApiEndpoints.laporan);

      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true) {
        state = state.copyWith(
          data: LaporanModel.fromJson(body),
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: body['message'] ?? 'Gagal memuat laporan',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        // Data belum cukup 14 — normal, bukan error kritis
        state = state.copyWith(isLoading: false, error: 'insufficient_data');
      } else {
        final msg =
            e.response?.data?['message'] ?? e.message ?? 'Terjadi kesalahan';
        state = state.copyWith(isLoading: false, error: msg);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final laporanProvider = StateNotifierProvider<LaporanNotifier, LaporanState>((
  ref,
) {
  ref.watch(isAuthenticatedProvider);
  final api = ref.watch(apiClientProvider); // pakai provider yang sudah ada
  return LaporanNotifier(api);
});
