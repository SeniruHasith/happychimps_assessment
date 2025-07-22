import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static const String baseUrl = 'https://apiv2.in2dfuture.com';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int tokenExpirationBuffer = 300; // 5 minutes in seconds

  late Dio _dio;
  final SharedPreferences _prefs;
  final GlobalKey<NavigatorState>? navigatorKey;
  late AuthInterceptor authInterceptor;

  DioClient(this._prefs, {this.navigatorKey}) {
    authInterceptor = AuthInterceptor(_prefs, navigatorKey);
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
        authInterceptor,
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

class AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  final GlobalKey<NavigatorState>? navigatorKey;
  static const String _tokenKey = 'auth_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _loginEndpoint = '/api/pos/auth/login';

  AuthInterceptor(this._prefs, this.navigatorKey);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Skip adding token for login endpoint
    if (options.path != _loginEndpoint) {
      final token = _prefs.getString(_tokenKey);
      final tokenExpiry = _prefs.getInt(_tokenExpiryKey);
      
      if (token != null) {
        // Check if token is about to expire
        if (tokenExpiry != null) {
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          if (tokenExpiry - now <= DioClient.tokenExpirationBuffer) {
            // Token is about to expire or has expired
            _handleTokenExpiration();
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  statusMessage: 'Token expired',
                ),
              ),
            );
            return;
          }
        }
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Clear token and navigate to login
      await _handleTokenExpiration();
    }
    handler.next(err);
  }

  Future<void> _handleTokenExpiration() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_tokenExpiryKey);

    // Navigate to login screen if navigator key is provided
    if (navigatorKey?.currentContext != null) {
      Navigator.of(navigatorKey!.currentContext!).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  void saveTokenExpiry(String token) {
    // Parse JWT token to get expiration time
    try {
      final parts = token.split('.');
      if (parts.length != 3) return;

      final payload = _decodeBase64(parts[1]);
      final payloadMap = Map<String, dynamic>.from(payload);
      
      if (payloadMap.containsKey('exp')) {
        final expiry = payloadMap['exp'] as int;
        _prefs.setInt(_tokenExpiryKey, expiry);
      }
    } catch (e) {
      debugPrint('Error parsing token expiry: $e');
    }
  }

  Map<String, dynamic> _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Invalid base64 string');
    }
    return Map<String, dynamic>.from(
      _parseJwt(output),
    );
  }

  Map<String, dynamic> _parseJwt(String base64String) {
    final normalizedSource = base64.normalize(base64String);
    return Map<String, dynamic>.from(
      _jsonDecode(
        utf8.decode(base64.decode(normalizedSource)),
      ),
    );
  }

  dynamic _jsonDecode(String source) {
    return Map<String, dynamic>.from(
      const JsonDecoder().convert(source) as Map,
    );
  }
} 