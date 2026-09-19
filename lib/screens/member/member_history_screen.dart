import 'package:flutter/material.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/reservation_helper.dart';
import '../../services/reservation_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/stitch_app_bar.dart';
import 'e_ticket_screen.dart';

class MemberHistoryScreen extends StatefulWidget {
  const MemberHistoryScreen({super.key});

  @override
  State<MemberHistoryScreen> createState() => MemberHistoryScreenState();
}

class MemberHistoryScreenState extends State<MemberHistoryScreen> {
  final ReservationService _reservationService = ReservationService();

  int _selectedMonth = DateTime.now().month;
  final int _selectedYear = DateTime.now().year;

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _historyData = {};

  final List<Map<String, dynamic>> _months = const [
    {'value': 0, 'label': 'Semua Bulan'},
    {'value': 1, 'label': 'Januari'},
    {'value': 2, 'label': 'Februari'},
    {'value': 3, 'label': 'Maret'},
    {'value': 4, 'label': 'April'},
    {'value': 5, 'label': 'Mei'},
    {'value': 6, 'label': 'Juni'},
    {'value': 7, 'label': 'Juli'},
    {'value': 8, 'label': 'Agustus'},
    {'value': 9, 'label': 'September'},
    {'value': 10, 'label': 'Oktober'},
    {'value': 11, 'label': 'November'},
    {'value': 12, 'label': 'Desember'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void refresh() {
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _reservationService.getReservationHistory(
        month: _selectedMonth == 0 ? null : _selectedMonth,
        year: _selectedYear,
      );
      if (!mounted) return;
      setState(() {
        _historyData = res;
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

  List<dynamic> _extractItems() {
    if (_historyData['data'] is List) {
      return _historyData['data'] as List<dynamic>;
    }
    if (_historyData['items'] is List) {
      return _historyData['items'] as List<dynamic>;
    }
    return [];
  }

  double _extractTotalSpent(List<dynamic> items) {
    if (_historyData['total_pengeluaran'] != null) {
      final raw = _historyData['total_pengeluaran'];
      if (raw is num) return raw.toDouble();
      return double.tryParse(raw.toString()) ?? 0.0;
    }
    double sum = 0.0;
    for (final it in items) {
      if (it is Map<String, dynamic>) {
        sum += ReservationHelper.extractPrice(it);
      }
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final items = _extractItems();
    final totalCount = _historyData['total_reservasi'] ?? items.length;
    final totalSpent = _extractTotalSpent(items);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const StitchAppBar(
        title: 'Histori Pemesanan',
        subtitle: 'Catatan Sewa & Pengeluaran',
        showBackButton: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchHistory,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Selector Bar (Stitch Design)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Riwayat Transaksi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Catatan sewa dan pengeluaran Anda',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedMonth,
                          items: _months.map((m) {
                            return DropdownMenuItem<int>(
                              value: m['value'] as int,
                              child: Text(
                                m['value'] == 0 ? 'Semua Bulan' : '${m['label']} $_selectedYear',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                          onChanged: (newMonth) {
                            if (newMonth != null && newMonth != _selectedMonth) {
                              setState(() => _selectedMonth = newMonth);
                              _fetchHistory();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2 Metric Summary Cards (Stitch Design)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 0.9),
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
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.blue50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.bookmark_border, color: AppColors.blue600, size: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$totalCount',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Total Reservasi',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 0.9),
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
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.emerald700, size: 18),
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyFormatter.formatRupiah(totalSpent),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Total Pengeluaran',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Section Title
                const Text(
                  'Daftar Transaksi Bulanan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: LoadingWidget(message: 'Memuat riwayat reservasi...'),
                  )
                else if (_errorMessage != null)
                  EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Gagal Memuat Riwayat',
                    message: _errorMessage!,
                    actionLabel: 'Coba Lagi',
                    onAction: _fetchHistory,
                  )
                else if (items.isEmpty)
                  const EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: 'Belum Ada Transaksi',
                    message: 'Tidak ada riwayat pemesanan pada periode ini.',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index] as Map<String, dynamic>;
                      return _buildHistoryCard(item);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final status = (item['status'] ?? '').toString();
    final rawId = item['id'];
    final id = (rawId is int) ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;
    final spaceName = ReservationHelper.extractSpaceName(item);
    final total = ReservationHelper.extractPrice(item);
    final code = ReservationHelper.extractBookingCode(item);
    final formattedDate = ReservationHelper.formatDate(item['tanggal_reservasi']);
    final time = '${item['jam_mulai'] ?? '-'} - ${item['jam_selesai'] ?? '-'}';
    final duration = '${item['durasi_jam'] ?? 1} Jam';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.9),
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
              Text(
                '#$code',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.accentBlue,
                ),
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
          ),
          const SizedBox(height: 3),

          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '$formattedDate • $time ($duration)',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Bayar',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                CurrencyFormatter.formatRupiah(total),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),

          if (id > 0 && (status == 'disetujui' || status == 'aktif' || status == 'selesai')) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(90, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                icon: const Icon(Icons.qr_code, size: 14),
                label: const Text('Lihat E-Tiket', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ETicketScreen(reservationId: id),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
