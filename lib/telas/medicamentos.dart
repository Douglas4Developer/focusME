import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:tdah_app/models/medicamentos_model.dart';
import 'package:timezone/timezone.dart' as tz;

class MedicacaoScreen extends StatefulWidget {
  const MedicacaoScreen({Key? key}) : super(key: key);

  @override
  _MedicacaoScreenState createState() => _MedicacaoScreenState();
}

class _MedicacaoScreenState extends State<MedicacaoScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosagemController = TextEditingController();
  DateTime? _selectedDateTime;
  List<Medicacao> _medicacoes = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadMedicacoes();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _notificationsPlugin.initialize(initializationSettings);
  }

  void _clearForm() {
    _nameController.clear();
    _dosagemController.clear();
    _selectedDateTime = null;
  }

  Future<void> _addMedicacao() async {
    final user = _auth.currentUser;
    if (user != null) {
      final tz.TZDateTime scheduledDateTime =
          tz.TZDateTime.from(_selectedDateTime!, tz.local);

      final medication = Medicacao(
        name: _nameController.text,
        dosagem: _dosagemController.text,
        dateTime: scheduledDateTime,
      );

      try {
        await _firestore.collection('medicacoes').add({
          'name': medication.name,
          'dosagem': medication.dosagem,
          'dateTime': scheduledDateTime.toUtc(), // Store as UTC in Firestore
          'userId': user.uid,
        });

        _scheduleNotification(medication);

        _clearForm();
        _loadMedicacoes();
      } catch (e) {
        print('Error adding medication: $e');
        // Handle the error gracefully, show a snackbar, or perform other error handling.
      }
    }
  }

  Future<void> _loadMedicacoes() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('medicacoes')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        _medicacoes = snapshot.docs
            .map((doc) => Medicacao(
                  name: doc['name'],
                  dosagem: doc['dosagem'],
                  dateTime: (doc['dateTime'] as Timestamp).toDate(),
                ))
            .toList();
      });
    }
  }

  Future<void> _scheduleNotification(Medicacao medication) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medication_channel',
      'Medicacoes',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.zonedSchedule(
      medication.hashCode,
      'Medicacao Reminder',
      'Take ${medication.name}, Dosage: ${medication.dosagem}',
      tz.TZDateTime.from(medication.dateTime, tz.local),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Widget _buildMedicacaoList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _medicacoes.length,
        itemBuilder: (context, index) {
          final medication = _medicacoes[index];
          return ListTile(
            title: Text(medication.name),
            subtitle: Text('Dosage: ${medication.dosagem}'),
            trailing: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(medication.dateTime),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDateTimePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

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
        backgroundColor: Colors.blue,
        title: const Text('Medicacao Rastreador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome da Medicação'),
            ),
            TextFormField(
              controller: _dosagemController,
              decoration: const InputDecoration(labelText: 'Dosagem'),
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
              onPressed: _addMedicacao,
              child: const Text('Adicionar Medicacao'),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Medicações Agendadas:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            _buildMedicacaoList(),
          ],
        ),
      ),
    );
  }
}
