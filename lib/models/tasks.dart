class Task {
  final String title;
  final String description;
  final bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.isCompleted,
    required DateTime dateTime,
  });

  get dateTime => null;
}
