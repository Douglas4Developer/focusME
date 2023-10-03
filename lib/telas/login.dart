import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tdah_app/telas/HomeScreen.dart';
import 'package:tdah_app/telas/resgister_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late FirebaseMessaging _firebaseMessaging;

  bool _isLoading = false;
  bool _obscurePassword =
      true; // Variável para controlar a visibilidade da senha

  @override
  void initState() {
    super.initState();
    _firebaseMessaging = FirebaseMessaging.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Adicione um widget Image para exibir o logotipo
                Image.asset(
                  'assets/Logo.png',
                  width: 350,
                  height: 250,
                ), // Substitua pelo caminho do seu logotipo
                const SizedBox(height: 20),
                const Text(
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
                  controller: _emailController,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  labelText: 'Senha',
                  prefixIcon: Icons.lock,
                  obscureText:
                      _obscurePassword, // Use a variável para controlar a visibilidade
                  controller: _passwordController,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();

                          try {
                            final userCredential =
                                await _auth.signInWithEmailAndPassword(
                              email: email,
                              password: password,
                            );
                            if (userCredential.user != null) {
                              // Após o usuário ter feito login com sucesso,
                              // agora podemos obter o token FCM
                              _getFCMToken();

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Credenciais inválidas'),
                              ),
                            );
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        child: const Text('Entrar'),
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistroPage(),
                      ),
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
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon, // Adicione um campo para o ícone de sufixo
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon, // Use o ícone de sufixo fornecido
      ),
      obscureText: obscureText,
    );
  }

  void _getFCMToken() {
    _firebaseMessaging.getToken().then((String? token) {
      if (token != null) {
        print("Token FCM: $token");
        // Aqui você pode enviar o token FCM para o seu servidor ou realizar outras ações
      } else {
        // Não foi possível obter o token FCM.
      }
    });
  }
}
