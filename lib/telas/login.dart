// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tdah_app/telas/Auth.dart';
import 'package:tdah_app/telas/HomeScreen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String email = "";
    String password = "";
    final AuthManager _authManager = AuthManager();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(size: 80),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                ),
                onChanged: (value) {
                  password = value;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_isValidCredentials(email, password)) {
                    final user = await _authManager.signInWithEmailAndPassword(
                        email, password);
                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Credenciais inválidas')),
                      );
                    }
                  }
                },
                child: const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValidCredentials(String email, String password) {
    // Aqui você pode implementar suas próprias validações
    // Por exemplo, verificar se o email e a senha são válidos

    //por exemplo
    return email == 'douglas' && password == '1';
  }
}
