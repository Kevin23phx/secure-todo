import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.loginUser, required this.registerUser, required this.getCurrentUser, required this.logoutUser})
      : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionExpired>((event, emit) => emit(const Unauthenticated(failure: UnauthorizedFailure('Your session expired. Sign in again.'))));
  }

  final LoginUser loginUser;
  final RegisterUser registerUser;
  final GetCurrentUser getCurrentUser;
  final LogoutUser logoutUser;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final result = await getCurrentUser();
    emit(switch (result) {
      Ok(:final value) => Authenticated(value),
      Err() => const Unauthenticated(),
    });
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    emit(_toState(await loginUser(email: event.email, password: event.password)));
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    emit(_toState(await registerUser(name: event.name, email: event.email, password: event.password)));
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await logoutUser();
    emit(const Unauthenticated());
  }

  AuthState _toState(Result<User> result) => switch (result) {
        Ok(:final value) => Authenticated(value),
        Err(:final failure) => Unauthenticated(failure: failure),
      };
}
