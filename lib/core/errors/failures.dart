import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message})
      : super(message: message);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message})
      : super(message: message);
}

class LocationFailure extends Failure {
  const LocationFailure({required String message})
      : super(message: message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
} 