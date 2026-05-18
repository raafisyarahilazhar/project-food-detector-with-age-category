class HistoryItem {
  final int id;
  final String? image;
  final String foodName;
  final double confidence;
  final String overallStatus;
  final DateTime? createdAt;

  HistoryItem({
    required this.id,
    this.image,
    required this.foodName,
    required this.confidence,
    required this.overallStatus,
    this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] ?? 0,
      image: json['image'],
      foodName: json['food_name'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      overallStatus: json['overall_status'] ?? 'data_tidak_ditemukan',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

class HistoryDetail {
  final bool success;
  final Map<String, dynamic>? data;

  HistoryDetail({required this.success, this.data});

  factory HistoryDetail.fromJson(Map<String, dynamic> json) {
    return HistoryDetail(
      success: json['success'] ?? false,
      data: json['data'],
    );
  }
}
