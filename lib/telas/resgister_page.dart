import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tdah_app/services/services.dart';
import 'package:tdah_app/telas/HomeScreen.dart';
import 'package:tdah_app/telas/login.dart';
import 'package:image_picker/image_picker.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({Key? key}) : super(key: key);

  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _sexoController = TextEditingController();

  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  String _errorMessage = '';
  XFile? _selectedImage; // Variável para armazenar a imagem selecionada
  DateTime?
      _selectedDate; // Variável para armazenar a data de nascimento selecionada
  String? _selectedGender; // Variável para armazenar o gênero selecionado
  List<String> _genderOptions = ['Masculino', 'Feminino']; // Opções de gênero

  AuthManager _authService = AuthManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _pickImage(); // Ao tocar na imagem, abre a galeria
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 40,
                    backgroundImage: _selectedImage != null
                        ? FileImage(
                            File(_selectedImage!.path),
                          )
                        : null, // Exibe a imagem selecionada
                    child: _selectedImage == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.blue,
                          )
                        : null, // Ícone da câmera quando não há imagem
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Crie sua conta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  labelText: 'Nome',
                  prefixIcon: Icons.person,
                  controller: _nomeController,
                ),
                _buildTextField(
                  labelText: 'Idade',
                  prefixIcon: Icons.calendar_today,
                  readOnly: true,
                  onTap: () {
                    _selectDate(context);
                  },
                  controller: TextEditingController(
                    text: _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : '',
                  ),
                ),
                _buildTextField(
                  labelText: 'Gênero',
                  prefixIcon: Icons.person,
                  controller:
                      TextEditingController(text: _selectedGender ?? ''),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Selecione o Gênero'),
                          content: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedGender,
                            items: _genderOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGender = newValue;
                                Navigator.of(context)
                                    .pop(); // Feche o diálogo após a seleção
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                  controller: _emailController,
                ),
                const SizedBox(height: 10),
                _buildPasswordField(
                  labelText: 'Senha',
                  prefixIcon: Icons.lock,
                  controller: _senhaController,
                ),
                const SizedBox(height: 10),
                _buildPasswordField(
                  labelText: 'Confirmar Senha',
                  prefixIcon: Icons.lock,
                  controller: _confirmarSenhaController,
                ),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _registrarUsuario,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Registrar'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Navegue de volta para a tela de login
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Já tem uma conta? Faça login aqui.',
                    style: TextStyle(
                      color: Colors.white,
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
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: onTap != null
            ? IconButton(
                icon: Icon(
                  Icons.calendar_today,
                ),
                onPressed: onTap,
              )
            : null,
      ),
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
    );
  }

  Widget _buildPasswordField({
    required String labelText,
    required IconData prefixIcon,
    required TextEditingController controller,
  }) {
    bool _obscureText = true;
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      obscureText: _obscureText,
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final selectedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedImage = selectedImage;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _registrarUsuario() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final nome = _nomeController.text;
    final email = _emailController.text;
    final senha = _senhaController.text;
    final confirmarSenha = _confirmarSenhaController.text;
    final imageFile = _selectedImage;
    final idade = _calculateAge(_selectedDate);
    final sexo = _selectedGender;

    if (_isValidInput(nome, email, senha, confirmarSenha, idade, sexo)) {
      final success = await _authService.cadastrarUsuario(
        nome: nome,
        email: email,
        senha: senha,
        imagem: imageFile,
        idade: idade.toString(),
        sexo: sexo!,
      );

      setState(() {
        _isLoading = false;
        if (success != null) {
          _isSuccess = true;
        } else {
          _errorMessage = 'Erro ao registrar';
        }
      });

      if (success != null) {
        _showSuccessSnackBar();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Por favor, verifique os campos e tente novamente';
      });
    }
  }

  int? _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return null;
    final now = DateTime.now();
    final age = now.year -
        birthDate.year -
        ((now.month > birthDate.month ||
                (now.month == birthDate.month && now.day >= birthDate.day))
            ? 0
            : 1);
    return age;
  }

  bool _isValidInput(
    String nome,
    String email,
    String senha,
    String confirmarSenha,
    int? idade,
    String? sexo,
  ) {
    final emailPattern =
        RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

    return nome.isNotEmpty &&
        email.isNotEmpty &&
        senha.isNotEmpty &&
        senha.length >= 6 &&
        senha == confirmarSenha &&
        idade != null &&
        sexo != null &&
        emailPattern.hasMatch(email);
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registro bem-sucedido! Faça login agora.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
