import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Failure related to server/network issues
class ServerFailure extends Failure {
  const ServerFailure(String message, [int? code]) : super(message, code);
}

/// Failure related to network connectivity
class NetworkFailure extends Failure {
  const NetworkFailure(String message, [int? code]) : super(message, code);
}

/// Failure related to database operations
class DatabaseFailure extends Failure {
  const DatabaseFailure(String message, [int? code]) : super(message, code);
}

/// Failure related to cache operations
class CacheFailure extends Failure {
  const CacheFailure(String message, [int? code]) : super(message, code);
}

/// Failure related to validation
class ValidationFailure extends Failure {
  const ValidationFailure(String message, [int? code]) : super(message, code);
}

/// Failure related to authentication
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message, [int? code]) : super(message, code);
}

/// Failure related to authorization
class AuthorizationFailure extends Failure {
  const AuthorizationFailure(String message, [int? code]) : super(message, code);
}

/// Failure related to parsing operations
class ParsingFailure extends Failure {
  const ParsingFailure(String message, [int? code]) : super(message, code);
}

/// Generic failure for unknown errors
class UnknownFailure extends Failure {
  const UnknownFailure(String message, [int? code]) : super(message, code);
}