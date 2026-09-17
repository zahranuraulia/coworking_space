import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _nameController = TextEditingController();
  final _spaceNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _spaceNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final spaceName = _spaceNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || spaceName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua bidang bertanda bintang wajib diisi'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.registerAdmin(
        name: name,
        spaceName: spaceName,
        email: email,
        phone: phone,
        password: password,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi Pengelola Berhasil! Silakan masuk.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } on DioException catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      String errorMessage = 'Registrasi gagal. Coba lagi nanti.';
      if (e.response?.data != null && e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Daftar Sebagai Pengelola',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Daftarkan Space Anda',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Mulai kelola coworking space dan dapatkan reservasi dari member.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),

              const SizedBox(height: 24),

              // Form Nama Pemilik
              _buildLabel('Nama Lengkap *'),
              TextField(
                controller: _nameController,
                decoration: _buildInputDecoration('Masukkan nama lengkap Anda', Icons.person_outline),
              ),

              const SizedBox(height: 16),

              // Form Nama Space
              _buildLabel('Nama Coworking Space *'),
              TextField(
                controller: _spaceNameController,
                decoration: _buildInputDecoration('Contoh: Kopi & Space Malang', Icons.storefront_outlined),
              ),

              const SizedBox(height: 16),

              // Form Email
              _buildLabel('Email Bisnis *'),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration('Masukkan email aktif', Icons.email_outlined),
              ),

              const SizedBox(height: 16),

              // Form Telepon
              _buildLabel('Nomor WhatsApp / HP'),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _buildInputDecoration('Contoh: 08123456789', Icons.phone_outlined),
              ),

              const SizedBox(height: 16),

              // Form Password
              _buildLabel('Password *'),
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: _buildInputDecoration('Buat kata sandi minimal 8 karakter', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF94A3B8),
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Daftarkan Space',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B)),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );
  }
}