class DashboardData {
  final int totalScan;
  final int makananAman;
  final int makananBerisiko;
  final int makananTidakDiketahui;

  DashboardData({
    required this.totalScan,
    required this.makananAman,
    required this.makananBerisiko,
    required this.makananTidakDiketahui,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final d = json['data'] ?? json;
    return DashboardData(
      totalScan: d['total_scan'] ?? 0,
      makananAman: d['makanan_aman'] ?? 0,
      makananBerisiko: d['makanan_berisiko'] ?? 0,
      makananTidakDiketahui: d['makanan_tidak_diketahui'] ?? 0,
    );
  }
}
