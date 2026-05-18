// ─── Scan Result Model ────────────────────────────────────────────────────────
class ScanResult {
  final String makanan;
  final double confidence;
  final Map<String, dynamic>? informasiGizi;
  final Map<String, dynamic>? ringkasanGizi;
  final String statusKeseluruhan;
  final Map<String, dynamic>? ringkasanAnalisis;
  final List<String> rekomendasi;
  final String kesimpulanAi;
  final List<dynamic> analisisDetail;

  ScanResult({
    required this.makanan,
    required this.confidence,
    this.informasiGizi,
    this.ringkasanGizi,
    required this.statusKeseluruhan,
    this.ringkasanAnalisis,
    required this.rekomendasi,
    required this.kesimpulanAi,
    required this.analisisDetail,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      makanan: json['makanan'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      informasiGizi: json['informasi_gizi'],
      ringkasanGizi: json['ringkasan_gizi'],
      statusKeseluruhan: json['status_keseluruhan'] ?? 'data_tidak_ditemukan',
      ringkasanAnalisis: json['ringkasan_analisis'],
      rekomendasi: List<String>.from(json['rekomendasi'] ?? []),
      kesimpulanAi: json['kesimpulan_ai'] ?? '',
      analisisDetail: json['analisis_detail'] ?? [],
    );
  }
}

// ─── Scan Response Model ──────────────────────────────────────────────────────
class ScanResponse {
  final bool success;
  final int totalDetection;
  final List<ScanResult> data;

  ScanResponse({
    required this.success,
    required this.totalDetection,
    required this.data,
  });

  factory ScanResponse.fromJson(Map<String, dynamic> json) {
    return ScanResponse(
      success: json['success'] ?? false,
      totalDetection: json['total_detection'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ScanResult.fromJson(e))
          .toList(),
    );
  }
}
