import 'package:flutter/material.dart';
import 'package:coworkingspace/services/reservation_service.dart';

class ReservationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> reservation;

  const ReservationDetailScreen({super.key, required this.reservation});

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  bool _isProcessing = false;
  late String _currentStatus;

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
    setState(() => _isProcessing = true);
    try {
      final id = widget.reservation['id'] ?? 0;
      await ReservationService().updateReservationStatus(id, newStatus);
      if (!mounted) return;
      setState(() => _currentStatus = newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diubah menjadi ${_statusLabel(newStatus)}'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ubah status: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCheckIn() async {
    setState(() => _isProcessing = true);
    try {
      final id = widget.reservation['id'] ?? 0;
      await ReservationService().checkInReservation(id);
      if (!mounted) return;
      setState(() => _currentStatus = 'aktif');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in berhasil, status: Aktif'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal check-in: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCheckOut() async {
    setState(() => _isProcessing = true);
    try {
      final id = widget.reservation['id'] ?? 0;
      await ReservationService().checkOutReservation(id);
      if (!mounted) return;
      setState(() => _currentStatus = 'selesai');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out berhasil, status: Selesai'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal check-out: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;
    final member = r['member'] ?? {};
    final space = r['space'] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text('Detail #${r['kode_booking'] ?? '-'}',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Member', member['nama_member'] ?? '-'),
            _buildInfoRow('Telp', member['telp'] ?? '-'),
            const Divider(height: 32),
            _buildInfoRow('Space', space['nama_space'] ?? '-'),
            _buildInfoRow('Tanggal', r['tanggal_reservasi'] ?? '-'),
            _buildInfoRow('Jam', '${r['jam_mulai'] ?? '-'} - ${r['jam_selesai'] ?? '-'}'),
            _buildInfoRow('Durasi', '${r['durasi_jam'] ?? '-'} Jam'),
            const Divider(height: 32),
            _buildInfoRow('Total Bayar', 'Rp ${r['total_bayar'] ?? 0}'),
            const SizedBox(height: 24),

            const Text('Ubah Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _currentStatus,
                  isExpanded: true,
                  items: _statusOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(_statusLabel(s))))
                      .toList(),
                  onChanged: _isProcessing
                      ? null
                      : (val) {
                          if (val != null) _handleUpdateStatus(val);
                        },
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_isProcessing || _currentStatus != 'disetujui') ? null : _handleCheckIn,
                    icon: const Icon(Icons.login),
                    label: const Text('Check-in'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_isProcessing || _currentStatus != 'aktif') ? null : _handleCheckOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Check-out'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}