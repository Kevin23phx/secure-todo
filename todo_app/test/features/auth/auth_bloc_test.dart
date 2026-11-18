import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/core/error/failure.dart';
import 'package:todo_app/core/result/result.dart';
import 'package:todo_app/features/auth/domain/entities/user.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:todo_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:todo_app/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  const ada = User(id: 'u1', name: 'Ada', email: 'ada@example.com');

  AuthBloc buildBloc() => AuthBloc(
        loginUser: LoginUser(repository),
        registerUser: RegisterUser(repository),
        getCurrentUser: GetCurrentUser(repository),
        logoutUser: LogoutUser(repository),
      );

  setUp(() => repository = MockAuthRepository());

  blocTest<AuthBloc, AuthState>(
    'restores a saved session at startup',
    setUp: () => when(() => repository.currentUser()).thenAnswer((_) async => const Ok(ada)),
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [const Authenticated(ada)],
  );

  blocTest<AuthBloc, AuthState>(
    'starts unauthenticated when no saved session exists',
    setUp: () => when(() => repository.currentUser()).thenAnswer((_) async => const Err(UnauthorizedFailure())),
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [const Unauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'login emits loading then authenticated and trims email',
    setUp: () => when(() => repository.login(email: 'ada@example.com', password: 'secret123')).thenAnswer((_) async => const Ok(ada)),
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthLoginRequested(email: ' ada@example.com ', password: 'secret123')),
    expect: () => [const AuthLoading(), const Authenticated(ada)],
  );

  blocTest<AuthBloc, AuthState>(
    'login failure is exposed as an unauthenticated state',
    setUp: () => when(() => repository.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => const Err(UnauthorizedFailure('Invalid email or password'))),
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthLoginRequested(email: 'ada@example.com', password: 'nope')),
    expect: () => [const AuthLoading(), const Unauthenticated(failure: UnauthorizedFailure('Invalid email or password'))],
  );

  blocTest<AuthBloc, AuthState>(
    'register validation errors are preserved for the form',
    setUp: () => when(() => repository.register(name: any(named: 'name'), email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => const Err(ValidationFailure('Invalid data', fieldErrors: {'email': 'Invalid email'}))),
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthRegisterRequested(name: 'Ada', email: 'bad', password: 'secret123')),
    expect: () => [const AuthLoading(), const Unauthenticated(failure: ValidationFailure('Invalid data', fieldErrors: {'email': 'Invalid email'}))],
  );

  blocTest<AuthBloc, AuthState>(
    'logout clears the local session',
    setUp: () => when(() => repository.logout()).thenAnswer((_) async {}),
    build: buildBloc,
    seed: () => const Authenticated(ada),
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => [const Unauthenticated()],
    verify: (_) => verify(() => repository.logout()).called(1),
  );

  blocTest<AuthBloc, AuthState>(
    'session expiry signs out and carries a message',
    build: buildBloc,
    seed: () => const Authenticated(ada),
    act: (bloc) => bloc.add(const AuthSessionExpired()),
    expect: () => [const Unauthenticated(failure: UnauthorizedFailure('Your session expired. Sign in again.'))],
  );
}
