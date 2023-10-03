import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tdah_app/models/tasks.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  bool _isCompleted = false;

  void _clearForm() {
    _titleController.clear();
    _descricaoController.clear();
    _isCompleted = false;
  }

  Future<void> _addTask() async {
    final user = _auth.currentUser;
    if (user != null) {
      final task = Task(
        title: _titleController.text,
        descricao: _descricaoController.text,
        isCompleted: _isCompleted,
        dateTime: DateTime.now(), // Set the dateTime to the current time
      );

      await _firestore.collection('tarefas').add({
        'titulo': task.title,
        'descricao': task.descricao,
        'isCompleted': task.isCompleted,
        'dateTime': task.dateTime, // Save the dateTime field in Firestore
        'userId': user.uid,
      });

      _clearForm();
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
              onPressed: _addTask,
              child: const Text('Adicionar Tarefa'),
            ),
          ],
        ),
      ),
    );
  }
}
