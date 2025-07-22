import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:happychimps_assessment/data/repositories/auth_repository.dart';
import 'package:happychimps_assessment/data/models/user_model.dart';
import 'package:happychimps_assessment/features/auth/bloc/auth_bloc.dart';
import 'package:happychimps_assessment/core/errors/failures.dart';
import 'auth_bloc_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late AuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  final testAuthResponse = AuthResponse(
    accessToken: 'test_token',
    tokenType: 'Bearer',
    user: UserModel(
      id: 1,
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      phoneNumber: '1234567890',
      sessionTime: null,
      role: [],
      companyId: null,
      companyPermissions: [],
    ),
    company: [
      Company(
        id: 1,
        companyName: 'Test Company',
        companyEmail: 'company@example.com',
        phone: Phone(
          primary: '1234567890',
          business: '1234567890',
        ),
        registrationNo: '123456',
        businessName: 'Test Business',
        currency: Currency(
          id: 1,
          name: 'USD',
          code: 'USD',
          symbol: '\$',
        ),
        country: Country(
          id: 1,
          name: 'United States',
          code: 'US',
          regionId: 1,
          countryCode: '1',
        ),
        logo: 'https://example.com/logo.png',
        receiptLogo: 'https://example.com/receipt-logo.png',
      ),
    ],
  );

  group('AuthBloc', () {
    group('Login', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when login is successful',
        build: () {
          when(mockAuthRepository.login(
            'test@example.com',
            'password123',
          )).thenAnswer((_) async => testAuthResponse);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const LoginEvent(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having(
            (state) => state.authData.user.email,
            'user email',
            'test@example.com',
          ),
        ],
        verify: (_) {
          verify(mockAuthRepository.login(
            'test@example.com',
            'password123',
          )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when login fails with invalid credentials',
        build: () {
          when(mockAuthRepository.login(
            'test@example.com',
            'wrong_password',
          )).thenThrow(
            const AuthenticationFailure(
              message: 'Invalid email or password',
              statusCode: 401,
            ),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const LoginEvent(
            email: 'test@example.com',
            password: 'wrong_password',
          ),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            'Invalid email or password',
          ),
        ],
        verify: (_) {
          verify(mockAuthRepository.login(
            'test@example.com',
            'wrong_password',
          )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when login fails with network error',
        build: () {
          when(mockAuthRepository.login(
            'test@example.com',
            'password123',
          )).thenThrow(
            const NetworkFailure(
              message: 'Network error occurred',
            ),
          );
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const LoginEvent(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'error message',
            'Network error occurred',
          ),
        ],
        verify: (_) {
          verify(mockAuthRepository.login(
            'test@example.com',
            'password123',
          )).called(1);
        },
      );
    });

    group('CheckAuthStatus', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user is logged in',
        build: () {
          when(mockAuthRepository.isLoggedIn()).thenReturn(true);
          when(mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => testAuthResponse);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having(
            (state) => state.authData.user.email,
            'user email',
            'test@example.com',
          ),
        ],
        verify: (_) {
          verify(mockAuthRepository.isLoggedIn()).called(1);
          verify(mockAuthRepository.getCurrentUser()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when user is not logged in',
        build: () {
          when(mockAuthRepository.isLoggedIn()).thenReturn(false);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ],
        verify: (_) {
          verify(mockAuthRepository.isLoggedIn()).called(1);
          verifyNever(mockAuthRepository.getCurrentUser());
        },
      );
    });
  });
} 