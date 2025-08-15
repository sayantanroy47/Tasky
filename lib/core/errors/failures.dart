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
  const ServerFailure(super.message, [super.code]);
}

/// Failure related to network connectivity
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// Failure related to database operations
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.code]);
}

/// Failure related to cache operations
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

/// Failure related to validation
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}

/// Failure related to authentication
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, [super.code]);
}

/// Failure related to authorization
class AuthorizationFailure extends Failure {
  const AuthorizationFailure(super.message, [super.code]);
}

/// Failure related to parsing operations
class ParsingFailure extends Failure {
  const ParsingFailure(super.message, [super.code]);
}

/// Generic failure for unknown errors
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.code]);
}