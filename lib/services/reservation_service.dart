import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/e_ticket.dart';
import '../models/reservation.dart';

class ReservationService {
  final ApiClient _apiClient = ApiClient();

  // POST /api/reservasi - Buat reservasi baru
  Future<Map<String, dynamic>> createReservation({
    required int idSpace,
    required String tanggalReservasi,
    required String jamMulai,
    required int durasiJam,
    int? idDiskon,
    String? kodePromo,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.reservations,
      data: {
        'id_space': idSpace,
        'tanggal_reservasi': tanggalReservasi,
        'jam_mulai': jamMulai,
        'durasi_jam': durasiJam,
        'id_diskon': ?idDiskon,
        if (kodePromo != null && kodePromo.isNotEmpty) 'kode_promo': kodePromo,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  // GET /api/reservasi/my - Pemesanan milik member aktif
  Future<List<Reservation>> getMyReservations() async {
    final response = await _apiClient.get(ApiConstants.myReservations);
    final responseData = response.data as Map<String, dynamic>;
    final list = responseData['data'] as List<dynamic>? ?? [];
    return list.map((item) => Reservation.fromJson(item as Map<String, dynamic>)).toList();
  }

  // Kompatibilitas untuk kode lama yang membaca raw Map
  Future<List<dynamic>> getUserReservations() async {
    final response = await _apiClient.get(ApiConstants.myReservations);
    final responseData = response.data as Map<String, dynamic>;
    return (responseData['data'] as List<dynamic>?) ?? [];
  }

  // GET /api/reservasi/my/history - Histori bulanan
  Future<Map<String, dynamic>> getReservationHistory({int? month, int? year}) async {
    final response = await _apiClient.get(
      ApiConstants.myHistory,
      queryParameters: {
        'month': ?month,
        'year': ?year,
      },
    );
    final responseData = response.data as Map<String, dynamic>;
    return (responseData['data'] as Map<String, dynamic>?) ?? {};
  }

  // GET /api/reservasi/{id}/e-ticket - Ambil e-ticket digital
  Future<ETicket> getETicket(int reservationId) async {
    final response = await _apiClient.get(ApiConstants.reservationETicket(reservationId));
    final responseData = response.data as Map<String, dynamic>;
    final data = (responseData['data'] as Map<String, dynamic>?) ?? {};
    return ETicket.fromJson(data);
  }

  // PATCH /api/reservasi/{id}/cancel - Batalkan reservasi member
  Future<Map<String, dynamic>> cancelReservation(int reservationId) async {
    final response = await _apiClient.patch(ApiConstants.cancelReservation(reservationId));
    return response.data as Map<String, dynamic>;
  }

  // ============ ADMIN RESERVASI METHODS ============

  // GET /api/admin/reservasi - Daftar semua reservasi untuk admin
  Future<List<dynamic>> getAdminReservations({
    int? month,
    int? year,
    String? status,
    int? idSpace,
    String? tanggal,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.adminReservations,
      queryParameters: {
        'month': ?month,
        'year': ?year,
        if (status != null && status.isNotEmpty) 'status': status,
        'id_space': ?idSpace,
        if (tanggal != null && tanggal.isNotEmpty) 'tanggal': tanggal,
      },
    );
    final responseData = response.data as Map<String, dynamic>;
    return (responseData['data'] as List<dynamic>?) ?? [];
  }

  // PATCH /api/admin/reservasi/{id}/status - Konfirmasi status oleh Admin
  Future<Map<String, dynamic>> updateReservationStatus(int id, String status) async {
    final response = await _apiClient.patch(
      ApiConstants.adminUpdateReservationStatus(id),
      data: {'status': status},
    );
    return response.data as Map<String, dynamic>;
  }

  // POST /api/admin/reservasi/{id}/check-in - Check in tamu
  Future<Map<String, dynamic>> checkInReservation(int id) async {
    final response = await _apiClient.post(ApiConstants.adminCheckIn(id));
    return response.data as Map<String, dynamic>;
  }

  // POST /api/admin/reservasi/{id}/check-out - Check out tamu
  Future<Map<String, dynamic>> checkOutReservation(int id) async {
    final response = await _apiClient.post(ApiConstants.adminCheckOut(id));
    return response.data as Map<String, dynamic>;
  }
}
