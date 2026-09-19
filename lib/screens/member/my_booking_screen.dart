import 'package:flutter/material.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/reservation_helper.dart';
import '../../services/reservation_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/reservation_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/stitch_app_bar.dart';
import 'e_ticket_screen.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => MyBookingScreenState();
}

class MyBookingScreenState extends State<MyBookingScreen> {
  final ReservationService _reservationService = ReservationService();

  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _reservations = [];
  String _selectedStatus = 'Semua';

  final List<String> _statusFilters = [
    'Semua',
    'Belum Dikonfirmasi',
    'Disetujui',
    'Aktif',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  void refresh() {
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _reservationService.getUserReservations();
      if (!mounted) return;
      setState(() {
        _reservations = data;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredReservations {
    if (_selectedStatus == 'Semua') return _reservations;

    return _reservations.where((r) {
      final st = (r['status'] ?? '').toString().toLowerCase();
      switch (_selectedStatus) {
        case 'Belum Dikonfirmasi':
          return st == 'belum_dikonfirm';
        case 'Disetujui':
          return st == 'disetujui';
        case 'Aktif':
          return st == 'aktif';
        case 'Selesai':
          return st == 'selesai';
        case 'Dibatalkan':
          return st == 'dibatalkan';
        default:
          return true;
      }
    }).toList();
  }

  Future<void> _confirmAndCancel(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Batalkan Reservasi?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan reservasi ini? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(100, 36),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _reservationService.cancelReservation(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservasi berhasil dibatalkan'),
            backgroundColor: AppColors.success,
          ),
        );
        _fetchReservations();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membatalkan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showBookingDetailModal(Map<String, dynamic> item) {
    int parsedId = 0;
    if (item['id'] != null) {
      if (item['id'] is int) {
        parsedId = item['id'] as int;
      } else {
        parsedId = int.tryParse(item['id'].toString()) ?? 0;
      }
    }

    final spaceName = ReservationHelper.extractSpaceName(item);
    final String status = (item['status'] ?? '').toString();
    final total = ReservationHelper.extractPrice(item);
    final code = ReservationHelper.extractBookingCode(item);
    final formattedDate = ReservationHelper.formatDate(item['tanggal_reservasi']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        spaceName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    StatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),
                _buildModalRow('Kode Booking', '#$code'),
                _buildModalRow('Tanggal', formattedDate),
                _buildModalRow('Waktu', '${item['jam_mulai'] ?? '-'} (${item['durasi_jam'] ?? 1} Jam)'),
                _buildModalRow('Total Bayar', CurrencyFormatter.formatRupiah(total)),
                const SizedBox(height: 20),

                // Tombol Lihat E-Ticket (Fungsional, tidak dead code)
                AppButton(
                  text: 'Lihat E-Tiket',
                  icon: Icons.qr_code,
                  onPressed: () {
                    Navigator.pop(modalContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ETicketScreen(reservationId: parsedId),
                      ),
                    );
                  },
                ),

                if (status == 'belum_dikonfirm') ...[
                  const SizedBox(height: 10),
                  AppButton(
                    text: 'Batalkan Reservasi',
                    variant: AppButtonVariant.outline,
                    onPressed: () {
                      Navigator.pop(modalContext);
                      _confirmAndCancel(parsedId);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: StitchAppBar(
        title: 'Status Pemesanan',
        subtitle: 'Lacak Reservasi & Jadwal Sewa',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: _fetchReservations,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Filter Chips (Stitch Design)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _statusFilters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 6),
                  itemBuilder: (context, idx) {
                    final f = _statusFilters[idx];
                    final isSel = _selectedStatus == f;
                    return InkWell(
                      onTap: () => setState(() => _selectedStatus = f),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSel ? AppColors.primary : AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSel ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Booking List
            Expanded(
              child: _isLoading
                  ? const LoadingWidget(message: 'Memuat data reservasi...')
                  : _errorMessage != null
                      ? EmptyStateWidget(
                          icon: Icons.error_outline,
                          title: 'Gagal Memuat Data',
                          message: _errorMessage!,
                          actionLabel: 'Coba Lagi',
                          onAction: _fetchReservations,
                        )
                      : _filteredReservations.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.calendar_today_outlined,
                              title: 'Tidak Ada Data Reservasi',
                              message: 'Tidak ada pemesanan space dengan status "$_selectedStatus".',
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchReservations,
                              color: AppColors.primary,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                                itemCount: _filteredReservations.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final item = _filteredReservations[index] as Map<String, dynamic>;
                                  return ReservationCard(
                                    item: item,
                                    onTap: () => _showBookingDetailModal(item),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
