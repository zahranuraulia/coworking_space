import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coworkingspace/core/network/api_client.dart';
import '../core/constants/api_constants.dart';

class AuthService {
  // Gunakan ApiClient agar otomatis membawa BaseURL, Header x-maker-key, dan LogInterceptor
  final ApiClient _apiClient = ApiClient();

  // 1. Login
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login, // Endpoint: /api/auth/login
        data: {'username': username, 'password': password},
      );

      final data = response.data;

      // Parsing token dan role dari format response API SMK Telkom
      String token = '';
      String role = 'member';

      if (data is Map<String, dynamic>) {
        token =
            data['token'] ??
            data['access_token'] ??
            data['data']?['token'] ??
            '';

        if (data['user'] != null && data['user']['role'] != null) {
          role = data['user']['role'];
        } else if (data['data'] != null && data['data']['user'] != null) {
          role = data['data']['user']['role'] ?? 'member';
        } else if (data['role'] != null) {
          role = data['role'];
        }
      }

      // Simpan Token & Role ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', role);

      return {'token': token, 'role': role, 'data': data};
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Gagal melakukan login: $e');
    }
  }

  // 2. Register Member
  Future<void> registerMember({
    required String username,
    required String namaMember,
    required String password,
    String? instansi,
    String? alamat,
    String? telp,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.memberRegister, // Endpoint: /api/auth/register/member
        data: {
          'username': username,
          'nama_member': namaMember,
          'password': password,
          'instansi': instansi ?? '',
          'alamat': alamat ?? '',
          'telp': telp ?? '',
        },
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Gagal mendaftar member: $e');
    }
  }

  // 3. Register Admin Space
  Future<void> registerAdmin({
    required String name,
    required String spaceName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.adminRegister, // Endpoint: /api/auth/register/admin
        data: {
          'name': name,
          'space_name': spaceName,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Gagal mendaftar admin: $e');
    }
  }

  // 4. Cek Sesi (Membaca data dari SharedPreferences)
  Future<Map<String, String?>> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString('access_token') ?? prefs.getString('auth_token');
    final role = prefs.getString('user_role');

    return {'token': token, 'role': role};
  }

  // 5. Logout (Menghapus sesi dari SharedPreferences)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
  }
}
