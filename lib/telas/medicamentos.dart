import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tdah_app/models/medicamentos_model.dart';
import 'package:timezone/timezone.dart' as tz;

class MedicationScreen extends StatefulWidget {
  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  DateTime? _selectedDateTime;
  List<Medication> _medications = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadMedications();
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
    _dosageController.clear();
    _selectedDateTime = null;
  }

  Future<void> _addMedication() async {
    final user = _auth.currentUser;
    if (user != null) {
      final tz.TZDateTime scheduledDateTime =
          tz.TZDateTime.from(_selectedDateTime!, tz.local);

      final medication = Medication(
        name: _nameController.text,
        dosage: _dosageController.text,
        dateTime: scheduledDateTime,
      );

      await _firestore.collection('medications').add({
        'name': medication.name,
        'dosage': medication.dosage,
        'dateTime': scheduledDateTime.toUtc(), // Store as UTC in Firestore
        'userId': user.uid,
      });

      _scheduleNotification(medication);

      _clearForm();
      _loadMedications();
    }
  }

  Future<void> _loadMedications() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('medications')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        _medications = snapshot.docs
            .map((doc) => Medication(
                  name: doc['name'],
                  dosage: doc['dosage'],
                  dateTime: (doc['dateTime'] as Timestamp).toDate(),
                ))
            .toList();
      });
    }
  }

  Future<void> _scheduleNotification(Medication medication) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'medication_channel',
      'Medications',
      //   'Notification for scheduled medications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.zonedSchedule(
      medication.hashCode,
      'Medication Reminder',
      'Take ${medication.name}, Dosage: ${medication.dosage}',
      tz.TZDateTime.from(medication.dateTime, tz.local),
      platformChannelSpecifics,
      //     androidAllowWhileIdle: true,
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
        title: const Text('Medication Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Medication Name'),
            ),
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(labelText: 'Dosage'),
            ),
            Row(
              children: [
                const Text('Schedule:'),
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
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addMedication,
              child: const Text('Add Medication'),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Medications Scheduled:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  final medication = _medications[index];
                  return ListTile(
                    title: Text(medication.name),
                    subtitle: Text('Dosage: ${medication.dosage}'),
                    trailing: Text(
                      medication.dateTime.toString(),
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
