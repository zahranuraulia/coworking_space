import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.showDot = true,
  });

  Color _getFgColor(String st) {
    switch (st.toLowerCase()) {
      case 'disetujui':
        return AppColors.emerald700;
      case 'belum_dikonfirm':
        return AppColors.amber700;
      case 'aktif':
        return AppColors.blue700;
      case 'selesai':
        return AppColors.slate700;
      case 'dibatalkan':
        return AppColors.rose700;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getBgColor(String st) {
    switch (st.toLowerCase()) {
      case 'disetujui':
        return AppColors.emerald50;
      case 'belum_dikonfirm':
        return AppColors.amber50;
      case 'aktif':
        return AppColors.blue50;
      case 'selesai':
        return AppColors.slate100;
      case 'dibatalkan':
        return AppColors.rose50;
      default:
        return AppColors.slate100;
    }
  }

  Color _getBorderColor(String st) {
    switch (st.toLowerCase()) {
      case 'disetujui':
        return AppColors.emerald200;
      case 'belum_dikonfirm':
        return AppColors.amber200;
      case 'aktif':
        return AppColors.blue200;
      case 'selesai':
        return AppColors.slate300;
      case 'dibatalkan':
        return AppColors.rose200;
      default:
        return AppColors.border;
    }
  }

  Color _getDotColor(String st) {
    switch (st.toLowerCase()) {
      case 'disetujui':
        return AppColors.emerald500;
      case 'belum_dikonfirm':
        return AppColors.amber500;
      case 'aktif':
        return AppColors.blue500;
      case 'selesai':
        return AppColors.slate500;
      case 'dibatalkan':
        return AppColors.rose500;
      default:
        return AppColors.textMuted;
    }
  }

  String _getLabel(String st) {
    switch (st.toLowerCase()) {
      case 'belum_dikonfirm':
        return 'Menunggu';
      case 'disetujui':
        return 'Disetujui';
      case 'aktif':
        return 'Aktif';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return st;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = _getFgColor(status);
    final bg = _getBgColor(status);
    final border = _getBorderColor(status);
    final dot = _getDotColor(status);
    final label = _getLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
