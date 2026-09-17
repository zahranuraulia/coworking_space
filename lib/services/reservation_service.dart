import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationService {
  static const String _baseUrl = 'https://learn.smktelkom-mlg.sch.id/coworking/api';
  static const String _makerKey = 'mk_default_ukk_2026';


  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'x-maker-key': _makerKey,
      },
    ),
  );

  Future<Map<String, String>> _authHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null ? {'Authorization': 'Bearer $token'} : {};
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    if (response.statusCode == 200 && response.data['status'] == true) {
      final token = response.data['data']?['access_token'];
      final role = response.data['data']?['role'];
      final prefs = await SharedPreferences.getInstance();
      if (token != null) await prefs.setString('auth_token', token);
      if (role != null) await prefs.setString('role', role);
    }
    return response.data;
  }

  // POST /api/reservasi
  Future<Map<String, dynamic>> createReservation({
    required int idSpace,
    required String tanggalReservasi,
    required String jamMulai,
    required int durasiJam,
    int? idDiskon,
    String? kodePromo,
  }) async {
    final headers = await _authHeader();
    final response = await _dio.post(
      '/reservasi',
      data: {
        'id_space': idSpace,
        'tanggal_reservasi': tanggalReservasi,
        'jam_mulai': jamMulai,
        'durasi_jam': durasiJam,
        if (idDiskon != null) 'id_diskon': idDiskon,
        if (kodePromo != null) 'kode_promo': kodePromo,
      },
      options: Options(headers: headers),
    );
    return response.data;
  }

  // GET /api/reservasi/my — dipakai untuk MyBookingScreen (semua status)
  Future<List<dynamic>> getUserReservations() async {
    final headers = await _authHeader();
    final response = await _dio.get('/reservasi/my', options: Options(headers: headers));
    return response.data['data'] ?? [];
  }

  // GET /api/reservasi/my/history?month=&year=
  Future<Map<String, dynamic>> getReservationHistory({int? month, int? year}) async {
    final headers = await _authHeader();
    final response = await _dio.get(
      '/reservasi/my/history',
      queryParameters: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
      options: Options(headers: headers),
    );
    return response.data['data'] ?? {};
  }

  // GET /api/reservasi/{id}/e-ticket
  Future<Map<String, dynamic>> getETicket(int reservationId) async {
    final headers = await _authHeader();
    final response = await _dio.get('/reservasi/$reservationId/e-ticket', options: Options(headers: headers));
    return response.data['data'] ?? {};
  }

  // PATCH /api/reservasi/{id}/cancel
  Future<Map<String, dynamic>> cancelReservation(int reservationId) async {
    final headers = await _authHeader();
    final response = await _dio.patch('/reservasi/$reservationId/cancel', options: Options(headers: headers));
    return response.data;
  }

    // ============ ADMIN RESERVASI METHODS ============

  // PATCH /api/admin/reservasi/{id}/status
  Future<Map<String, dynamic>> updateReservationStatus(int id, String status) async {
    final headers = await _authHeader();
    final response = await _dio.patch(
      '/admin/reservasi/$id/status',
      data: {'status': status},
      options: Options(headers: headers),
    );
    return response.data;
  }

  // POST /api/admin/reservasi/{id}/check-in
  Future<Map<String, dynamic>> checkInReservation(int id) async {
    final headers = await _authHeader();
    final response = await _dio.post(
      '/admin/reservasi/$id/check-in',
      options: Options(headers: headers),
    );
    return response.data;
  }

  // POST /api/admin/reservasi/{id}/check-out
  Future<Map<String, dynamic>> checkOutReservation(int id) async {
    final headers = await _authHeader();
    final response = await _dio.post(
      '/admin/reservasi/$id/check-out',
      options: Options(headers: headers),
    );
    return response.data;
  }

  
  
}