import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/reservation_helper.dart';
import 'status_badge.dart';

class ReservationCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const ReservationCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spaceName = ReservationHelper.extractSpaceName(item);
    final status = (item['status'] ?? 'belum_dikonfirm').toString();
    final jamMulai = item['jam_mulai'] ?? '-';
    final durasi = item['durasi_jam'] ?? 1;
    final total = ReservationHelper.extractPrice(item);
    final code = ReservationHelper.extractBookingCode(item);
    final formattedDate = ReservationHelper.formatDate(item['tanggal_reservasi']);

    Color dotColor = AppColors.amber500;
    if (status == 'disetujui') dotColor = AppColors.emerald500;
    if (status == 'aktif') dotColor = AppColors.blue500;
    if (status == 'dibatalkan') dotColor = AppColors.rose500;
    if (status == 'selesai') dotColor = AppColors.slate500;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: status == 'aktif' ? AppColors.blue200 : AppColors.border,
            width: status == 'aktif' ? 1.2 : 0.9,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x040F172A),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '#$code',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              spaceName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '$jamMulai ($durasi Jam)',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Tagihan',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatRupiah(total),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
