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

  Future<AuthResponse> login(String email, String password, {bool rememberMe = false}) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/pos/auth/login',
        data: {
          'email': email,
          'password': password,
          'remember_me': rememberMe ? 1 : 0,
        },
      );

      if (response.data['error'] != null) {
        final error = response.data['error'];
        if (error is Map<String, dynamic>) {
          final validationErrors = <String, List<String>>{};
          error.forEach((key, value) {
            if (value is List) {
              validationErrors[key] = value.map((e) => e.toString()).toList();
              // Check for unregistered user error
              if (key == 'email' && value.any((e) => e.toString().toLowerCase().contains('not registered'))) {
                throw UnregisteredUserFailure(
                  message: value.first.toString(),
                  email: email,
                  statusCode: response.statusCode,
                );
              }
            } else if (value is String) {
              validationErrors[key] = [value];
            }
          });
          
          if (validationErrors.isNotEmpty) {
            // Get the first error message to use as the main message
            final firstError = validationErrors.entries.first;
            final mainMessage = firstError.value.first;
            
            throw ValidationFailure(
              errors: validationErrors,
              message: mainMessage,
              statusCode: response.statusCode,
            );
          }
        }
        throw ServerFailure(
          message: error.toString(),
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
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkFailure(
          message: 'Connection timeout. Please check your internet connection.',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure(
          message: 'No internet connection. Please check your network settings.',
        );
      }

      final errorData = e.response?.data;
      if (errorData != null && errorData is Map<String, dynamic>) {
        final error = errorData['error'];
        
        // Handle validation errors
        if (error is Map<String, dynamic>) {
          final validationErrors = <String, List<String>>{};
          error.forEach((key, value) {
            if (value is List) {
              validationErrors[key] = value.map((e) => e.toString()).toList();
            } else if (value is String) {
              validationErrors[key] = [value];
            }
          });
          
          if (validationErrors.isNotEmpty) {
            // Determine if it's an unregistered user case first
            if (validationErrors.containsKey('email')) {
              final emailErrors = validationErrors['email']!;
              final unregisteredError = emailErrors.firstWhere(
                (msg) => msg.toLowerCase().contains('not registered'),
                orElse: () => '',
              );
              if (unregisteredError.isNotEmpty) {
                throw UnregisteredUserFailure(
                  message: unregisteredError,
                  email: email,
                  statusCode: e.response?.statusCode,
                );
              }
            }

            // Use first validation error message as main message
            final mainMessage = validationErrors.entries.first.value.first;

            throw ValidationFailure(
              errors: validationErrors,
              message: mainMessage,
              statusCode: e.response?.statusCode,
            );
          }
        }

        // Handle other error messages
        if (error != null) {
          if (e.response?.statusCode == 401) {
            throw AuthenticationFailure(
              message: error.toString(),
              statusCode: 401,
            );
          }
          throw ServerFailure(
            message: error.toString(),
            statusCode: e.response?.statusCode,
          );
        }
      }

      // If we couldn't extract a specific error message
      if (e.response?.statusCode == 401) {
        throw const AuthenticationFailure(
          message: 'Invalid email or password',
          statusCode: 401,
        );
      }

      throw ServerFailure(
        message: 'Server error occurred. Please try again later.',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw const ServerFailure(
        message: 'An unexpected error occurred. Please try again.',
      );
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