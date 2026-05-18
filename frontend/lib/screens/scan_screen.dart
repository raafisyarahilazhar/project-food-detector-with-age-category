import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../models/scan_result.dart';
import '../services/api_service.dart';
import '../widgets/status_badge.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  ScanResponse? _result;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _selectedImage = File(picked.path);
      _result = null;
      _error = null;
    });

    await _doScan();
  }

  Future<void> _doScan() async {
    if (_selectedImage == null) return;
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.scanFood(_selectedImage!);
      setState(() {
        _result = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _selectedImage = null;
      _result = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan Makanan'),
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _reset,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: _selectedImage == null ? _buildPickerView() : _buildResultView(),
    );
  }

  // ── Empty state / picker ──────────────────────────────────────────────────
  Widget _buildPickerView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Illustration area
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.15),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_rounded,
                    size: 72, color: AppColors.primary.withOpacity(0.3)),
                const SizedBox(height: 16),
                const Text(
                  'Foto makanan untuk dianalisis',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Pilih sumber gambar',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _PickerButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PickerButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Sistem akan mendeteksi jenis makanan dan\nmenganalisis kandungan gizi secara otomatis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted.withOpacity(0.8),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Result view ───────────────────────────────────────────────────────────
  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              _selectedImage!,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),

          if (_isLoading) _buildLoading(),
          if (_error != null) _buildError(),
          if (_result != null) _buildResults(),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Menganalisis makanan...',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error ?? 'Terjadi kesalahan',
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final results = _result!.data;

    if (results.isEmpty) {
      return _buildEmptyDetection();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${results.length} makanan terdeteksi',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        ...results.map((r) => _FoodResultCard(result: r)),
      ],
    );
  }

  Widget _buildEmptyDetection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text(
            'Tidak ada makanan yang terdeteksi',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Coba ambil foto yang lebih jelas atau dari sudut yang berbeda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Picker Button ────────────────────────────────────────────────────────────
class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Food Result Card ─────────────────────────────────────────────────────────
class _FoodResultCard extends StatefulWidget {
  final ScanResult result;
  const _FoodResultCard({required this.result});

  @override
  State<_FoodResultCard> createState() => _FoodResultCardState();
}

class _FoodResultCardState extends State<_FoodResultCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.result;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _capitalize(r.makanan),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    StatusBadge(status: r.statusKeseluruhan, large: true),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Akurasi: ${(r.confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),

          // AI Conclusion
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.kesimpulanAi,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Nutrition info (if available)
          if (r.informasiGizi != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _NutritionRow(nutrition: r.informasiGizi!),
            ),
            const SizedBox(height: 12),
          ],

          // Recommendations
          if (r.rekomendasi.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rekomendasi',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...r.rekomendasi.map(
                    (rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_right_rounded,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(rec,
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textDark)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Detail toggle
          if (r.analisisDetail.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Text(
                      _expanded ? 'Sembunyikan detail' : 'Lihat analisis detail',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(height: 18),

          if (_expanded) _DetailList(details: r.analisisDetail),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── Nutrition Row ─────────────────────────────────────────────────────────────
class _NutritionRow extends StatelessWidget {
  final Map<String, dynamic> nutrition;
  const _NutritionRow({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Kalori', '${nutrition['kalori'] ?? '-'} kkal', Icons.local_fire_department_rounded),
      ('Protein', '${nutrition['protein'] ?? '-'} g', Icons.egg_alt_rounded),
      ('Lemak', '${nutrition['lemak'] ?? '-'} g', Icons.opacity_rounded),
      ('Karbo', '${nutrition['karbohidrat'] ?? '-'} g', Icons.grain_rounded),
    ];

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(item.$3, size: 16, color: AppColors.primary),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      item.$1,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Detail List ──────────────────────────────────────────────────────────────
class _DetailList extends StatelessWidget {
  final List<dynamic> details;
  const _DetailList({required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: details.take(10).map<Widget>((d) {
          final status = d['status'] ?? '';
          final isLayak = status == 'layak';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  isLayak ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: isLayak ? AppColors.safe : AppColors.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${d['kategori'] ?? ''} · ${d['kelompok_umur'] ?? ''} (${d['jenis_kelamin'] ?? ''})',
                    style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
