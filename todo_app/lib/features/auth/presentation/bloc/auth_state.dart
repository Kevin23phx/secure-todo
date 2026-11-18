part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState { const AuthInitial(); }
final class AuthLoading extends AuthState { const AuthLoading(); }
final class Authenticated extends AuthState {
  const Authenticated(this.user);
  final User user;
  @override
  List<Object?> get props => [user];
}
final class Unauthenticated extends AuthState {
  const Unauthenticated({this.failure});
  final Failure? failure;
  @override
  List<Object?> get props => [failure];
}
