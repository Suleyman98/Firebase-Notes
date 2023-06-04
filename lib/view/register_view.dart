import 'package:flutter/material.dart';
import 'package:flutter_bloc/constants/routes.dart';
import 'package:flutter_bloc/services/auth/auth_exceptions.dart';

import '../services/auth/auth_service.dart';
import '../utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Register View')),
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
                    .createUser(email: email, password: password);
                AuthService.firebase().sendEmailVerification();

                // ignore: use_build_context_synchronously
                Navigator.pushNamed(context, verifyRoute);
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(context, 'Email already in use');
              } on WeakPasswordAuthException {
                await showErrorDialog(context, 'Weak password entered');
              } on InvalidEmailAuthException {
                await showErrorDialog(context, 'Email is invalid');
              } on GenericAuthException {
                await showErrorDialog(context, 'Authentication failed');
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text('Already registered?  Login now!'))
        ],
      ),
    );
  }
}
