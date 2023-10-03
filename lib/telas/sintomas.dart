import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tdah_app/models/sintomas_models.dart';
import 'package:timezone/timezone.dart' as tz;

class SintomaScreen extends StatefulWidget {
  @override
  _SintomaScreenState createState() => _SintomaScreenState();
}

class _SintomaScreenState extends State<SintomaScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  DateTime? _selectedDateTime;
  List<Sintoma> _sintomas = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSintomas();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        const InitializationSettings(android: initializationSettingsAndroid);
    _notificationsPlugin.initialize(initializationSettings);
  }

  void _clearForm() {
    _nameController.clear();
    _descricaoController.clear();
    _selectedDateTime = null;
  }

  Future<void> _addSintoma() async {
    final user = _auth.currentUser;
    if (user != null) {
      final sintoma = Sintoma(
        name: _nameController.text,
        descricao: _descricaoController.text,
        dateTime: _selectedDateTime ?? DateTime.now(),
      );

      await _firestore.collection('sintomas').add({
        'nome': sintoma.name,
        'descricao': sintoma.descricao,
        'dateTime': sintoma.dateTime,
        'userId': user.uid,
      });

      _scheduleNotification(sintoma);

      _clearForm();
      _loadSintomas();
    }
  }

  Future<void> _loadSintomas() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('sintomas')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        _sintomas = snapshot.docs
            .map((doc) => Sintoma(
                  name: doc['nome'],
                  descricao: doc['descricao'],
                  dateTime: (doc['dateTime'] as Timestamp).toDate(),
                ))
            .toList();
      });
    }
  }

  Future<void> _scheduleNotification(Sintoma sintoma) async {
    final androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'sintoma_channel',
      'Sintomas',
      //   'Notification for scheduled sintomas',
      importance: Importance.high,
      priority: Priority.high,
    );
    final platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.zonedSchedule(
      sintoma.hashCode,
      'Sintoma Reminder',
      'Recorded sintoma: ${sintoma.name}, Description: ${sintoma.descricao}',
      tz.TZDateTime.from(sintoma.dateTime, tz.local),
      platformChannelSpecifics,
      // androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _showDateTimePicker() async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null) {
      final TimeOfDay pickedTime = (await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      ))!;

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Sintomas'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Sintoma que está sentindo?'),
            ),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição:'),
            ),
            Row(
              children: [
                const Text('Agendar:'),
                TextButton(
                  onPressed: _showDateTimePicker,
                  child: Text(
                    _selectedDateTime == null
                        ? 'Selecione a data e hora:'
                        : _selectedDateTime.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addSintoma,
              child: const Text('Adicionar Sintoma'),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Sintomas registrados: ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _sintomas.length,
                itemBuilder: (context, index) {
                  final sintoma = _sintomas[index];
                  return ListTile(
                    title: Text(sintoma.name),
                    subtitle: Text('Descricao: ${sintoma.descricao}'),
                    trailing: Text(
                      sintoma.dateTime.toString(),
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
