import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // 1. Login User (Member atau Admin Space)
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'username': username, 'password': password},
      );

      final data = response.data;

      String token = '';
      String role = 'member';
      int? makerId;

      if (data is Map<String, dynamic>) {
        token = data['token'] ??
            data['access_token'] ??
            data['data']?['access_token'] ??
            data['data']?['token'] ??
            '';

        final userMap = (data['data'] is Map<String, dynamic>)
            ? data['data'] as Map<String, dynamic>
            : (data['user'] is Map<String, dynamic>
                ? data['user'] as Map<String, dynamic>
                : data);

        if (userMap['role'] != null) {
          role = userMap['role'].toString();
        } else if (data['role'] != null) {
          role = data['role'].toString();
        }

        final rawMaker = userMap['maker_id'];
        if (rawMaker != null) {
          makerId = rawMaker is int ? rawMaker : int.tryParse(rawMaker.toString());
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      await prefs.setString('auth_token', token); // compatibility key
      await prefs.setString('user_role', role);
      await prefs.setString('username', username);

      if (makerId != null) {
        await prefs.setInt('maker_id', makerId);
        await prefs.setBool('is_global_seed', false);
      } else {
        await prefs.remove('maker_id');
        await prefs.setBool('is_global_seed', true);
      }

      return {
        'token': token,
        'role': role,
        'data': data,
        'maker_id': makerId,
        'is_global_seed': makerId == null,
      };
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal melakukan login: $e');
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
        ApiConstants.memberRegister,
        data: {
          'username': username,
          'nama_member': namaMember,
          'password': password,
          if (instansi != null && instansi.isNotEmpty) 'instansi': instansi,
          if (alamat != null && alamat.isNotEmpty) 'alamat': alamat,
          if (telp != null && telp.isNotEmpty) 'telp': telp,
        },
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal mendaftar member: $e');
    }
  }

  // 3. Register Admin Space (sesuai kontrak resmi /api/auth/register/admin-space)
  Future<void> registerAdmin({
    required String username,
    required String password,
    required String namaCoworking,
    required String namaPemilik,
    required String telp,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.adminRegister,
        data: {
          'username': username,
          'password': password,
          'nama_coworking': namaCoworking,
          'nama_pemilik': namaPemilik,
          'telp': telp,
        },
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Gagal mendaftar admin coworking: $e');
    }
  }

  // 4. Cek Sesi Login
  Future<Map<String, dynamic>> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final role = prefs.getString('user_role');
    final username = prefs.getString('username');
    final isGlobalSeed = prefs.getBool('is_global_seed') ?? false;

    return {
      'token': token,
      'role': role,
      'username': username,
      'is_global_seed': isGlobalSeed,
    };
  }

  // 5. Logout & Bersihkan Sesi
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('username');
    await prefs.remove('maker_id');
    await prefs.remove('is_global_seed');
  }
}
