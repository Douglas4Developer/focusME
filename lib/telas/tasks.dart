import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tdah_app/models/tasks.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tdah_app/telas/calender.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  bool _isCompleted = false;
  DateTime? _selectedDate;
  List<Task> _taskList = [];

  void _clearForm() {
    _titleController.clear();
    _descricaoController.clear();
    _isCompleted = false;
    _selectedDate = null;
  }

  Future<void> _addTask() async {
    final user = _auth.currentUser;
    if (user != null) {
      final task = Task(
        title: _titleController.text,
        descricao: _descricaoController.text,
        isCompleted: _isCompleted,
        dateTime: _selectedDate ?? DateTime.now(),
      );

      await _firestore.collection('tarefas').add({
        'titulo': task.title,
        'descricao': task.descricao,
        'isCompleted': task.isCompleted,
        'dateTime': task.dateTime,
        'userId': user.uid,
      });

      _clearForm();
      _loadTasks(); // Recarrega a lista de tarefas após adicionar uma nova
    }
  }

  void _navigateToCalendarScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalendarScreen(),
      ),
    );
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

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Carrega as tarefas ao iniciar o widget
  }

  Future<void> _loadTasks() async {
    final user = _auth.currentUser;
    if (user != null) {
      final querySnapshot = await _firestore
          .collection('tarefas')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        _taskList = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Task(
            title: data['titulo'],
            descricao: data['descricao'],
            isCompleted: data['isCompleted'],
            dateTime: data['dateTime'].toDate(),
          );
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Cadastro de Tarefas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título da Tarefa'),
            ),
            TextFormField(
              controller: _descricaoController,
              decoration:
                  const InputDecoration(labelText: 'Descrição da Tarefa'),
            ),
            Row(
              children: [
                const Text('Tarefa Concluída'),
                Checkbox(
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _showDatePicker,
              child: const Text('Selecionar Data'),
            ),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text('Adicionar Tarefa'),
            ),
            ElevatedButton(
              onPressed: _navigateToCalendarScreen,
              child: const Text('Ver Calendário'),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Lista de Tarefas:',
              style: TextStyle(fontSize: 18.0),
            ),
            _buildTaskList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _taskList.length,
        itemBuilder: (context, index) {
          final task = _taskList[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(
              'Descrição: ${task.descricao}\n'
              'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(task.dateTime)}\n'
              'Concluída: ${task.isCompleted ? "Sim" : "Não"}',
            ),
          );
        },
      ),
    );
  }
}
