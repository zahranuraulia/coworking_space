import 'package:flutter/material.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/reservation_helper.dart';
import '../../../services/reservation_service.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/stitch_app_bar.dart';
import 'reservation_detail_screen.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() => _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  final ReservationService _reservationService = ReservationService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _reservations = [];
  String _selectedStatus = 'Semua';
  int _selectedMonth = DateTime.now().month;
  final int _selectedYear = DateTime.now().year;

  final List<String> _statusFilters = [
    'Semua',
    'Menunggu',
    'Disetujui',
    'Aktif',
    'Batal',
  ];

  final List<Map<String, dynamic>> _months = const [
    {'value': 1, 'label': 'Jan'},
    {'value': 2, 'label': 'Feb'},
    {'value': 3, 'label': 'Mar'},
    {'value': 4, 'label': 'Apr'},
    {'value': 5, 'label': 'Mei'},
    {'value': 6, 'label': 'Jun'},
    {'value': 7, 'label': 'Jul'},
    {'value': 8, 'label': 'Agu'},
    {'value': 9, 'label': 'Sep'},
    {'value': 10, 'label': 'Okt'},
    {'value': 11, 'label': 'Nov'},
    {'value': 12, 'label': 'Des'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _reservationService.getAdminReservations(
        month: _selectedMonth,
        year: _selectedYear,
      );
      if (!mounted) return;
      setState(() {
        _reservations = list;
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

  int _countByStatus(String statusKey) {
    if (statusKey == 'Semua') return _reservations.length;
    return _reservations.where((r) {
      final st = (r['status'] ?? '').toString().toLowerCase();
      if (statusKey == 'Menunggu') return st == 'belum_dikonfirm';
      if (statusKey == 'Disetujui') return st == 'disetujui';
      if (statusKey == 'Aktif') return st == 'aktif';
      if (statusKey == 'Batal') return st == 'dibatalkan';
      return false;
    }).length;
  }

  List<dynamic> get _filteredReservations {
    final query = _searchController.text.trim().toLowerCase();

    return _reservations.where((r) {
      final map = r as Map<String, dynamic>;
      final status = (map['status'] ?? '').toString().toLowerCase();

      if (_selectedStatus == 'Menunggu' && status != 'belum_dikonfirm') return false;
      if (_selectedStatus == 'Disetujui' && status != 'disetujui') return false;
      if (_selectedStatus == 'Aktif' && status != 'aktif') return false;
      if (_selectedStatus == 'Batal' && status != 'dibatalkan') return false;

      if (query.isNotEmpty) {
        final code = (map['kode_booking'] ?? '').toString().toLowerCase();
        final member = (map['member'] is Map ? map['member']['nama_member'] : map['nama_member'] ?? '').toString().toLowerCase();
        final space = (map['space'] is Map ? map['space']['nama_space'] : map['space_name'] ?? '').toString().toLowerCase();
        if (!code.contains(query) && !member.contains(query) && !space.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _quickUpdateStatus(int id, String newStatus) async {
    try {
      await _reservationService.updateReservationStatus(id, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status pemesanan berhasil diubah ke $newStatus'),
          backgroundColor: AppColors.success,
        ),
      );
      _fetchReservations();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ubah status: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _countByStatus('Menunggu');
    final todayCount = _reservations.length;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: StitchAppBar(
        title: 'Data Reservasi',
        subtitle: 'Panel Pengelola Space',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: _fetchReservations,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchReservations,
          color: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Selector & Search Row (Stitch Screen 3 Exact)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    // Month Picker Dropdown Pill
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedMonth,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.textMuted),
                          items: _months.map((m) {
                            return DropdownMenuItem<int>(
                              value: m['value'] as int,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${m['label']} $_selectedYear',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedMonth = val);
                              _fetchReservations();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Search Box
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Cari reservasi...',
                            hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textMuted),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 14),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Tabs with Counts (Stitch Screen 3 Exact: Semua (24), Menunggu (4), etc.)
              SizedBox(
                height: 34,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _statusFilters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 6),
                  itemBuilder: (context, idx) {
                    final f = _statusFilters[idx];
                    final isSel = _selectedStatus == f;
                    final count = _countByStatus(f);

                    return InkWell(
                      onTap: () => setState(() => _selectedStatus = f),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSel ? AppColors.primary : AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '$f ($count)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Quick Summary Metric Bar (Stitch Screen 3: 2 Column Cards)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 0.8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x040F172A), blurRadius: 4, offset: Offset(0, 1)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Reservasi Hari Ini', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 2),
                                Text('$todayCount Jadwal', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
                              ],
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.blue50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.schedule, size: 16, color: AppColors.blue600),
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
                          border: Border.all(color: AppColors.border, width: 0.8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x040F172A), blurRadius: 4, offset: Offset(0, 1)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Perlu Konfirmasi', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 2),
                                Text('$pendingCount Antrean', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.amber700)),
                              ],
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.amber50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.amber700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Reservations List
              Expanded(
                child: _isLoading
                    ? const LoadingWidget(message: 'Memuat data reservasi...')
                    : _errorMessage != null
                        ? EmptyStateWidget(
                            icon: Icons.error_outline,
                            title: 'Gagal Memuat Reservasi',
                            message: _errorMessage!,
                            actionLabel: 'Coba Lagi',
                            onAction: _fetchReservations,
                          )
                        : _filteredReservations.isEmpty
                            ? const EmptyStateWidget(
                                icon: Icons.calendar_today_outlined,
                                title: 'Tidak Ada Reservasi',
                                message: 'Tidak ditemukan jadwal reservasi pada filter ini.',
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                                itemCount: _filteredReservations.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final item = _filteredReservations[index] as Map<String, dynamic>;
                                  return _buildReservationCard(item);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> item) {
    final status = (item['status'] ?? 'belum_dikonfirm').toString();
    final rawId = item['id'];
    final id = (rawId is int) ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;
    final member = (item['member'] is Map) ? item['member'] as Map<String, dynamic> : {};

    final memberName = member['nama_member'] ?? member['nama'] ?? item['nama_member'] ?? 'Member';
    final spaceName = ReservationHelper.extractSpaceName(item);
    final date = ReservationHelper.formatDate(item['tanggal_reservasi']);
    final time = '${item['jam_mulai'] ?? '-'} WIB';
    final total = ReservationHelper.extractPrice(item);
    final code = ReservationHelper.extractBookingCode(item);
    final duration = '${item['durasi_jam'] ?? 1} Jam';

    // Dot color matching status
    Color dotColor = AppColors.amber500;
    if (status == 'disetujui') dotColor = AppColors.emerald500;
    if (status == 'aktif') dotColor = AppColors.blue500;
    if (status == 'dibatalkan') dotColor = AppColors.rose500;
    if (status == 'selesai') dotColor = AppColors.slate500;

    return Container(
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
          // Top Row: Dot + Code + Status Badge (Stitch Screen 3 Exact)
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
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 8),

          // Center Row: Member Name, Space Type, Date & Price (Stitch Screen 3 Exact)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            memberName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('· $spaceName', style: const TextStyle(fontSize: 11, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '$date · $time',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatRupiah(total),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  const Text('Lunas', style: TextStyle(fontSize: 10, color: AppColors.emerald700, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 8),

          // Bottom Row: Duration & Kelola Detail Button (Stitch Exact)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('Durasi: $duration', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),

              if (status == 'belum_dikonfirm') ...[
                Row(
                  children: [
                    InkWell(
                      onTap: () => _quickUpdateStatus(id, 'disetujui'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.emerald500,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Setujui', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _quickUpdateStatus(id, 'dibatalkan'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.rose50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.rose200),
                        ),
                        child: const Text('Tolak', style: TextStyle(color: AppColors.rose600, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Black Kelola Detail Button with chevron (Stitch Screen 3 Exact)
                InkWell(
                  onTap: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservationDetailScreen(reservation: item),
                      ),
                    );
                    if (updated == true) _fetchReservations();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Kelola Detail', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        SizedBox(width: 3),
                        Icon(Icons.chevron_right, size: 13, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
