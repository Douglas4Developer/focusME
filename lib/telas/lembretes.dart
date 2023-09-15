import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tdah_app/models/lembretes_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class CadastroLembreteScreen extends StatefulWidget {
  @override
  _CadastroLembreteScreenState createState() => _CadastroLembreteScreenState();
}

class _CadastroLembreteScreenState extends State<CadastroLembreteScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    initializeNotifications();
  }

  void initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onSelectNotification: onSelectNotification,
    );
  }

  Future onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('Notificação selecionada: $payload');
    }
  }

  tz.TZDateTime _getNow() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    return tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
  }

  Future<void> scheduleNotification(
      DateTime scheduledDate, String title) async {
    final tz.TZDateTime now = _getNow();
    final tz.TZDateTime scheduledDateTime = tz.TZDateTime(
      tz.getLocation('America/Sao_Paulo'),
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final tz.TZDateTime effectiveScheduledDateTime =
        scheduledDateTime.isBefore(now.add(Duration(minutes: 1)))
            ? now.add(const Duration(minutes: 1))
            : scheduledDateTime;

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      priority: Priority.high,
      importance: Importance.max,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      'Lembrete',
      effectiveScheduledDateTime,
      notificationDetails,
      payload: 'Notificação payload',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('Notificação agendada para $effectiveScheduledDateTime');
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Lembrete'),
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
              onPressed: () {
                if (_tituloController.text.isNotEmpty &&
                    _selectedDate != null &&
                    _selectedTime != null) {
                  final lembrete = Lembrete(
                    titulo: _tituloController.text,
                    descricao: _descricaoController.text,
                    dataHora: DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    ),
                  );

                  scheduleNotification(lembrete.dataHora, lembrete.titulo);
                  // Salve o lembrete no banco de dados ou onde você preferir
                  // Adicione o código aqui para salvar o lembrete
                }
              },
              child: const Text('Salvar Lembrete'),
            ),
          ],
        ),
      ),
    );
  }
}
