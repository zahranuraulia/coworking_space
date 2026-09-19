import 'package:flutter/material.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/reservation_helper.dart';
import '../../../services/reservation_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/stitch_app_bar.dart';

class ReservationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> reservation;

  const ReservationDetailScreen({super.key, required this.reservation});

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  final ReservationService _reservationService = ReservationService();
  bool _isProcessing = false;
  late String _currentStatus;
  late int _reservationId;

  final List<String> _statusOptions = [
    'belum_dikonfirm',
    'disetujui',
    'aktif',
    'selesai',
    'dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = (widget.reservation['status'] ?? 'belum_dikonfirm').toString();
    final rawId = widget.reservation['id'];
    _reservationId = (rawId is int) ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'belum_dikonfirm':
        return 'Belum Dikonfirmasi';
      case 'disetujui':
        return 'Disetujui';
      case 'aktif':
        return 'Aktif';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Future<void> _handleUpdateStatus(String newStatus) async {
    if (_reservationId <= 0) return;

    setState(() => _isProcessing = true);
    try {
      await _reservationService.updateReservationStatus(_reservationId, newStatus);
      if (!mounted) return;
      setState(() => _currentStatus = newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status diubah menjadi ${_statusLabel(newStatus)}'),
          backgroundColor: AppColors.success,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ubah status: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCheckIn() async {
    if (_reservationId <= 0) return;

    setState(() => _isProcessing = true);
    try {
      await _reservationService.checkInReservation(_reservationId);
      if (!mounted) return;
      setState(() => _currentStatus = 'aktif');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in member berhasil, status aktif'), backgroundColor: AppColors.success),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal check-in: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCheckOut() async {
    if (_reservationId <= 0) return;

    setState(() => _isProcessing = true);
    try {
      await _reservationService.checkOutReservation(_reservationId);
      if (!mounted) return;
      setState(() => _currentStatus = 'selesai');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out member berhasil, reservasi selesai'), backgroundColor: AppColors.success),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal check-out: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;
    final member = (r['member'] is Map<String, dynamic>) ? r['member'] as Map<String, dynamic> : {};
    final bookingCode = ReservationHelper.extractBookingCode(r);
    final memberName = member['nama_member'] ?? member['nama'] ?? r['nama_member'] ?? 'Member';
    final memberPhone = member['telp'] ?? member['telepon'] ?? '-';
    final spaceName = ReservationHelper.extractSpaceName(r);
    final spaceType = ReservationHelper.extractSpaceType(r);
    final date = ReservationHelper.formatDate(r['tanggal_reservasi']);
    final time = '${r['jam_mulai'] ?? '-'} WIB';
    final duration = '${r['durasi_jam'] ?? 1} Jam';
    final total = ReservationHelper.extractPrice(r);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const StitchAppBar(
        title: 'Detail & Operasional',
        actions: [
          Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card: Kode Reservasi + Status (Stitch Screen 4/5 Exact)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 0.9),
                  boxShadow: const [
                    BoxShadow(color: Color(0x040F172A), blurRadius: 6, offset: Offset(0, 1)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'KODE RESERVASI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '#$bookingCode',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            StatusBadge(status: _currentStatus),
                            const SizedBox(height: 4),
                            Text(
                              'Dibuat: ${(r['tanggal_reservasi'] ?? '-').toString()}',
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (_currentStatus == 'aktif') ...[
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: AppColors.borderLight),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 13, color: AppColors.blue600),
                          const SizedBox(width: 5),
                          const Text(
                            'Waktu Check-in: Sedang berlangsung di lokasi',
                            style: TextStyle(fontSize: 11, color: AppColors.blue700, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Card INFORMASI PEMESANAN (Stitch Screen 4/5 Exact)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 0.9),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INFORMASI PEMESANAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Member Row
                    _buildRowTwoCol('Member', memberName, subValue: memberPhone),
                    const Divider(height: 16, color: AppColors.borderLight),

                    // Space Row
                    _buildRowTwoCol('Ruangan', spaceName, subValue: spaceType),
                    const Divider(height: 16, color: AppColors.borderLight),

                    // Schedule Rows
                    _buildRow('Tanggal', date),
                    _buildRow('Waktu Sewa', time),
                    _buildRow('Durasi', duration),
                    const Divider(height: 16, color: AppColors.borderLight),

                    // Payment Row with Lunas tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Bayar', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.emerald50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Lunas via Bank Transfer',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.emerald700),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormatter.formatRupiah(total),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Card STATUS & SIKLUS RESERVASI Timeline (Stitch Screen 5 Exact)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 0.9),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STATUS & SIKLUS RESERVASI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildTimelineStep(
                      title: 'Pemesanan Dibuat',
                      subtitle: date,
                      isDone: true,
                    ),
                    _buildTimelineStep(
                      title: 'Disetujui Admin',
                      subtitle: _currentStatus != 'belum_dikonfirm' ? 'Disetujui pengelola' : 'Menunggu review',
                      isDone: _currentStatus == 'disetujui' || _currentStatus == 'aktif' || _currentStatus == 'selesai',
                    ),
                    _buildTimelineStep(
                      title: 'Check-in Berhasil',
                      subtitle: _currentStatus == 'aktif' ? 'Tamu aktif di ruangan' : (_currentStatus == 'selesai' ? 'Selesai digunakan' : 'Menunggu tamu'),
                      isDone: _currentStatus == 'aktif' || _currentStatus == 'selesai',
                      tag: _currentStatus == 'aktif' ? 'SAAT INI AKTIF' : null,
                    ),
                    _buildTimelineStep(
                      title: 'Check-out / Selesai',
                      subtitle: _currentStatus == 'selesai' ? 'Reservasi selesai' : 'Estimasi selesai $time',
                      isDone: _currentStatus == 'selesai',
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Orange Warning Callout Box for Active Reservation (Stitch Screen 5 Exact)
              if (_currentStatus == 'aktif') ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reservasi sedang berlangsung di lokasi. Tekan Proses Check-out saat tamu telah selesai menggunakan space.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Manual Status Override Dropdown (Collapsible)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  children: [
                    const Text('Ubah Status: ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _currentStatus,
                          isExpanded: true,
                          items: _statusOptions
                              .map((s) => DropdownMenuItem(value: s, child: Text(_statusLabel(s), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))))
                              .toList(),
                          onChanged: _isProcessing
                              ? null
                              : (val) {
                                  if (val != null && val != _currentStatus) _handleUpdateStatus(val);
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Operational Primary Action Button (Stitch Screen 4 & 5 Exact)
              if (_currentStatus == 'disetujui') ...[
                AppButton(
                  text: 'PROSES CHECK-IN',
                  icon: Icons.login,
                  isLoading: _isProcessing,
                  onPressed: _handleCheckIn,
                ),
                const SizedBox(height: 8),
              ] else if (_currentStatus == 'aktif') ...[
                AppButton(
                  text: 'PROSES CHECK-OUT',
                  icon: Icons.logout,
                  isLoading: _isProcessing,
                  onPressed: _handleCheckOut,
                ),
                const SizedBox(height: 8),
              ] else if (_currentStatus == 'belum_dikonfirm') ...[
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Tolak',
                        variant: AppButtonVariant.outline,
                        onPressed: _isProcessing ? null : () => _handleUpdateStatus('dibatalkan'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        text: 'Setujui',
                        variant: AppButtonVariant.primary,
                        onPressed: _isProcessing ? null : () => _handleUpdateStatus('disetujui'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Batalkan Reservasi Outline Button (Stitch Screen 5)
              if (_currentStatus != 'selesai' && _currentStatus != 'dibatalkan')
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rose600,
                    side: const BorderSide(color: AppColors.rose200),
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Batalkan Reservasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  onPressed: _isProcessing ? null : () => _handleUpdateStatus('dibatalkan'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildRowTwoCol(String label, String mainValue, {String? subValue}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(mainValue, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            if (subValue != null)
              Text(subValue, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isDone,
    bool isLast = false,
    String? tag,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isDone ? (tag != null ? AppColors.blue600 : AppColors.emerald500) : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: isDone ? const Color(0xFFD1FAE5) : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: isDone ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                  if (tag != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.blue50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.blue700),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ],
    );
  }
}
