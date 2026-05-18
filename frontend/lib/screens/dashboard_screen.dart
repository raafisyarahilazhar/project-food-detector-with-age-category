import 'package:flutter/material.dart';
import '../main.dart';
import '../models/dashboard_data.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardData? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getDashboard();
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
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (_data == null) return const SizedBox();

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A6E), Color(0xFF2D5AA8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Datang 👋',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'MBG Food Scanner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.camera_alt_rounded,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${_data!.totalScan} total scan dilakukan',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Statistik Scan',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 14),

            // Stats grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.55,
              children: [
                _StatCard(
                  label: 'Total Scan',
                  value: _data!.totalScan,
                  icon: Icons.camera_alt_rounded,
                  color: AppColors.primary,
                ),
                _StatCard(
                  label: 'Makanan Aman',
                  value: _data!.makananAman,
                  icon: Icons.check_circle_rounded,
                  color: AppColors.safe,
                ),
                _StatCard(
                  label: 'Makanan Berisiko',
                  value: _data!.makananBerisiko,
                  icon: Icons.warning_rounded,
                  color: AppColors.danger,
                ),
                _StatCard(
                  label: 'Tidak Diketahui',
                  value: _data!.makananTidakDiketahui,
                  icon: Icons.help_outline_rounded,
                  color: AppColors.unknown,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Safety overview
            _OverviewBar(data: _data!),
            const SizedBox(height: 32),

            // Info card
            Container(
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Data berdasarkan Angka Kecukupan Gizi (AKG) yang diterbitkan oleh Kementerian Kesehatan RI.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Overview Bar ─────────────────────────────────────────────────────────────
class _OverviewBar extends StatelessWidget {
  final DashboardData data;
  const _OverviewBar({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.totalScan == 0 ? 1 : data.totalScan;
    final safeRatio = data.makananAman / total;
    final riskRatio = data.makananBerisiko / total;
    final unknownRatio = data.makananTidakDiketahui / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          const Text(
            'Proporsi Keamanan Makanan',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          // Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                if (safeRatio > 0)
                  Expanded(
                    flex: (safeRatio * 100).round(),
                    child: Container(height: 14, color: AppColors.safe),
                  ),
                if (riskRatio > 0)
                  Expanded(
                    flex: (riskRatio * 100).round(),
                    child: Container(height: 14, color: AppColors.danger),
                  ),
                if (unknownRatio > 0)
                  Expanded(
                    flex: (unknownRatio * 100).round(),
                    child: Container(height: 14, color: AppColors.unknown),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Legend
          Row(
            children: [
              _Legend(color: AppColors.safe, label: 'Aman'),
              const SizedBox(width: 16),
              _Legend(color: AppColors.danger, label: 'Berisiko'),
              const SizedBox(width: 16),
              _Legend(color: AppColors.unknown, label: 'Tidak diketahui'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}
