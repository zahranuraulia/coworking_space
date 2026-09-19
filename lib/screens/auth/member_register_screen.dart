import 'package:flutter/material.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class MemberRegisterScreen extends StatefulWidget {
  const MemberRegisterScreen({super.key});

  @override
  State<MemberRegisterScreen> createState() => _MemberRegisterScreenState();
}

class _MemberRegisterScreenState extends State<MemberRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _namaMemberController = TextEditingController();
  final _instansiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _telpController = TextEditingController();

  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _namaMemberController.dispose();
    _instansiController.dispose();
    _alamatController.dispose();
    _telpController.dispose();
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
      await _authService.registerMember(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        namaMember: _namaMemberController.text.trim(),
        instansi: _instansiController.text.trim(),
        alamat: _alamatController.text.trim(),
        telp: _telpController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi member berhasil! Silakan masuk.'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
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
        title: const Text('Daftar Member'),
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
                  'Buat Akun Member',
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
                  'Daftar sebagai pengguna untuk memesan ruang kerja dan meja kerja.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                AppTextField(
                  label: 'Nama Lengkap *',
                  hintText: 'Masukkan nama lengkap Anda',
                  controller: _namaMemberController,
                  prefixIcon: Icons.badge_outlined,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Username *',
                  hintText: 'Masukkan username unik',
                  controller: _usernameController,
                  prefixIcon: Icons.person_outline,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Username wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Nomor Telepon / HP *',
                  hintText: 'Contoh: 081234567890',
                  controller: _telpController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Nomor telepon wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Instansi / Perusahaan (Opsional)',
                  hintText: 'Contoh: Universitas Indonesia / PT Maju',
                  controller: _instansiController,
                  prefixIcon: Icons.business_outlined,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Alamat (Opsional)',
                  hintText: 'Masukkan alamat tempat tinggal',
                  controller: _alamatController,
                  prefixIcon: Icons.home_outlined,
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
                        'Saya setuju dengan Syarat & Ketentuan layanan reservasi coworking space.',
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
                      'Sudah punya akun? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Masuk Akun',
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
