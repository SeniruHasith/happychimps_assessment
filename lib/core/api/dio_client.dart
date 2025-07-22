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
          'Accept': 'application/json',
          'Tz': 'Europe/London',
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
  static const String _refreshTokenKey = 'refresh_token';

  _AuthInterceptor(this._prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _prefs.getString(_tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      try {
        final refreshToken = _prefs.getString(_refreshTokenKey);
        if (refreshToken != null) {
          final dio = Dio(BaseOptions(baseUrl: DioClient.baseUrl));
          final response = await dio.post(
            '/api/v2/auth/refresh',
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200) {
            final newToken = response.data['token'];
            final newRefreshToken = response.data['refresh_token'];

            await _prefs.setString(_tokenKey, newToken);
            await _prefs.setString(_refreshTokenKey, newRefreshToken);

            // Retry the original request with the new token
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';
            
            try {
              final response = await dio.fetch(options);
              return handler.resolve(response);
            } on DioException catch (e) {
              return handler.next(e);
            }
          }
        }
      } catch (e) {
        // If refresh fails, clear tokens and let the error propagate
        await _prefs.remove(_tokenKey);
        await _prefs.remove(_refreshTokenKey);
      }
    }
    handler.next(err);
  }
} 