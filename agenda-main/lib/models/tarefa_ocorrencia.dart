import 'package:agenda/models/status.dart';

class TarefaOcorrencia {
  final int? id;
  final int taskId;
  final DateTime occurrenceDate;
  final Status status;

  TarefaOcorrencia({
    this.id,
    required this.taskId,
    required this.occurrenceDate,
    required this.status,
  });

  // Aqui está o copyWith
  TarefaOcorrencia copyWith({
    int? id,
    int? taskId,
    DateTime? occurrenceDate,
    Status? status,
  }) {
    return TarefaOcorrencia(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'occurrenceDate': occurrenceDate.toIso8601String(),
      'status': status.toString(),
    };
  }

  factory TarefaOcorrencia.fromMap(Map<String, dynamic> map) {
    return TarefaOcorrencia(
      id: map['id'],
      taskId: map['task_id'],
      occurrenceDate: DateTime.parse(map['occurrenceDate']),
      status: Status.values.firstWhere((e) => e.toString() == map['status']),
    );
  }
}

