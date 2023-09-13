import 'package:flutter/material.dart';

import 'package:tdah_app/telas/SplashScreen.dart';

class HomeAppTDAH extends StatelessWidget {
  const HomeAppTDAH({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}
