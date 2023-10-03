import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String title;
  final String descricao;
  final bool isCompleted;
  final DateTime dateTime;

  Task({
    required this.title,
    required this.descricao,
    required this.isCompleted,
    required this.dateTime,
  });

  // Construtor para criar uma tarefa a partir de um DocumentSnapshot
}

// Resto do código permanece o mesmo
