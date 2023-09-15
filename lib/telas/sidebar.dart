import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  const SideBar({Key? key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Container(
        color: Colors.white, // Cor de fundo branca
        child: ListView(
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user?.photoURL ?? ''),
                      radius: 40.0,
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      user?.displayName ?? 'Nome do Usuário',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? 'Email do Usuário',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () {
                // Implemente a navegação para a tela inicial
              },
            ),
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('O que fazer hoje?'),
              onTap: () {
                // Implemente a navegação para a tela "O que fazer hoje?"
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Lembrar de algo?'),
              onTap: () {
                // Implemente a navegação para a tela "Lembrar de algo?"
              },
            ),
            ListTile(
              leading: const Icon(Icons.sentiment_satisfied),
              title: const Text('Controlar meus sentimentos'),
              onTap: () {
                // Implemente a navegação para a tela "Controlar meus sentimentos"
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Cadastrar meus medicamentos'),
              onTap: () {
                // Implemente a navegação para a tela "Cadastrar meus medicamentos"
              },
            ),
            // Outras opções da barra lateral
          ],
        ),
      ),
    );
  }
}
