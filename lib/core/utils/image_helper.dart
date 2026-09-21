import '../constants/api_constants.dart';

class ImageHelper {
  /// Normalizes server image URLs to handle reverse proxy routing,
  /// HTTPS upgrading, and bare filenames.
  static String? normalizeUrl(String? rawUrl, {String folder = 'spaces'}) {
    if (rawUrl == null) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    // 1. Bare filename case (e.g. "1789992032651-796110024.jpg")
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return '${ApiConstants.baseUrl}/uploads/$folder/$trimmed';
    }

    String result = trimmed;

    // 2. Localhost development seed fallback
    if (result.contains('localhost:3000/uploads/')) {
      result = result.replaceFirst(
        'http://localhost:3000/uploads/',
        '${ApiConstants.baseUrl}/uploads/',
      );
      result = result.replaceFirst(
        'https://localhost:3000/uploads/',
        '${ApiConstants.baseUrl}/uploads/',
      );
    }

    // 3. Reverse proxy SMK Telkom case
    // The server generates "http://learn.smktelkom-mlg.sch.id/uploads/..."
    // but the backend is hosted under "/coworking/uploads/..." over HTTPS.
    if (result.contains('learn.smktelkom-mlg.sch.id')) {
      if (result.startsWith('http://')) {
        result = result.replaceFirst('http://', 'https://');
      }
      if (result.contains('/uploads/') && !result.contains('/coworking/uploads/')) {
        result = result.replaceFirst('/uploads/', '/coworking/uploads/');
      }
    }

    return result;
  }
}
