import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/reservation_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/reservation_card.dart';
import '../../widgets/stitch_app_bar.dart';
import 'profile/admin_profile_screen.dart';
import 'reports/admin_revenue_report_screen.dart';
import 'reservations/reservation_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthService _authService = AuthService();
  final ReservationService _reservationService = ReservationService();

  bool _isLoading = true;
  bool _isGlobalSeed = false;
  String? _errorMessage;
  List<dynamic> _reservations = [];

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = await _authService.checkSession();
      final list = await _reservationService.getAdminReservations();
      if (!mounted) return;
      setState(() {
        _isGlobalSeed = session['is_global_seed'] == true;
        _reservations = list;
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

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text(
          'Keluar dari panel pengelola coworking space?',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(90, 36),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalBooking = _reservations.length;
    final int pendingBooking = _reservations
        .where((r) => (r['status'] ?? '').toString() == 'belum_dikonfirm')
        .length;
    final int activeBooking = _reservations
        .where((r) => (r['status'] ?? '').toString() == 'aktif')
        .length;
    final int completedBooking = _reservations
        .where((r) => (r['status'] ?? '').toString() == 'selesai')
        .length;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: StitchAppBar(
        title: 'Dashboard Pengelola',
        subtitle: 'Panel NexusSpace Management',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined, size: 20),
            tooltip: 'Laporan Pendapatan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminRevenueReportScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.business_outlined, size: 20),
            tooltip: 'Profil Lokasi Space',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Keluar Akun',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchAdminData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isGlobalSeed)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: Color(0xFFD97706)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Mode Akun Template Panitia',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Anda login dengan akun global (admin_space1). Data space dan transaksi tenant App Maker Anda terpisah dari akun ini. Untuk mengelola space Anda sendiri, masuk dengan akun admin tenant Anda.',
                                style: TextStyle(fontSize: 11, color: Color(0xFFB45309), height: 1.35),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const Text(
                  'Ringkasan Reservasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                // Stat Cards Matrix (Stitch 16dp rounded)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Booking',
                        '$totalBooking',
                        Icons.bookmark_outline,
                        AppColors.accentBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        'Menunggu',
                        '$pendingBooking',
                        Icons.hourglass_empty,
                        AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Sedang Aktif',
                        '$activeBooking',
                        Icons.meeting_room_outlined,
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        'Selesai',
                        '$completedBooking',
                        Icons.done_all,
                        AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Reservasi Terbaru',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18, color: AppColors.textSecondary),
                      onPressed: _fetchAdminData,
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: LoadingWidget(message: 'Memuat data reservasi...'),
                  )
                else if (_errorMessage != null)
                  EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Gagal Memuat Reservasi',
                    message: _errorMessage!,
                    actionLabel: 'Coba Lagi',
                    onAction: _fetchAdminData,
                  )
                else if (_reservations.isEmpty)
                  const EmptyStateWidget(
                    icon: Icons.calendar_today_outlined,
                    title: 'Belum Ada Reservasi',
                    message: 'Saat ini belum ada data pemesanan space dari member.',
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _reservations.length,
                    itemBuilder: (context, index) {
                      final item = _reservations[index] as Map<String, dynamic>;
                      return ReservationCard(
                        item: item,
                        onTap: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReservationDetailScreen(reservation: item),
                            ),
                          );
                          if (updated == true) {
                            _fetchAdminData();
                          }
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
