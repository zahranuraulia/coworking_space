import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:coworkingspace/services/auth_service.dart';

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
  final _namaMemberController = TextEditingController();
  final _instansiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _telpController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _namaMemberController.dispose();
    _instansiController.dispose();
    _alamatController.dispose();
    _telpController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

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

      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi member berhasil! Silakan masuk.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on DioException catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      String errorMessage = 'Gagal mendaftar. Periksa kembali data kamu.';
      if (e.response != null && e.response?.data != null) {
        final resData = e.response?.data;
        if (resData is Map<String, dynamic> && resData.containsKey('message')) {
          errorMessage = resData['message'].toString();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
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
          'Daftar Member',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Buat Akun Member',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Daftar sebagai pengguna untuk memesan coworking space.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),

                const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _namaMemberController,
                  validator: (val) => val == null || val.isEmpty ? 'Nama lengkap wajib diisi' : null,
                  decoration: _inputDecoration('Masukkan nama lengkap', Icons.badge_outlined),
                ),
                const SizedBox(height: 16),

                const Text('Username', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  validator: (val) => val == null || val.isEmpty ? 'Username wajib diisi' : null,
                  decoration: _inputDecoration('Masukkan username', Icons.person_outline),
                ),
                const SizedBox(height: 16),

                const Text('Nomor Telepon / HP', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _telpController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Contoh: 08123456789', Icons.phone_outlined),
                ),
                const SizedBox(height: 16),

                const Text('Instansi / Perusahaan (Opsional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _instansiController,
                  decoration: _inputDecoration('Masukkan instansi atau kampus', Icons.business_outlined),
                ),
                const SizedBox(height: 16),

                const Text('Alamat (Opsional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _alamatController,
                  decoration: _inputDecoration('Masukkan alamat tempat tinggal', Icons.home_outlined),
                ),
                const SizedBox(height: 16),

                const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  validator: (val) => val == null || val.length < 6 ? 'Password minimal 6 karakter' : null,
                  decoration: _inputDecoration('Masukkan kata sandi', Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8)),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('DAFTAR SEBAGAI MEMBER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ],
                        ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun? ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Masuk Akun', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}