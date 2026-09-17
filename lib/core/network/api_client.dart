import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {
          'x-maker-key': ApiConstants.makerKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30), // Bikin durasi lebih panjang
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Bypass Sertifikat SSL (mencegah error Handshake / Connection error di Emulator)
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // 1. Interceptor untuk memasukkan Token Otomatis
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

    // 2. TAMBAHAN UTAMA: LogInterceptor untuk Debugging di Terminal
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(
      path,
      queryParameters: queryParameters,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
  }) {
    return _dio.put(
      path,
      data: data,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
  }) {
    return _dio.patch(
      path,
      data: data,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
  }) {
    return _dio.delete(
      path,
      data: data,
    );
  }
}