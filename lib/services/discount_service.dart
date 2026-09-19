import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/discount.dart';

class DiscountService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Discount>> getActiveDiscounts() async {
    final response = await _apiClient.get(ApiConstants.diskonActive);
    final responseData = response.data as Map<String, dynamic>;
    final list = (responseData['data'] as List<dynamic>?) ?? [];
    return list.map((item) => Discount.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Discount> checkDiscount(String kode) async {
    final response = await _apiClient.post(
      ApiConstants.diskonCheck,
      data: {'nama_diskon': kode},
    );
    final responseData = response.data as Map<String, dynamic>;
    return Discount.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  // ============ ADMIN METHODS ============

  Future<List<Discount>> getAdminDiscounts() async {
    final response = await _apiClient.get(ApiConstants.adminDiskon);
    final responseData = response.data as Map<String, dynamic>;
    final list = (responseData['data'] as List<dynamic>?) ?? [];
    return list.map((item) => Discount.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Discount> getAdminDiscountDetail(int id) async {
    final response = await _apiClient.get(ApiConstants.adminDiskonDetail(id));
    final responseData = response.data as Map<String, dynamic>;
    return Discount.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  Future<Discount> createDiscount({
    required String namaDiskon,
    required double persentaseDiskon,
    required String tanggalAwal,
    required String tanggalAkhir,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.adminDiskon,
      data: {
        'nama_diskon': namaDiskon,
        'persentase_diskon': persentaseDiskon,
        'tanggal_awal': tanggalAwal,
        'tanggal_akhir': tanggalAkhir,
      },
    );
    final responseData = response.data as Map<String, dynamic>;
    return Discount.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  Future<Discount> updateDiscount(
    int id, {
    String? namaDiskon,
    double? persentaseDiskon,
    String? tanggalAwal,
    String? tanggalAkhir,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.adminDiskonDetail(id),
      data: <String, dynamic>{
        'nama_diskon': ?namaDiskon,
        'persentase_diskon': ?persentaseDiskon,
        'tanggal_awal': ?tanggalAwal,
        'tanggal_akhir': ?tanggalAkhir,
      },
    );
    final responseData = response.data as Map<String, dynamic>;
    return Discount.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  Future<void> deleteDiscount(int id) async {
    await _apiClient.delete(ApiConstants.adminDiskonDetail(id));
  }
}
