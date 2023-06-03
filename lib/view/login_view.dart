import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/constants/routes.dart';
import 'package:flutter_bloc/view/register_view.dart';

import '../firebase_options.dart';

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
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email, password: password);

                // ignore: use_build_context_synchronously
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  notesRoute,
                  (route) => false,
                );
              } on FirebaseAuthException catch (e) {
                if (e.code == 'wrong-password') {
                  print('Password is wrong');
                } else if (e.code == 'user-not-found') {
                  print('User not found');
                } else if (e.code == 'invalid-email') {
                  print('Email address is invalid');
                }
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
