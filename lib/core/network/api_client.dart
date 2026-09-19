import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import 'api_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {
          'x-maker-key': ApiConstants.makerKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Bypass Sertifikat SSL untuk environment sekolah/emulator
    if (_dio.httpClientAdapter is IOHttpClientAdapter) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    // Interceptor Token JWT
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );

    // LogInterceptor aktif hanya pada mode debug (Antislop & Security best practice)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  ApiException _handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final resData = e.response?.data;
      if (resData is Map<String, dynamic> && resData.containsKey('message')) {
        return ApiException(resData['message'].toString(), e.response?.statusCode);
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException('Koneksi ke server terputus (Timeout). Periksa koneksi internet Anda.');
      case DioExceptionType.connectionError:
        return const ApiException('Tidak dapat terhubung ke server. Pastikan jaringan internet aktif.');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401) {
          return ApiException('Sesi telah berakhir. Silakan masuk kembali.', 401);
        } else if (code == 403) {
          return ApiException('Akses ditolak. Anda tidak memiliki izin untuk tindakan ini.', 403);
        } else if (code == 404) {
          return ApiException('Data yang diminta tidak ditemukan.', 404);
        }
        return ApiException('Terjadi kesalahan pada server (Kode: $code).', code);
      default:
        return ApiException('Terjadi kesalahan: ${e.message ?? "Koneksi bermasalah"}');
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
