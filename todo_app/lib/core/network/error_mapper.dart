import 'package:dio/dio.dart';

import '../error/failure.dart';
import '../result/result.dart';

Future<Result<T>> guard<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on DioException catch (error) {
    return Err(mapDioException(error));
  } catch (_) {
    return const Err(ServerFailure());
  }
}

Failure mapDioException(DioException exception) {
  final response = exception.response;
  if (response == null) return const NetworkFailure();
  final body = response.data;
  final error = body is Map<String, dynamic> ? body['error'] : null;
  final message = error is Map<String, dynamic> ? error['message'] as String? : null;

  switch (response.statusCode) {
    case 401:
      return UnauthorizedFailure(message ?? 'Please sign in again.');
    case 422:
      final details = error is Map<String, dynamic> ? error['details'] : null;
      return ValidationFailure(
        message ?? 'Invalid data.',
        fieldErrors: _firstErrorPerField(details),
      );
    default:
      return message == null ? const ServerFailure() : ServerFailure(message);
  }
}

Map<String, String> _firstErrorPerField(Object? details) {
  if (details is! Map<String, dynamic>) return const {};
  return {
    for (final MapEntry(:key, :value) in details.entries)
      if (value is List && value.isNotEmpty) key: value.first.toString(),
  };
}
