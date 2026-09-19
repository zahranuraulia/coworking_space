import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class UploadService {
  final ApiClient _apiClient = ApiClient();

  Future<String> uploadGeneralImage(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _apiClient.post(
      ApiConstants.uploadImage,
      data: formData,
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return (data['filename'] ?? data['url'] ?? '').toString();
  }

  Future<String> uploadSpacePhoto(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _apiClient.post(
      ApiConstants.uploadSpaces,
      data: formData,
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return (data['filename'] ?? data['url'] ?? '').toString();
  }

  Future<String> uploadMemberPhoto(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _apiClient.post(
      ApiConstants.uploadMembers,
      data: formData,
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return (data['filename'] ?? data['url'] ?? '').toString();
  }
}
