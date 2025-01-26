// lib/utils/add_task_utils.dart

import 'package:agenda/models/prioridade.dart';
import 'package:agenda/models/categoria.dart';

class AddTaskUtils {

  static String? validateTask({
    required String name,
    required Prioridade? prioridade,
    required Categoria? categoria,
    required String? tipoRecorrencia, 
    required DateTime? dataVencimento,
    required List<bool> diasSelecionados, 
    required int? diaDoMes,             
  }) {

    if (name.trim().isEmpty) {
      return "O nome da tarefa não pode estar vazio.";
    }

    if (prioridade == null) {
      return "Selecione uma prioridade.";
    }
    if (categoria == null) {
      return "Selecione uma categoria.";
    }

    if (tipoRecorrencia == null) {
      if (dataVencimento == null) {
        return "Selecione uma data de vencimento ou mude a recorrência.";
      }
    }
    else if (tipoRecorrencia == 'semanal') {
      final algumDiaSelecionado = diasSelecionados.any((item) => item == true);
      if (!algumDiaSelecionado) {
        return "Selecione ao menos um dia da semana para recorrência.";
      }
    }
    else if (tipoRecorrencia == 'mensal') {
      if (diaDoMes == null) {
        return "Selecione um dia do mês para a recorrência mensal.";
      }
    }

    return null;
  }
}
