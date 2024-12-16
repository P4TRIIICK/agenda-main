import 'prioridade.dart';
import 'status.dart';

class Tarefa {
  final int? id;
  final String nome;
  final String descricao;
  final DateTime dataCriacao;
  final DateTime? dataVencimento;
  final Prioridade prioridade;
  final Status status;
  final String categoria;

  Tarefa({
    this.id,
    required this.nome,
    required this.descricao,
    required this.dataCriacao,
    this.dataVencimento,
    required this.prioridade,
    required this.status,
    required this.categoria,
  });

  // Converter para Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataVencimento': dataVencimento?.toIso8601String(),
      'prioridade': prioridade.toString(),
      'status': status.toString(),
      'categoria': categoria,
    };
  }

  // Criar uma Tarefa a partir do Map (para SQLite)
  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      dataCriacao: DateTime.parse(map['dataCriacao']),
      dataVencimento: map['dataVencimento'] != null
          ? DateTime.parse(map['dataVencimento'])
          : null,
      prioridade: Prioridade.values.firstWhere(
          (e) => e.toString() == map['prioridade']),
      status:
          Status.values.firstWhere((e) => e.toString() == map['status']),
      categoria: map['categoria'],
    );
  }
}
