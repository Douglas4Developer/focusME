import 'dart:math';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tdah_app/models/tasks.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Task>> _events = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  List<Task> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
  }

  Widget _buildEventsList() {
    if (_selectedDay == null) {
      return Container();
    }

    final selectedEvents = _getEventsForDay(_selectedDay!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarefas para ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: selectedEvents.length,
          itemBuilder: (context, index) {
            final task = selectedEvents[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text(task.descricao),
            );
          },
        ),
      ],
    );
  }

  void _loadEvents() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userId = user.uid;
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tarefas')
          .where('userId', isEqualTo: userId)
          .get();

      for (var taskDoc in tasksSnapshot.docs) {
        final data = taskDoc.data();
        final timestamp = data['dateTime'] as Timestamp;
        final taskDate = timestamp.toDate();

        final task = Task(
          title: data['titulo'] as String,
          descricao: data['descricao'] as String,
          isCompleted: data['isCompleted'] as bool,
          dateTime: taskDate,
        );

        if (_events[taskDate] == null) {
          _events[taskDate] = [task];
        } else {
          _events[taskDate]!.add(task);
        }
      }

      // Debugging: Print the loaded events to check if data is retrieved correctly
      print('Loaded events:');
      _events.forEach((key, value) {
        print('$key: ${value.map((task) => task.title)}');
      });

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário de Tarefas'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2022, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: _onDaySelected,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
              ),
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (BuildContext context, date, events) {
                  if (events.isEmpty) return const SizedBox();
                  return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.all(1),
                          child: Container(
                            // height: 7,
                            width: 5,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.primaries[
                                    Random().nextInt(Colors.primaries.length)]),
                          ),
                        );
                      });
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildEventsList(),
          ],
        ),
      ),
    );
  }
}
