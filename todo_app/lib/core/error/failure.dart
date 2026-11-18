import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Cannot reach the server. Check your connection.']);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Please sign in again.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.fieldErrors = const {}});
  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong. Try again.']);
}
