// lib/features/grafik/providers/grafik_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../faker/grafik_faker.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum GrafikStatus { loading, success, error }

class GrafikState {
  final GrafikData? data;
  final GrafikPeriod period;
  final GrafikStatus status;
  final String? errorMessage;

  const GrafikState({
    this.data,
    this.period = GrafikPeriod.week,
    this.status = GrafikStatus.loading,
    this.errorMessage,
  });

  GrafikState copyWith({
    GrafikData? data,
    GrafikPeriod? period,
    GrafikStatus? status,
    String? errorMessage,
  }) {
    return GrafikState(
      data:         data         ?? this.data,
      period:       period       ?? this.period,
      status:       status       ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class GrafikNotifier extends AsyncNotifier<GrafikState> {
  @override
  Future<GrafikState> build() async {
    return _fetchAndBuild(GrafikPeriod.week);
  }

  /// Ganti periode dan fetch ulang data dari API.
  Future<void> setPeriod(GrafikPeriod period) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAndBuild(period));
  }

  Future<GrafikState> _fetchAndBuild(GrafikPeriod period) async {
    try {
      final data = await _fetchGrafik(period);
      return GrafikState(
        data:   data,
        period: period,
        status: GrafikStatus.success,
      );
    } catch (e) {
      return GrafikState(
        period:       period,
        status:       GrafikStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── API Call ──────────────────────────────────────────────────────────────

  Future<GrafikData> _fetchGrafik(GrafikPeriod period) async {
    // ApiClient sudah handle token otomatis via _AuthInterceptor
    final client = ref.read(apiClientProvider);

    final response = await client.get(
      ApiEndpoints.analyticsGrafik,
      queryParams: {'period': period.apiParam},
    );

    final body = response.data as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Respons API tidak valid');
    }

    return GrafikData.fromJson(body['data'] as Map<String, dynamic>);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final grafikProvider = AsyncNotifierProvider<GrafikNotifier, GrafikState>(
  GrafikNotifier.new,
);