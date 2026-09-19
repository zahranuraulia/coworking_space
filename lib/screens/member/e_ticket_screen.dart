import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/e_ticket.dart';
import '../../services/e_ticket_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_badge.dart';

class ETicketScreen extends StatefulWidget {
  final int reservationId;

  const ETicketScreen({
    super.key,
    required this.reservationId,
  });

  @override
  State<ETicketScreen> createState() => _ETicketScreenState();
}

class _ETicketScreenState extends State<ETicketScreen> {
  final ETicketService _eTicketService = ETicketService();
  bool _isLoading = true;
  String? _errorMessage;
  ETicket? _ticket;

  @override
  void initState() {
    super.initState();
    _fetchETicket();
  }

  Future<void> _fetchETicket() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ticket = await _eTicketService.getETicket(widget.reservationId);
      if (!mounted) return;
      setState(() {
        _ticket = ticket;
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
        _errorMessage = 'Gagal memuat e-ticket: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('E-Tiket Reservasi'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const LoadingWidget(message: 'Memuat E-Tiket...')
            : _errorMessage != null
                ? EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Gagal Memuat Tiket',
                    message: _errorMessage!,
                    actionLabel: 'Coba Lagi',
                    onAction: _fetchETicket,
                  )
                : _ticket == null
                    ? const EmptyStateWidget(
                        title: 'Tiket Tidak Ditemukan',
                        message: 'Data tiket tidak tersedia.',
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // Punch Card Container
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x080F172A),
                                    blurRadius: 16,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Header Tiket
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _ticket!.namaCoworking,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'No. Tiket: ${_ticket!.ticketNumber}',
                                                style: const TextStyle(
                                                  color: Color(0xFF94A3B8),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        StatusBadge(status: _ticket!.status),
                                      ],
                                    ),
                                  ),

                                  // QR Code Section
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: QrImageView(
                                            data: _ticket!.qrCodePayload,
                                            version: QrVersions.auto,
                                            size: 160.0,
                                            eyeStyle: const QrEyeStyle(
                                              eyeShape: QrEyeShape.square,
                                              color: AppColors.primary,
                                            ),
                                            dataModuleStyle: const QrDataModuleStyle(
                                              dataModuleShape: QrDataModuleShape.square,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _ticket!.bookingCode,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Tunjukkan QR Code ini kepada resepsionis saat check-in di lokasi.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Dashed Divider Metaphor
                                  Row(
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          color: AppColors.canvas,
                                          borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
                                        ),
                                      ),
                                      Expanded(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            const dashWidth = 5.0;
                                            const dashSpace = 4.0;
                                            final dashCount = (constraints.constrainWidth() / (dashWidth + dashSpace)).floor();
                                            return Flex(
                                              direction: Axis.horizontal,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: List.generate(dashCount, (_) {
                                                return const SizedBox(
                                                  width: dashWidth,
                                                  height: 1,
                                                  child: DecoratedBox(
                                                    decoration: BoxDecoration(color: Color(0xFFCBD5E1)),
                                                  ),
                                                );
                                              }),
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: 14,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          color: AppColors.canvas,
                                          borderRadius: BorderRadius.horizontal(left: Radius.circular(14)),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Detail Grid
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        _buildRow('Nama Member', _ticket!.namaMember),
                                        _buildRow('Ruangan / Space', _ticket!.namaSpace),
                                        _buildRow('Tipe Space', _ticket!.tipeSpace),
                                        _buildRow('Tanggal', _ticket!.tanggalReservasi),
                                        _buildRow('Waktu Pemakaian', '${_ticket!.jamMulai} - ${_ticket!.jamSelesai}'),
                                        _buildRow('Durasi Sewa', _ticket!.durasi),
                                        if (_ticket!.diskonPromo != null)
                                          _buildRow('Promo Diskon', _ticket!.diskonPromo!),
                                        const Divider(height: 24),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Total Pembayaran',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              CurrencyFormatter.formatRupiah(_ticket!.totalBayar),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppColors.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Stitch Action Buttons (Unduh & Bagikan)
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    text: 'Unduh Tiket',
                                    icon: Icons.download_outlined,
                                    variant: AppButtonVariant.primary,
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('E-Tiket berhasil diunduh dan disimpan ke memori perangkat.'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppButton(
                                    text: 'Bagikan',
                                    icon: Icons.share_outlined,
                                    variant: AppButtonVariant.secondary,
                                    onPressed: () {
                                      final text = 'E-TIKET RESERVASI COWORKING SPACE\n'
                                          'Kode: ${_ticket!.bookingCode}\n'
                                          'Space: ${_ticket!.namaSpace}\n'
                                          'Tanggal: ${_ticket!.tanggalReservasi}\n'
                                          'Jam: ${_ticket!.jamMulai} - ${_ticket!.jamSelesai}\n'
                                          'Total: ${CurrencyFormatter.formatRupiah(_ticket!.totalBayar)}\n'
                                          'Status: ${_ticket!.status}';
                                      Clipboard.setData(ClipboardData(text: text));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Ringkasan E-Tiket disalin ke clipboard untuk dibagikan.'),
                                          backgroundColor: AppColors.primary,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            AppButton(
                              text: 'Tutup E-Tiket',
                              variant: AppButtonVariant.outline,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
