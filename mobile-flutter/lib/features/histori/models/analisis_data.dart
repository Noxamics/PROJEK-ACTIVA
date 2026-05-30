import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../hasil_prediksi/models/ml_result_model.dart';

class AnalisisData {
  final int number;
  final String day;
  final String month;
  final int dep;
  final String category;
  final double confidence;
  final String? note;
  final Color? noteColor;
  final MlResultModel originalResult;

  const AnalisisData({
    required this.number,
    required this.day,
    required this.month,
    required this.dep,
    required this.category,
    required this.confidence,
    this.note,
    this.noteColor,
    required this.originalResult,
  });

  // ── Getters untuk histori_screen.dart ─────────────────────────
  String get kategori => category;
  String get title => 'Analisis #$number';
  double get score => digitalDependenceScore;
  String get relativeTime => '$day $month';

  // score alias — pakai dep karena itu digitalDependenceScore.round()
  double get digitalDependenceScore => dep.toDouble();

  String get statusWellness => switch (category.toLowerCase()) {
    'rendah' => 'Hidup Sehat',
    'sedang' => 'Mulai Stabil',
    'tinggi' => 'Perlu Perhatian',
    _ => 'Dalam Pemantauan',
  };
}

extension AnalisisDataConverter on AnalisisData {
  static AnalisisData fromMlResult(MlResultModel ml) {
    return AnalisisData(
      number: ml.dependenceInt, // digitalDependenceScore.round()
      day: ml.dayStr, // '23'
      month: ml.monthStr, // 'MEI'
      dep: ml.dependenceInt,
      category: ml.category, // 'rendah' | 'sedang' | 'tinggi'
      confidence: ml.confidence.confidenceFinalPct, // 0–100
      note: ml.riskLevel, // 'Hidup Sehat' | 'Perlu Perhatian' | 'Risiko Tinggi'
      noteColor: ml.category.toLowerCase() == 'tinggi'
          ? AppColors.red
          : AppColors.teal,
      originalResult: ml,
    );
  }
}
