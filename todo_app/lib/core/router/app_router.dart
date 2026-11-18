import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/todos/presentation/bloc/todo_bloc.dart';
import '../../features/todos/presentation/pages/todos_page.dart';
import '../di/injection.dart';

GoRouter createRouter(AuthBloc authBloc) => GoRouter(
      initialLocation: '/splash',
      refreshListenable: _StreamListenable(authBloc.stream),
      redirect: (context, state) {
        final location = state.matchedLocation;
        final onAuthPage = location == '/login' || location == '/register';
        return switch (authBloc.state) {
          AuthInitial() => '/splash',
          Authenticated() when onAuthPage || location == '/splash' => '/todos',
          Unauthenticated() when !onAuthPage => '/login',
          _ => null,
        };
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, _) => const Scaffold(body: Center(child: CircularProgressIndicator()))),
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
        GoRoute(
          path: '/todos',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<TodoBloc>()..add(const TodosRequested()),
            child: const TodosPage(),
          ),
        ),
      ],
    );

class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<Object?> _subscription;
  @override
  void dispose() { _subscription.cancel(); super.dispose(); }
}
