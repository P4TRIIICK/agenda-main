import 'prioridade.dart';
import 'status.dart';
import 'categoria.dart';

class Tarefa {
  final int? id;
  final String nome;
  final String descricao;
  final DateTime dataCriacao;
  final DateTime? dataVencimento;
  final Prioridade prioridade;
  final Status status;
  final Categoria categoria;

  final String? tipoRecorrencia;    
  final List<int>? diasRecorrentes; 
  final int? diaDoMes;               

  Tarefa({
    this.id,
    required this.nome,
    required this.descricao,
    required this.dataCriacao,
    this.dataVencimento,
    required this.prioridade,
    required this.status,
    required this.categoria,
    this.tipoRecorrencia,
    this.diasRecorrentes,
    this.diaDoMes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataVencimento': dataVencimento?.toIso8601String(),
      'prioridade': prioridade.toString(),  
      'status': status.toString(),         
      'categoria': categoria.toString(),   
      'tipoRecorrencia': tipoRecorrencia,  
      'diasRecorrentes': diasRecorrentes?.join(','),
      'diaDoMes': diaDoMes,                 
    };
  }

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
        (e) => e.toString() == map['prioridade'],
      ),
      status: Status.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
      categoria: Categoria.values.firstWhere(
        (e) => e.toString() == map['categoria'],
      ),
      tipoRecorrencia: map['tipoRecorrencia'],
      diasRecorrentes: map['diasRecorrentes'] != null
          ? (map['diasRecorrentes'] as String)
              .split(',')
              .map((e) => int.parse(e))
              .toList()
          : null,
      diaDoMes: map['diaDoMes'],
    );
  }
}
