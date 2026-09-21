import 'package:flutter/material.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../member/member_navbar_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan password harus diisi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final responseData = await _authService.login(
        username: username,
        password: password,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      final String role = (responseData['role'] ?? 'member').toString();
      final bool isGlobalSeed = responseData['is_global_seed'] == true;

      // Peringatan jika login dengan akun seeder global panitia (maker_id: null)
      if (isGlobalSeed && (role == 'admin_space' || role == 'admin')) {
        final proceed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.info_outline, color: AppColors.secondary, size: 22),
                SizedBox(width: 8),
                Text('Akun Global Panitia', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'Anda masuk menggunakan akun template bawaan panitia (admin_space1 / Moklet Hub Coworking).\n\n'
              'Akun ini terpisah dari tenant App Maker Anda, sehingga ruangan dan transaksi milik coworking space Anda tidak akan muncul pada akun ini.\n\n'
              'Tetap lanjutkan ke dashboard akun panitia?',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal & Ganti Akun', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(88, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Lanjutkan', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );

        if (proceed != true) {
          await _authService.logout();
          return;
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil masuk sebagai $role'),
          backgroundColor: AppColors.success,
        ),
      );

      if (role == 'admin_space' || role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MemberNavbar()),
        );
      }
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

  void _showRegisterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Pilih Jenis Pendaftaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Daftar sesuai dengan peran akun yang ingin kamu gunakan.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Daftar Sebagai Member',
                  icon: Icons.person_outline,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/register-member');
                  },
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'Daftar Sebagai Admin Space',
                  variant: AppButtonVariant.outline,
                  icon: Icons.storefront_outlined,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/register-admin');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Masuk Akun'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // Logo Box (Stitch Design)
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.work_outline_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Selamat Datang Kembali!',
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
                'Masuk ke akun untuk memesan ruangan atau mengelola coworking space.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 20),

              // Banner Informasi Terpadu
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.accentBlue,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Pintu Masuk Terpadu: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'Member dan Pengelola Space masuk di sini. Sistem mengenali peran akun secara otomatis.',
                              style: TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              AppTextField(
                label: 'Username',
                hintText: 'Masukkan username terdaftar',
                controller: _usernameController,
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              AppTextField(
                label: 'Password',
                hintText: 'Masukkan kata sandi',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleLogin(),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (val) =>
                              setState(() => _rememberMe = val ?? true),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ingat saya',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              AppButton(
                text: 'Masuk',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum punya akun? ',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: _showRegisterOptions,
                    child: const Text(
                      'Daftar Sekarang',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
