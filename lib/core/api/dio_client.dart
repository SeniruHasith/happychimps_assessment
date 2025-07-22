import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static const String baseUrl = 'https://apiv2.in2dfuture.com';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  late Dio _dio;
  final SharedPreferences _prefs;

  DioClient(this._prefs) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: connectionTimeout),
        receiveTimeout: const Duration(milliseconds: receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    )..interceptors.addAll([
        _AuthInterceptor(_prefs),
        if (kDebugMode) PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: true,
          error: true,
          compact: true,
        ),
      ]);
  }

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';
  static const String _loginEndpoint = '/api/pos/auth/login';

  _AuthInterceptor(this._prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Skip adding token for login endpoint
    if (options.path != _loginEndpoint) {
      final token = _prefs.getString(_tokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Clear token on 401 error
      await _prefs.remove(_tokenKey);
    }
    handler.next(err);
  }
} 