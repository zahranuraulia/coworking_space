import 'package:flutter/material.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final _usernameController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _namaCoworkingController = TextEditingController();
  final _telpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _namaPemilikController.dispose();
    _namaCoworkingController.dispose();
    _telpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi password tidak cocok'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui Syarat & Ketentuan untuk mendaftar.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.registerAdmin(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        namaCoworking: _namaCoworkingController.text.trim(),
        namaPemilik: _namaPemilikController.text.trim(),
        telp: _telpController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi pengelola berhasil! Silakan masuk.'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Daftar Sebagai Pengelola'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Daftarkan Space Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mulai kelola coworking space dan terima reservasi dari member.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                AppTextField(
                  label: 'Username Admin *',
                  hintText: 'Masukkan username login admin',
                  controller: _usernameController,
                  prefixIcon: Icons.account_circle_outlined,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Username wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Nama Lengkap Pengelola *',
                  hintText: 'Nama pemilik atau penanggung jawab',
                  controller: _namaPemilikController,
                  prefixIcon: Icons.person_outline,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Nama pengelola wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Nama Coworking Space *',
                  hintText: 'Contoh: Moklet Hub Coworking Space',
                  controller: _namaCoworkingController,
                  prefixIcon: Icons.storefront_outlined,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Nama coworking space wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Nomor WhatsApp / Telepon *',
                  hintText: 'Contoh: 081298765432',
                  controller: _telpController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Nomor telepon wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Password *',
                  hintText: 'Minimal 6 karakter',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (val) =>
                      val == null || val.length < 6 ? 'Password minimal 6 karakter' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Konfirmasi Password *',
                  hintText: 'Ulangi password Anda',
                  controller: _confirmPasswordController,
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Konfirmasi password wajib diisi';
                    if (val != _passwordController.text) return 'Password tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Checkbox Terms
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Saya setuju dengan Syarat & Ketentuan pengelolaan space.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                AppButton(
                  text: 'DAFTAR',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah memiliki akun pengelola? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: AppColors.accentBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
