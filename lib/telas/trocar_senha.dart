import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Trocar Senha'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const TextField(
              obscureText: true, // Para esconder a senha digitada
              decoration: InputDecoration(
                labelText: 'Senha Atual',
              ),
            ),
            // ignore: prefer_const_constructors
            SizedBox(height: 16.0),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nova Senha',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar Nova Senha',
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Coloque aqui a lógica para trocar a senha
                // Pode ser chamada uma função ou um serviço para realizar a troca de senha
              },
              child: const Text('Trocar Senha'),
            ),
          ],
        ),
      ),
    );
  }
}
