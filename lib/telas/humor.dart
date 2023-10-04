import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tdah_app/models/humor_model.dart';
import 'package:intl/intl.dart';

class CadastroHumorScreen extends StatefulWidget {
  @override
  _CadastroHumorScreenState createState() => _CadastroHumorScreenState();
}

class _CadastroHumorScreenState extends State<CadastroHumorScreen> {
  String _selectedHumor = 'Feliz';
  double _selectedWeight = 1.0; // Peso inicial
  final TextEditingController _observacaoController = TextEditingController();
  final List<String> _humorOptions = [
    'Feliz',
    'Triste',
    'Preocupado',
    'Irritado',
    'Empolgado',
    'Ansioso',
  ];

  // Define um mapa de pesos para cada humor
  final Map<String, double> _humorWeights = {
    'Feliz': 1.0,
    'Triste': 0.1,
    'Preocupado': 0.5,
    'Irritado': 0.2,
    'Empolgado': 0.8,
    'Ansioso': 0.4,
  };

  // Lista de humores registrados
  List<HumorRegistro> _humorRegistros = [];

  @override
  void initState() {
    super.initState();
    _loadHumorRegistros();
  }

  Future<void> _loadHumorRegistros() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return; // Saia se o usuário não estiver autenticado
    }

    final uid = user.uid;

    // Carregue os humores registrados do Firebase Firestore para o UID do usuário
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('humores_registrados')
        .where('uid', isEqualTo: uid) // Filtrar por UID do usuário
        .get();

    setState(() {
      _humorRegistros = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return HumorRegistro(
          humor: data['humor'],
          data: data['data'].toDate(), // Converte Timestamp para DateTime
          observacao: data['observacao'],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cadastro de Humor',
          style: TextStyle(
            color: Colors.white, // Cor do texto na AppBar
          ),
        ),
        backgroundColor: Colors.blue, // Cor de fundo da AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecione seu humor:',
              style: TextStyle(fontSize: 18.0),
            ),
            _buildHumorDropdown(), // Função para criar o dropdown de humor
            const SizedBox(height: 20.0),
            const Text(
              'Peso do Humor:',
              style: TextStyle(fontSize: 18.0),
            ),
            _buildHumorWeightSlider(), // Função para criar o controle deslizante de peso
            const SizedBox(height: 20.0),
            const Text(
              'Observação (opcional):',
              style: TextStyle(fontSize: 18.0),
            ),
            TextFormField(
              controller: _observacaoController,
              maxLines: 3,
              decoration: InputDecoration(
                // Adicione uma borda e sombra ao campo de observação
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Descreva seu humor (opcional)',
              ),
            ),
            const SizedBox(height: 20.0),
            _buildSaveButton(), // Função para criar o botão "Salvar"
            const SizedBox(height: 20.0),
            const Text(
              'Histórico de Humores:',
              style: TextStyle(fontSize: 18.0),
            ),
            _buildHumorList(), // Função para criar a lista de humores cadastrados
          ],
        ),
      ),
    );
  }

  // Função para criar o controle deslizante de peso do humor
  Widget _buildHumorWeightSlider() {
    return Slider(
      value: _selectedWeight,
      onChanged: (double newValue) {
        setState(() {
          _selectedWeight = newValue;
        });
      },
      min: 0.1, // Valor mínimo de peso
      max: 1.0, // Valor máximo de peso
      divisions: 9, // Número de divisões entre min e max
      label: _selectedWeight.toStringAsFixed(1), // Exibe o valor selecionado
    );
  }

  // Função para criar o dropdown de humor
  Widget _buildHumorDropdown() {
    return DropdownButton<String>(
      value: _selectedHumor,
      onChanged: (String? newValue) {
        setState(() {
          _selectedHumor = newValue!;
        });
      },
      items: _humorOptions.map((String humor) {
        return DropdownMenuItem<String>(
          value: humor,
          child: Row(
            children: [
              _buildHumorIcon(humor), // Função para criar o ícone do humor
              const SizedBox(width: 8.0),
              Text(humor),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Função para criar o ícone do humor
  Widget _buildHumorIcon(String humor) {
    IconData iconData;
    switch (humor) {
      case 'Feliz':
        iconData = Icons.sentiment_satisfied;
        break;
      case 'Triste':
        iconData = Icons.sentiment_very_dissatisfied;
        break;
      case 'Preocupado':
        iconData = Icons.sentiment_neutral;
        break;
      case 'Irritado':
        iconData = Icons.sentiment_very_dissatisfied;
        break;
      case 'Empolgado':
        iconData = Icons.sentiment_very_satisfied;
        break;
      case 'Ansioso':
        iconData = Icons.sentiment_neutral;
        break;
      default:
        iconData = Icons.sentiment_satisfied;
    }
    return Icon(
      iconData,
      color: _selectedHumor == humor ? Colors.blue : Colors.grey,
    );
  }

  // Função para criar a lista de humores cadastrados

  Widget _buildHumorList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _humorRegistros.length,
        itemBuilder: (context, index) {
          final registro = _humorRegistros[index];
          return ListTile(
            leading: _buildHumorIcon(registro.humor),
            title: Text(registro.humor),
            subtitle: Text(
              'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(registro.data)}\n'
              'Observação: ${registro.observacao}',
            ),
          );
        },
      ),
    );
  }

  // Função para criar o botão "Salvar"
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        _saveHumor();
      },
      child: const Text('Salvar'),
    );
  }

  void _saveHumor() async {
    if (_selectedHumor.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return; // Saia se o usuário não estiver autenticado
      }

      final uid = user.uid;

      // Define a coleção no Firestore onde os humores serão armazenados
      final CollectionReference humoresRegistrados =
          FirebaseFirestore.instance.collection('humores_registrados');

      // Define os dados do humor a serem armazenados, incluindo o UID do usuário
      Map<String, dynamic> data = {
        'humor': _selectedHumor,
        'data': DateTime.now(), // Salva a data e hora atual
        'observacao': _observacaoController.text,
        'uid': uid, // Associe o registro ao UID do usuário
      };

      // Adiciona o registro de humor à coleção
      await humoresRegistrados.add(data);

      // Atualiza a lista de humores registrados
      await _loadHumorRegistros();

      // Exibe uma mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Humor registrado com sucesso!'),
        ),
      );

      // Limpa o campo de observação
      _observacaoController.clear();
    } else {
      // Se nenhum humor for selecionado, exibe uma mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um humor antes de salvar.'),
        ),
      );
    }
  }
}
