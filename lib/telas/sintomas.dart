import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tdah_app/models/sintomas_models.dart';
import 'package:timezone/timezone.dart' as tz;

class SymptomScreen extends StatefulWidget {
  @override
  _SymptomScreenState createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;
  List<Symptom> _symptoms = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSymptoms();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _notificationsPlugin.initialize(initializationSettings);
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _selectedDateTime = null;
  }

  Future<void> _addSymptom() async {
    final user = _auth.currentUser;
    if (user != null) {
      final symptom = Symptom(
        name: _nameController.text,
        description: _descriptionController.text,
        dateTime: _selectedDateTime ?? DateTime.now(),
      );

      await _firestore.collection('symptoms').add({
        'name': symptom.name,
        'description': symptom.description,
        'dateTime': symptom.dateTime,
        'userId': user.uid,
      });

      _scheduleNotification(symptom);

      _clearForm();
      _loadSymptoms();
    }
  }

  Future<void> _loadSymptoms() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('symptoms')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        _symptoms = snapshot.docs
            .map((doc) => Symptom(
                  name: doc['name'],
                  description: doc['description'],
                  dateTime: (doc['dateTime'] as Timestamp).toDate(),
                ))
            .toList();
      });
    }
  }

  Future<void> _scheduleNotification(Symptom symptom) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'symptom_channel',
      'Symptoms',
      //   'Notification for scheduled symptoms',
      importance: Importance.high,
      priority: Priority.high,
    );
    final platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.zonedSchedule(
      symptom.hashCode,
      'Symptom Reminder',
      'Recorded symptom: ${symptom.name}, Description: ${symptom.description}',
      tz.TZDateTime.from(symptom.dateTime, tz.local),
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
        title: Text('Symptom Tracker'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Symptom Name'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            Row(
              children: [
                Text('Schedule:'),
                TextButton(
                  onPressed: _showDateTimePicker,
                  child: Text(
                    _selectedDateTime == null
                        ? 'Select Date and Time'
                        : _selectedDateTime.toString(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addSymptom,
              child: Text('Add Symptom'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Symptoms Recorded:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _symptoms.length,
                itemBuilder: (context, index) {
                  final symptom = _symptoms[index];
                  return ListTile(
                    title: Text(symptom.name),
                    subtitle: Text('Description: ${symptom.description}'),
                    trailing: Text(
                      symptom.dateTime.toString(),
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
