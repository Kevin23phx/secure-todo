import '../../../../core/error/failure.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._tokenStorage);
  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<Result<User>> login({required String email, required String password}) => guard(() async {
        final session = await _remote.login(email: email, password: password);
        return _persist(session);
      });

  @override
  Future<Result<User>> register({required String name, required String email, required String password}) => guard(() async {
        final session = await _remote.register(name: name, email: email, password: password);
        return _persist(session);
      });

  @override
  Future<Result<User>> currentUser() async {
    if (await _tokenStorage.readAccessToken() == null) return const Err(UnauthorizedFailure());
    return guard(_remote.me);
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    await _tokenStorage.clear(); // local sign-out works even without a network
    if (refreshToken != null) await guard(() => _remote.logout(refreshToken));
  }

  Future<User> _persist(AuthSession session) async {
    await _tokenStorage.save(accessToken: session.accessToken, refreshToken: session.refreshToken);
    return session.user;
  }
}
