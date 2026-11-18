import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/app_bloc_observer.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  Bloc.observer = const AppBlocObserver();
  runApp(
    BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>()..add(const AuthStarted()),
      child: const TodoApp(),
    ),
  );
}
