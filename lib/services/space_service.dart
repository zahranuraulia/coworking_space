import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/space.dart';

class SpaceService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Space>> getSpaces() async {
    final response = await _apiClient.get(
      ApiConstants.spaces,
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as List<dynamic>;

    return data
        .map(
          (item) => Space.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<Map<String, dynamic>> checkAvailability({
    required int idSpace,
    required String tanggal,
    required String jamMulai,
    required int durasiJam,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.spaceAvailability,
      queryParameters: {
        'id_space': idSpace,
        'tanggal': tanggal,
        'jam_mulai': jamMulai,
        'durasi_jam': durasiJam,
      },
    );

    final responseData = response.data as Map<String, dynamic>;

    return responseData['data'] as Map<String, dynamic>;
  }
}