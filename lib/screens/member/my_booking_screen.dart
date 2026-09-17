import 'package:flutter/material.dart';
import 'package:coworkingspace/services/reservation_service.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _reservations = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final data = await ReservationService().getUserReservations();
      setState(() {
        _reservations = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Status ASLI dari API: belum_dikonfirm, disetujui, aktif, selesai, dibatalkan
  List<dynamic> _filterReservations(String tab) {
    if (tab == 'active') {
      return _reservations.where((r) {
        final st = (r['status'] ?? '').toString();
        return st == 'belum_dikonfirm' || st == 'disetujui' || st == 'aktif';
      }).toList();
    } else if (tab == 'completed') {
      return _reservations.where((r) => (r['status'] ?? '') == 'selesai').toList();
    } else {
      return _reservations.where((r) => (r['status'] ?? '') == 'dibatalkan').toList();
    }
  }

  String _formatRupiah(dynamic amount) {
    final number = int.tryParse(amount.toString().replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'disetujui':
        return Colors.green;
      case 'belum_dikonfirm':
        return Colors.orange;
      case 'aktif':
        return Colors.blue;
      case 'selesai':
        return Colors.teal;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'belum_dikonfirm':
        return 'BELUM DIKONFIRMASI';
      case 'disetujui':
        return 'DISETUJUI';
      case 'aktif':
        return 'AKTIF';
      case 'selesai':
        return 'SELESAI';
      case 'dibatalkan':
        return 'DIBATALKAN';
      default:
        return status.toUpperCase();
    }
  }

  Future<void> _handleCancel(int id) async {
    try {
      await ReservationService().cancelReservation(id);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservasi berhasil dibatalkan'), backgroundColor: Colors.green),
      );
      _fetchReservations();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membatalkan: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _showBookingDetailModal(Map<String, dynamic> item) {
    final int reservationId = item['id'] ?? 0;
    final String status = (item['status'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['space']?['nama_space'] ?? 'Detail Reservasi',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text('Kode Booking: ${item['kode_booking'] ?? '-'}'),
              Text('Tanggal: ${item['tanggal_reservasi'] ?? '-'}'),
              Text('Jam: ${item['jam_mulai'] ?? '-'} - ${item['jam_selesai'] ?? '-'}'),
              Text('Total Bayar: Rp ${_formatRupiah(item['total_bayar'] ?? 0)}'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: navigasi ke halaman E-Ticket, panggil
                    // ReservationService().getETicket(reservationId)
                  },
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Lihat E-Ticket'),
                ),
              ),
              if (status == 'belum_dikonfirm') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleCancel(reservationId),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text('Batalkan Reservasi', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Reservasi Saya',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF2563EB),
          tabs: const [Tab(text: 'Aktif'), Tab(text: 'Selesai'), Tab(text: 'Batal')],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(_filterReservations('active')),
                    _buildBookingList(_filterReservations('completed')),
                    _buildBookingList(_filterReservations('cancelled')),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text('Gagal memuat data\n$_errorMessage', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchReservations, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(List<dynamic> list) {
    if (list.isEmpty) {
      return const Center(child: Text('Tidak ada data reservasi'));
    }
    return RefreshIndicator(
      onRefresh: _fetchReservations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          final space = item['space'] ?? {};
          final status = (item['status'] ?? '').toString();
          final statusColor = _getStatusColor(status);

          return InkWell(
            onTap: () => _showBookingDetailModal(item),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(space['nama_space'] ?? 'Space',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_statusLabel(status),
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text('Tanggal: ${item['tanggal_reservasi'] ?? '-'}'),
                  const SizedBox(height: 4),
                  Text('Jam: ${item['jam_mulai'] ?? '-'} (${item['durasi_jam'] ?? 1} Jam)'),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Bayar', style: TextStyle(color: Color(0xFF64748B))),
                      Text('Rp ${_formatRupiah(item['total_bayar'] ?? 0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF97316))),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}