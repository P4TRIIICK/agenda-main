import 'tarefa.dart';

class TarefaRecorrente {
  final int id;
  final List<String> dayOfWeek;
  final DateTime finalDate;
  final Tarefa tarefa;

  TarefaRecorrente({
    required this.id,
    required this.dayOfWeek,
    required this.finalDate,
    required this.tarefa,
  });
}
