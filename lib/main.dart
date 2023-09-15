import 'package:flutter/material.dart';
// Importar o pacote de gráficos
import 'package:firebase_core/firebase_core.dart';
import 'package:tdah_app/telas/HomeScreen.dart';
import 'package:tdah_app/telas/SplashScreen.dart';
import 'package:tdah_app/telas/login.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TDAH App',
      initialRoute: '/', // Rota inicial
      routes: {
        '/': (context) => const SplashScreen(), // Tela de login
        '/home': (context) => const HomeScreen(), // Tela principal
        '/login': (context) => const LoginPage(), // Tela principal
      },
    );
  }
}
