import 'categoria.dart';

class Tarefa {
  final int id;
  final String descriptions;
  final int priority;
  final Categoria categoria;

  Tarefa({
    required this.id,
    required this.descriptions,
    required this.priority,
    required this.categoria,
  });
}
