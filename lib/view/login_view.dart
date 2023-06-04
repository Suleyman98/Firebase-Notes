import 'package:flutter/material.dart';
import 'package:flutter_bloc/constants/routes.dart';
import '../services/auth/auth_exceptions.dart';
import '../services/auth/auth_service.dart';
import '../utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _password.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          TextField(
            decoration:
                const InputDecoration(hintText: 'Enter your email address'),
            controller: _email,
          ),
          TextField(
            decoration: const InputDecoration(hintText: 'Enter your password'),
            controller: _password,
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;

              try {
                await AuthService.firebase()
                    .logIn(email: email, password: password);
                final user = AuthService.firebase().currentUser;
                if (user?.isEmailVerified ?? false) {
                  // ignore: use_build_context_synchronously
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    notesRoute,
                    (route) => false,
                  );
                } else {
                  // ignore: use_build_context_synchronously
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    verifyRoute,
                    (route) => false,
                  );
                }
              } on WrongPasswordAuthException {
                await showErrorDialog(context, 'Password is incorrect');
              } on UserNotFoundAuthException {
                await showErrorDialog(context, 'User Not Found');
              } on InvalidEmailAuthException {
                await showErrorDialog(context, 'Email address is invalid');
              } on GenericAuthException {
                await showErrorDialog(context, 'Authentication failed');
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text('Not registered yet?  Register now!'))
        ],
      ),
    );
  }
}
