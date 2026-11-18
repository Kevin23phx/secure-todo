import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

Dio _baseDio() => Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));

Dio createDio({required TokenStorage tokenStorage, required void Function() onSessionExpired}) {
  final dio = _baseDio();
  dio.interceptors.add(AuthInterceptor(
    tokenStorage: tokenStorage,
    plainDio: _baseDio(),
    onSessionExpired: onSessionExpired,
  ));
  if (kDebugMode) dio.interceptors.add(LogInterceptor(requestHeader: false));
  return dio;
}
