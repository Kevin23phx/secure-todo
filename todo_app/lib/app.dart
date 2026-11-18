import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});
  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  late final _router = createRouter(context.read<AuthBloc>());

  @override
  void dispose() { _router.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Todo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFFD6336C), inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder())),
        routerConfig: _router,
      );
}
