import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tdah_app/models/lembretes_model.dart';

class CadastroLembreteScreen extends StatefulWidget {
  @override
  _CadastroLembreteScreenState createState() => _CadastroLembreteScreenState();
}

class _CadastroLembreteScreenState extends State<CadastroLembreteScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  DateTime? _selectedDateTime;

  // Initialize Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista de lembretes
  List<Lembrete> _lembretes = [];

  @override
  void initState() {
    super.initState();
    // Carregue os lembretes quando o componente for inicializado
    _loadLembretes();
  }

  Future<void> _showDatePicker() async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != _selectedDateTime) {
      setState(() {
        _selectedDateTime = picked;
      });
    }
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay picked = (await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ))!;

    if (picked != null && _selectedDateTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime!.year,
          _selectedDateTime!.month,
          _selectedDateTime!.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveLembrete() async {
    final titulo = _tituloController.text;
    final descricao = _descricaoController.text;

    if (titulo.isNotEmpty && _selectedDateTime != null) {
      // Create a Firestore document for the reminder
      await _firestore.collection('lembretes').add({
        'titulo': titulo,
        'descricao': descricao,
        'dateTime': _selectedDateTime, // Save the selected date and time
      });

      // Clear the form
      _tituloController.clear();
      _descricaoController.clear();
      setState(() {
        _selectedDateTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lembrete salvo com sucesso!'),
        ),
      );

      // Atualiza a lista de lembretes
      _loadLembretes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Preencha todos os campos e selecione uma data e hora.'),
        ),
      );
    }
  }

  Future<void> _loadLembretes() async {
    final snapshots = await _firestore.collection('lembretes').get();

    setState(() {
      _lembretes = snapshots.docs.map((doc) {
        final data = doc.data();
        return Lembrete(
          titulo: data['titulo'] ?? '',
          descricao: data['descricao'] ?? '',
          dateTime: (data['dateTime'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Lembrete'),
        backgroundColor: Colors.blue, // AppBar background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Título:',
              style: TextStyle(fontSize: 18.0),
            ),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                hintText: 'Digite o título do lembrete',
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Descrição:',
              style: TextStyle(fontSize: 18.0),
            ),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                hintText: 'Digite a descrição do lembrete',
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Data e Hora:',
              style: TextStyle(fontSize: 18.0),
            ),
            _selectedDateTime != null
                ? Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime!),
                    style: const TextStyle(fontSize: 18.0),
                  )
                : const Text(
                    'Selecione uma data e hora',
                    style: TextStyle(fontSize: 18.0),
                  ),
            ElevatedButton(
              onPressed: _showDatePicker,
              child: const Text('Selecionar Data'),
            ),
            ElevatedButton(
              onPressed: _showTimePicker,
              child: const Text('Selecionar Hora'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveLembrete,
              child: const Text('Salvar Lembrete'),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Lista de Lembretes:',
              style: TextStyle(fontSize: 18.0),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _lembretes.length,
                itemBuilder: (context, index) {
                  final lembrete = _lembretes[index];
                  return ListTile(
                    title: Text(lembrete.titulo),
                    subtitle: Text(lembrete.descricao),
                    trailing: Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(lembrete.dateTime),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
