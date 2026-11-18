import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthLoginRequested(email: _email.text, password: _password.text));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Sign in')),
        body: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (_, state) => state is Unauthenticated && state.failure != null,
          listener: (context, state) {
            final failure = (state as Unauthenticated).failure!;
            ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(failure.message)));
          },
          builder: (context, state) {
            final loading = state is AuthLoading;
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email], decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email'),
                  const SizedBox(height: 16),
                  TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password'), validator: (v) => v != null && v.isNotEmpty ? null : 'Enter your password', onFieldSubmitted: (_) => _submit()),
                  const SizedBox(height: 24),
                  FilledButton(onPressed: loading ? null : _submit, child: loading ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Sign in')),
                  TextButton(onPressed: loading ? null : () => context.go('/register'), child: const Text('No account yet? Create one')),
                ],
              ),
            );
          },
        ),
      );
}
