import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tdah_app/models/lembretes_model.dart';

class CadastroLembreteScreen extends StatefulWidget {
  @override
  _CadastroLembreteScreenState createState() => _CadastroLembreteScreenState();
}

class _CadastroLembreteScreenState extends State<CadastroLembreteScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
//
  }

  // Restante do código permanece o mesmo

  Future<void> _showDatePicker() async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay picked = (await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ))!;

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveLembrete() async {
    if (_tituloController.text.isNotEmpty &&
        _selectedDate != null &&
        _selectedTime != null) {
      final lembrete = LembreteNotification(
        titulo: _tituloController.text,
        descricao: _descricaoController.text,
        // dataHora: DateTime(
        //   _selectedDate!.year,
        //   _selectedDate!.month,
        //   _selectedDate!.day,
        //   _selectedTime!.hour,
        //   _selectedTime!.minute,
        // ),
      );

      // Lógica para salvar o lembrete no banco de dados ou onde preferir

      // Enviar notificação push
      final message = {
        'notification': {
          'title': 'Novo lembrete',
          'body': 'Você tem um novo lembrete: ${lembrete.titulo}',
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
        },
        'to': '/topics/lembretes', // Tópico de notificação
      };

      await _firebaseMessaging.sendMessage();

      debugPrint('Notificação enviada');

      // Restante da lógica de salvamento do lembrete
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Lembrete'),
        backgroundColor: Colors.blue, // Cor de fundo da AppBar
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
              'Data:',
              style: TextStyle(fontSize: 18.0),
            ),
            _selectedDate != null
                ? Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    style: const TextStyle(fontSize: 18.0),
                  )
                : const Text(
                    'Selecione uma data',
                    style: TextStyle(fontSize: 18.0),
                  ),
            ElevatedButton(
              onPressed: _showDatePicker,
              child: const Text('Selecionar Data'),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Hora:',
              style: TextStyle(fontSize: 18.0),
            ),
            _selectedTime != null
                ? Text(
                    _selectedTime!.format(context),
                    style: const TextStyle(fontSize: 18.0),
                  )
                : const Text(
                    'Selecione uma hora',
                    style: TextStyle(fontSize: 18.0),
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
          ],
        ),
      ),
    );
  }
}
