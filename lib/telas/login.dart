import 'package:flutter/material.dart';
import 'package:tdah_app/services/services.dart';
import 'package:tdah_app/telas/HomeScreen.dart';
import 'package:tdah_app/telas/resgister_page.dart'; // Importe a tela de registro se já a tiver

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String email = "";
    String password = "";
    AuthManager _authService = AuthManager();

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(size: 80),
                const SizedBox(height: 20),
                Text(
                  'Bem-vindo de volta!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                  onChanged: (value) {
                    email = value;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  labelText: 'Senha',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_isValidCredentials(email, password)) {
                      if (_isValidCredentials == true) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Credenciais inválidas')),
                        );
                      }
                    }
                  },
                  child: const Text('Entrar'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Navegue para a tela de registro
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistroPage()),
                    );
                  },
                  child: Text(
                    'Não tem uma conta? Registre-se aqui.',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required IconData prefixIcon,
    required ValueChanged<String> onChanged,
    bool obscureText = false,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
      ),
      onChanged: onChanged,
      obscureText: obscureText,
    );
  }

  bool _isValidCredentials(String email, String password) {
    // Aqui você pode implementar suas próprias validações
    // Por exemplo, verificar se o email e a senha são válidos

    // Por exemplo:
    return email == 'douglas' && password == '1';
  }
}
