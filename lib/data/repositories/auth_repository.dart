import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/dio_client.dart';
import '../../core/errors/failures.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient;
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _userKey = 'user_data';
  static const String _companyKey = 'company_data';

  AuthRepository(this._dioClient, this._prefs);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/pos/auth/login',
        data: {
          'email': email,
          'password': password,
          'remember_me': 1,
        },
      );

      if (response.data['error'] != null) {
        throw ServerFailure(
          message: response.data['error'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }

      final result = response.data['result'];
      final authResponse = AuthResponse.fromJson(result);
      
      // Save auth data
      await _prefs.setString(_tokenKey, authResponse.accessToken);
      await _prefs.setString(_tokenTypeKey, authResponse.tokenType);
      await _prefs.setString(_userKey, result['user'].toString());
      await _prefs.setString(_companyKey, result['company'].toString());

      // Save token expiry
      _dioClient.authInterceptor.saveTokenExpiry(authResponse.accessToken);

      return authResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthenticationFailure(
          message: 'Invalid email or password',
          statusCode: 401,
        );
      }
      throw ServerFailure(
        message: e.response?.data['error'] ?? 'Server error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw const NetworkFailure(message: 'Network error occurred');
    }
  }

  Future<void> logout() async {
    try {
      await _dioClient.dio.post('/api/pos/auth/logout');
    } catch (e) {
      // Ignore logout API errors
    } finally {
      // Clear local storage
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_tokenTypeKey);
      await _prefs.remove(_userKey);
      await _prefs.remove(_companyKey);
    }
  }

  bool isLoggedIn() {
    return _prefs.containsKey(_tokenKey);
  }

  Future<AuthResponse?> getCurrentUser() async {
    final token = _prefs.getString(_tokenKey);
    final tokenType = _prefs.getString(_tokenTypeKey);
    final userData = _prefs.getString(_userKey);
    final companyData = _prefs.getString(_companyKey);

    if (token != null && tokenType != null && userData != null && companyData != null) {
      try {
        return AuthResponse(
          accessToken: token,
          tokenType: tokenType,
          user: UserModel.fromJson(userData as Map<String, dynamic>),
          company: (companyData as List<dynamic>)
              .map((json) => Company.fromJson(json as Map<String, dynamic>))
              .toList(),
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }
} 