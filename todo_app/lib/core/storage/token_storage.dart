import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage contract keeps the rest of the app independent of the platform.
abstract interface class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> save({required String accessToken, required String refreshToken});
  Future<void> clear();
}

/// Persists credentials in Android Keystore / iOS Keychain via the plugin.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);
  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessKey);
  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);
  @override
  Future<void> save({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }
  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
