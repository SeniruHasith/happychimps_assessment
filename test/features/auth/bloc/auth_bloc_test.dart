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

  final testUser = UserModel(
    id: 1,
    email: 'test@example.com',
    name: 'Test User',
    avatarUrl: 'https://example.com/avatar.jpg',
    accessToken: 'test_token',
    refreshToken: 'test_refresh_token',
  );

  group('LoginEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login is successful',
      build: () {
        when(mockAuthRepository.login(
          'test@example.com',
          'password123',
        )).thenAnswer((_) async => testUser);
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
        isA<AuthAuthenticated>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.login(
          'test@example.com',
          'password123',
        )).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(mockAuthRepository.login(
          'test@example.com',
          'wrong_password',
        )).thenThrow(
          const AuthenticationFailure(
            message: 'Invalid credentials',
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
        isA<AuthError>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.login(
          'test@example.com',
          'wrong_password',
        )).called(1);
      },
    );
  });

  group('LogoutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when logout is successful',
      build: () {
        when(mockAuthRepository.logout())
            .thenAnswer((_) async => Future<void>.value());
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.logout()).called(1);
      },
    );
  });

  group('CheckAuthStatusEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when user is logged in',
      build: () {
        when(mockAuthRepository.isLoggedIn()).thenReturn(true);
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
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
} 