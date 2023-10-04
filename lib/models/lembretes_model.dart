class Lembrete {
  final String titulo;
  final String descricao;
  final DateTime dateTime;

  Lembrete({
    required this.titulo,
    required this.descricao,
    required this.dateTime,
  });
}

class LembreteNotification {
  final String titulo;
  final String descricao;

  LembreteNotification({
    required this.titulo,
    required this.descricao,
  });
}
