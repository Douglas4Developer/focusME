import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tdah_app/telas/HomeScreen.dart';
import 'package:tdah_app/telas/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _navigateToMainScreen();
  }

  void _navigateToMainScreen() async {
    // Aguarde alguns segundos para simular o tempo da tela de splash
    await Future.delayed(const Duration(seconds: 3));

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      // O usuário já está logado, vá para a tela principal
      // ignore: use_build_context_synchronously
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // O usuário não está logado, vá para a tela de login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Logo.png', // Substitua pelo caminho da sua imagem
              width: 100.0,
              height: 100.0,
            ),
            const SizedBox(height: 20.0),
            const Text(
              "Gestor de Concentração Pessoal",
              style: TextStyle(
                fontSize: 24.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
