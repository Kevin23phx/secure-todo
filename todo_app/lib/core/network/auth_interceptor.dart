import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

/// Adds access tokens, refreshes expired sessions once, and replays requests.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.plainDio,
    required this.onSessionExpired,
  });

  final TokenStorage tokenStorage;
  final Dio plainDio;
  final void Function() onSessionExpired;
  static const _publicPaths = ['/auth/login', '/auth/register', '/auth/refresh'];

  bool _isPublic(RequestOptions options) => _publicPaths.any(options.path.endsWith);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_isPublic(options)) {
      final token = await tokenStorage.readAccessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 || _isPublic(request)) {
      return handler.next(err);
    }

    try {
      final sentHeader = request.headers['Authorization'];
      var token = await tokenStorage.readAccessToken();
      if (token == null || sentHeader == 'Bearer $token') token = await _refreshTokens();
      request.headers['Authorization'] = 'Bearer $token';
      final response = await plainDio.fetch<dynamic>(request);
      return handler.resolve(response);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await tokenStorage.clear();
        onSessionExpired();
      }
      return handler.next(error);
    }
  }

  Future<String> _refreshTokens() async {
    final refreshToken = await tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          statusCode: 401,
        ),
      );
    }
    final response = await plainDio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    await tokenStorage.save(
      accessToken: accessToken,
      refreshToken: data['refreshToken'] as String,
    );
    return accessToken;
  }
}
