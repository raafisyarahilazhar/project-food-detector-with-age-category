import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/scan_result.dart';
import '../models/history_item.dart';
import '../models/dashboard_data.dart';

class ApiService {
  // ── GANTI dengan IP/base URL backend kamu ──────────────────────────────────
  // static const String baseUrl = 'http://127.0.0.1:8000';
  static const String baseUrl = 'http://10.109.82.41:8000';
  // Untuk Android emulator gunakan 10.0.2.2
  // Untuk device fisik gunakan IP komputer di jaringan yang sama, misal 192.168.x.x:8000
  // ──────────────────────────────────────────────────────────────────────────

  // POST /scan
  static Future<ScanResponse> scanFood(File imageFile) async {
    final uri = Uri.parse('$baseUrl/scan');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return ScanResponse.fromJson(json);
    } else {
      throw Exception('Gagal melakukan scan: ${response.statusCode}');
    }
  }

  // GET /dashboard
  static Future<DashboardData> getDashboard() async {
    final response = await http
        .get(Uri.parse('$baseUrl/dashboard'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return DashboardData.fromJson(json);
    } else {
      throw Exception('Gagal memuat dashboard');
    }
  }

  // GET /history
  static Future<List<HistoryItem>> getHistory() async {
    final response = await http
        .get(Uri.parse('$baseUrl/history'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> data = json['data'] ?? [];
      return data.map((e) => HistoryItem.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat riwayat');
    }
  }

  // GET /history/{id}
  static Future<Map<String, dynamic>> getHistoryDetail(int id) async {
    final response = await http
        .get(Uri.parse('$baseUrl/history/$id'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return json['data'] ?? {};
    } else {
      throw Exception('Gagal memuat detail riwayat');
    }
  }
}
