import 'package:flutter/material.dart';
import '../main.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool large;

  const StatusBadge({super.key, required this.status, this.large = false});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    final fontSize = large ? 13.0 : 11.0;
    final hPad = large ? 12.0 : 8.0;
    final vPad = large ? 6.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: fontSize + 2, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _statusConfig(String status) {
    switch (status) {
      case 'relatif_aman':
        return _StatusConfig(AppColors.safe, Icons.check_circle, 'Aman');
      case 'cukup_berisiko':
        return _StatusConfig(AppColors.warning, Icons.warning_rounded, 'Cukup Berisiko');
      case 'berisiko_tinggi':
        return _StatusConfig(AppColors.danger, Icons.dangerous_rounded, 'Berisiko Tinggi');
      default:
        return _StatusConfig(AppColors.unknown, Icons.help_outline, 'Tidak Diketahui');
    }
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;
  final String label;
  const _StatusConfig(this.color, this.icon, this.label);
}
