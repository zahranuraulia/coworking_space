import 'package:flutter/material.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/admin_profile.dart';
import '../../../services/admin_service.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/stitch_app_bar.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();

  final _namaCoworkingCtrl = TextEditingController();
  final _namaPemilikCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController(text: 'Jl. Danau Ranau No. 1, Sawojajar, Malang');
  final _deskripsiCtrl = TextEditingController(
    text: 'Ruang kerja modern & produktif dengan fasilitas lengkap, koneksi fiber optik kencang, dan ruang meeting profesional.',
  );

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  AdminProfile? _profile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _namaCoworkingCtrl.dispose();
    _namaPemilikCtrl.dispose();
    _telpCtrl.dispose();
    _alamatCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prof = await _adminService.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = prof;
        _namaCoworkingCtrl.text = prof.namaCoworking;
        _namaPemilikCtrl.text = prof.namaPemilik;
        _telpCtrl.text = prof.telp;
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final updated = await _adminService.updateProfile(
        namaCoworking: _namaCoworkingCtrl.text.trim(),
        namaPemilik: _namaPemilikCtrl.text.trim(),
        telp: _telpCtrl.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _profile = updated;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil Coworking Space berhasil diperbarui!'),
          backgroundColor: AppColors.success,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal perbarui profil: $e'), backgroundColor: AppColors.error),
      );
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
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: StitchAppBar(
        title: 'Profil Coworking Space',
        subtitle: 'Pengaturan Identitas Lokasi',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 18),
            tooltip: 'Keluar Akun',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const LoadingWidget(message: 'Memuat profil lokasi space...')
            : _errorMessage != null
                ? EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Gagal Memuat Profil',
                    message: _errorMessage!,
                    actionLabel: 'Coba Lagi',
                    onAction: _fetchProfile,
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Photo & Title Card (Stitch Design)
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
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Center(
                                child: Icon(Icons.business, color: Colors.white, size: 36),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _profile?.namaCoworking ?? 'Coworking Hub',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pengelola: ${_profile?.namaPemilik ?? "Admin"}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Fields Container (Stitch Design)
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
                              'Informasi Operasional Lokasi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 14),

                            AppTextField(
                              label: 'Nama Coworking Space *',
                              hintText: 'Nama resmi tempat coworking',
                              controller: _namaCoworkingCtrl,
                              prefixIcon: Icons.store_outlined,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Nama space wajib diisi' : null,
                            ),
                            const SizedBox(height: 14),

                            AppTextField(
                              label: 'Nama Pemilik / Manajer *',
                              hintText: 'Penanggung jawab lokasi',
                              controller: _namaPemilikCtrl,
                              prefixIcon: Icons.person_outline,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Nama pemilik wajib diisi' : null,
                            ),
                            const SizedBox(height: 14),

                            AppTextField(
                              label: 'Nomor Telepon Operasional *',
                              hintText: 'Nomor kontak CS / resepsionis',
                              controller: _telpCtrl,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_outlined,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Nomor telepon wajib diisi' : null,
                            ),
                            const SizedBox(height: 14),

                            AppTextField(
                              label: 'Alamat Lengkap Lokasi',
                              hintText: 'Alamat fisik coworking space',
                              controller: _alamatCtrl,
                              prefixIcon: Icons.location_on_outlined,
                            ),
                            const SizedBox(height: 14),

                            AppTextField(
                              label: 'Deskripsi Fasilitas',
                              hintText: 'Rangkuman fasilitas umum',
                              controller: _deskripsiCtrl,
                              maxLines: 3,
                              prefixIcon: Icons.notes_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      AppButton(
                        text: 'SIMPAN PERUBAHAN',
                        isLoading: _isSaving,
                        onPressed: _isSaving ? null : _handleSave,
                      ),
                      const SizedBox(height: 12),

                      AppButton(
                        text: 'Keluar Akun Pengelola',
                        variant: AppButtonVariant.outline,
                        icon: Icons.logout,
                        onPressed: _handleLogout,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
