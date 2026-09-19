import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/admin_profile.dart';
import '../models/revenue_report.dart';
import '../models/space.dart';

class AdminService {
  final ApiClient _apiClient = ApiClient();

  // Profil Coworking Space
  Future<AdminProfile> getProfile() async {
    final response = await _apiClient.get(ApiConstants.adminProfile);
    return AdminProfile.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<AdminProfile> updateProfile({
    required String namaCoworking,
    required String namaPemilik,
    required String telp,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.adminProfile,
      data: {
        'nama_coworking': namaCoworking,
        'nama_pemilik': namaPemilik,
        'telp': telp,
      },
    );
    return AdminProfile.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  // Ruangan / Space CRUD
  Future<List<Space>> getSpaces() async {
    final response = await _apiClient.get(ApiConstants.adminSpaces);
    final list = (response.data['data'] as List<dynamic>?) ?? [];
    return list.map((e) => Space.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Space> getSpaceDetail(int id) async {
    final response = await _apiClient.get(ApiConstants.adminSpaceDetail(id));
    return Space.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Space> createSpace({
    required String namaSpace,
    required double hargaPerJam,
    required String tipe,
    required int kapasitas,
    required String deskripsi,
    String? foto,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.adminSpaces,
      data: {
        'nama_space': namaSpace,
        'harga_per_jam': hargaPerJam,
        'tipe': tipe,
        'kapasitas': kapasitas,
        'deskripsi': deskripsi,
        if (foto != null && foto.isNotEmpty) 'foto': foto,
      },
    );
    return Space.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Space> updateSpace(
    int id, {
    required String namaSpace,
    required double hargaPerJam,
    required String tipe,
    required int kapasitas,
    required String deskripsi,
    String? foto,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.adminSpaceDetail(id),
      data: {
        'nama_space': namaSpace,
        'harga_per_jam': hargaPerJam,
        'tipe': tipe,
        'kapasitas': kapasitas,
        'deskripsi': deskripsi,
        if (foto != null && foto.isNotEmpty) 'foto': foto,
      },
    );
    return Space.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteSpace(int id) async {
    await _apiClient.delete(ApiConstants.adminSpaceDetail(id));
  }

  // Laporan Pendapatan
  Future<RevenueReport> getMonthlyReport({int? month, int? year}) async {
    final response = await _apiClient.get(
      ApiConstants.adminReportsMonthly,
      queryParameters: {
        'month': ?month,
        'year': ?year,
      },
    );
    return RevenueReport.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
