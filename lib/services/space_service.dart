import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/space.dart';

class SpaceService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Space>> getSpaces({String? tipe, String? search}) async {
    final response = await _apiClient.get(
      ApiConstants.spaces,
      queryParameters: {
        if (tipe != null && tipe.isNotEmpty && tipe != 'Semua') 'tipe': tipe,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = (responseData['data'] as List<dynamic>?) ?? [];

    return data
        .map(
          (item) => Space.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<Space> getSpaceDetail(int id) async {
    final response = await _apiClient.get(ApiConstants.spaceDetail(id));
    final responseData = response.data as Map<String, dynamic>;
    return Space.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getSpaceTypes() async {
    final response = await _apiClient.get(ApiConstants.spaceTypes);
    final responseData = response.data as Map<String, dynamic>;
    final list = (responseData['data'] as List<dynamic>?) ?? [];
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> checkAvailability({
    required int idSpace,
    required String tanggal,
    String? jamMulai,
    int? durasiJam,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.spaceAvailability,
      queryParameters: {
        'id_space': idSpace,
        'tanggal': tanggal,
        if (jamMulai != null && jamMulai.isNotEmpty) 'jam_mulai': jamMulai,
        'durasi_jam': ?durasiJam,
      },
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is List && data.isNotEmpty) {
        return (data.first is Map<String, dynamic>)
            ? data.first as Map<String, dynamic>
            : <String, dynamic>{};
      } else if (data is Map<String, dynamic>) {
        return data;
      }
    }
    return {};
  }
}
