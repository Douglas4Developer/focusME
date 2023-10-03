class Task {
  final String title;
  final String descricao;
  final bool isCompleted;

  Task({
    required this.title,
    required this.descricao,
    required this.isCompleted,
    required DateTime dateTime,
  });

  get dateTime => null;
}
