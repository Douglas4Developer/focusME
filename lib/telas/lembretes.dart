import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
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

      // Schedule the notification
      _scheduleNotification(titulo, descricao, _selectedDateTime!);

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Preencha todos os campos e selecione uma data e hora.'),
        ),
      );
    }
  }

  // Schedule a notification using Firebase Messaging
  void _scheduleNotification(
      String titulo, String descricao, DateTime dateTime) async {
    // Define a unique identifier for this notification
    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Create a notification message
    final notification = RemoteNotification(
      title: 'Novo lembrete',
      body: 'Você tem um novo lembrete: $titulo',
    );

    // Create a data message
    final data = <String, dynamic>{
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': notificationId.toString(),
      'status': 'done',
    };

    // Create the message
    final message = RemoteMessage(
      data: data,
      notification: notification,
      messageId: notificationId.toString(),
    );

    // // Schedule the notification using Firebase Cloud Messaging
    // await _firebaseMessaging.scheduleLocalNotification(message, const LocalNotificationSchedule(
    //   id: notificationId,
    //   title: 'Novo lembrete',
    //   body: 'Você tem um novo lembrete: $titulo',
    //   ticker: 'ticker',
    //   tag: 'tag',
    //   scheduledDate: dateTime,
    //   payload: notificationId.toString(),
    // ));

    debugPrint('Notificação agendada para $dateTime');
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
          ],
        ),
      ),
    );
  }
}
