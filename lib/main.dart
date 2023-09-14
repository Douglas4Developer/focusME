import 'package:flutter/material.dart';
import 'package:tdah_app/telas/Home.dart'; // Importar o pacote de gráficos
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HomeAppTDAH());
}
