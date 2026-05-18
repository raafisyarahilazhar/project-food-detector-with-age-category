import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../widgets/status_badge.dart';

class HistoryDetailScreen extends StatefulWidget {
  final int historyId;

  const HistoryDetailScreen({super.key, required this.historyId});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getHistoryDetail(widget.historyId);
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Scan')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
      );
    }

    if (_data == null) return const SizedBox();

    final d = _data!;
    final makanan = d['makanan'] ?? '';
    final status = d['status_keseluruhan'] ?? '';
    final kesimpulan = d['kesimpulan_ai'] ?? '';
    final rekomendasi = List<String>.from(d['rekomendasi'] ?? []);
    final gizi = d['informasi_gizi'];
    final ringkasan = d['ringkasan_analisis'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food name + status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalize(makanan),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                StatusBadge(status: status, large: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Ringkasan analisis
          if (ringkasan != null)
            _InfoCard(
              title: 'Ringkasan Analisis',
              child: Row(
                children: [
                  _CountChip(
                    label: 'Layak',
                    value: ringkasan['jumlah_layak'] ?? 0,
                    color: AppColors.safe,
                  ),
                  const SizedBox(width: 12),
                  _CountChip(
                    label: 'Tidak Layak',
                    value: ringkasan['jumlah_tidak_layak'] ?? 0,
                    color: AppColors.danger,
                  ),
                ],
              ),
            ),

          // Informasi gizi
          if (gizi != null)
            _InfoCard(
              title: 'Informasi Gizi',
              child: Column(
                children: [
                  _NutriRow('Kalori', '${gizi['kalori'] ?? '-'} kkal'),
                  _NutriRow('Protein', '${gizi['protein'] ?? '-'} g'),
                  _NutriRow('Lemak', '${gizi['lemak'] ?? '-'} g'),
                  _NutriRow('Karbohidrat', '${gizi['karbohidrat'] ?? '-'} g'),
                  _NutriRow('Gula', '${gizi['gula'] ?? '-'} g'),
                  _NutriRow('Natrium', '${gizi['natrium'] ?? '-'} mg'),
                  _NutriRow('Serat', '${gizi['serat'] ?? '-'} g'),
                  _NutriRow('Kalsium', '${gizi['kalsium'] ?? '-'} mg',
                      last: true),
                ],
              ),
            ),

          // Kesimpulan AI
          _InfoCard(
            title: 'Kesimpulan AI',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    kesimpulan,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                        height: 1.6),
                  ),
                ),
              ],
            ),
          ),

          // Rekomendasi
          if (rekomendasi.isNotEmpty)
            _InfoCard(
              title: 'Rekomendasi',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rekomendasi
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_right_rounded,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(r,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textDark)),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _NutriRow extends StatelessWidget {
  final String label;
  final String value;
  final bool last;

  const _NutriRow(this.label, this.value, {this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF0F0F0)),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _CountChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color),
          ),
          Text(label,
              style:
                  TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
