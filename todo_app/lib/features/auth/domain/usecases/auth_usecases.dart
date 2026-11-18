import '../../../../core/result/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  const LoginUser(this._repository);
  final AuthRepository _repository;
  Future<Result<User>> call({required String email, required String password}) =>
      _repository.login(email: email.trim(), password: password);
}

class RegisterUser {
  const RegisterUser(this._repository);
  final AuthRepository _repository;
  Future<Result<User>> call({required String name, required String email, required String password}) =>
      _repository.register(name: name.trim(), email: email.trim(), password: password);
}

class GetCurrentUser {
  const GetCurrentUser(this._repository);
  final AuthRepository _repository;
  Future<Result<User>> call() => _repository.currentUser();
}

class LogoutUser {
  const LogoutUser(this._repository);
  final AuthRepository _repository;
  Future<void> call() => _repository.logout();
}
