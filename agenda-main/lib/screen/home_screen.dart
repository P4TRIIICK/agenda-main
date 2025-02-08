import 'package:agenda/screen/settings_screen.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/tarefa.dart';
import '../models/tarefa_ocorrencia.dart';
import '../models/status.dart'; 
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService.instance;
  DateTime _selectedDate = DateTime.now();

  List<_TarefaComOcorrencia> _tarefasComOcorrencias = [];

  @override
  void initState() {
    super.initState();
    _carregarTarefasDoDia(_selectedDate);
  }

  Future<void> _carregarTarefasDoDia(DateTime dia) async {
    final tasks = await _dbService.getTasksForDate(dia);

    final lista = <_TarefaComOcorrencia>[];
    for (final t in tasks) {

      final occ = await _dbService.getOccurrenceByDate(t.id!, _stripTime(dia));
      if (occ == null) {
        final nova = TarefaOcorrencia(
          taskId: t.id!,
          occurrenceDate: _stripTime(dia),
          status: Status.pendente, 
        );
        final newId = await _dbService.addOccurrence(nova);
        final novaOcorrencia = nova.copyWith(id: newId);
        lista.add(_TarefaComOcorrencia(t, novaOcorrencia));
      } else {
        lista.add(_TarefaComOcorrencia(t, occ));
      }
    }

    setState(() {
      _tarefasComOcorrencias = lista;
    });
  }

  DateTime _stripTime(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  void _irParaAdicionarTarefa() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen()),
    );
    _carregarTarefasDoDia(_selectedDate);
  }

  Status _proximoStatus(Status atual) {
    switch (atual) {
      case Status.pendente:
        return Status.executando;
      case Status.executando:
        return Status.concluida;
      case Status.concluida:
        return Status.pendente;
    }
  }

  Future<void> _mudarStatus(TarefaOcorrencia occ) async {
    final novoStatus = _proximoStatus(occ.status);
    final atualizado = TarefaOcorrencia(
      id: occ.id,
      taskId: occ.taskId,
      occurrenceDate: occ.occurrenceDate,
      status: novoStatus,
    );
    await _dbService.updateOccurrence(atualizado);
    _carregarTarefasDoDia(_selectedDate);
  }

  Color _getStatusColor(Status status) {
    switch (status) {
      case Status.pendente:
        return Colors.white; 
      case Status.executando:
        return Colors.orange.shade100; 
      case Status.concluida:
        return Colors.green.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    _getDayOfWeek(_selectedDate),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left),
                        onPressed: () {
                          setState(() {
                            _selectedDate =
                                _selectedDate.subtract(const Duration(days: 1));
                          });
                          _carregarTarefasDoDia(_selectedDate);
                        },
                      ),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 24),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_right),
                        onPressed: () {
                          setState(() {
                            _selectedDate =
                                _selectedDate.add(const Duration(days: 1));
                          });
                          _carregarTarefasDoDia(_selectedDate);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: _tarefasComOcorrencias.isEmpty
                  ? const Center(child: Text('Nenhuma tarefa encontrada.'))
                  : ListView.builder(
                      itemCount: _tarefasComOcorrencias.length,
                      itemBuilder: (context, index) {
                        final item = _tarefasComOcorrencias[index];
                        final tarefa = item.tarefa;
                        final occ = item.occurrence;

                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (tarefa.tipoRecorrencia != null) {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Tarefa recorrente'),
                                  content: const Text(
                                      'Você tem certeza que deseja deletar esta tarefa recorrente '
                                      'de todos os dias?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Deletar'),
                                    ),
                                  ],
                                ),
                              );

                              return confirm ?? false;
                            } else {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Deletar tarefa'),
                                  content: const Text(
                                      'Deseja realmente deletar esta tarefa?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Deletar'),
                                    ),
                                  ],
                                ),
                              );

                              return confirm ?? false;
                            }
                          },
                          onDismissed: (direction) async {
                            await _dbService.deleteTask(tarefa.id!);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Tarefa "${tarefa.nome}" foi deletada')),
                            );
                            setState(() {
                              _tarefasComOcorrencias.removeAt(index);
                            });
                          },
                          child: _buildTaskItem(tarefa, occ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.task),
      label: 'Tarefa',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Configurações',
    ),
  ],
  onTap: (index) {
    if (index == 1) {
      _irParaAdicionarTarefa();
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }
  },
),

    );
  }

  Widget _buildTaskItem(Tarefa tarefa, TarefaOcorrencia occ) {
    return Card(
      color: _getStatusColor(occ.status), 
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.list_alt, size: 30, color: Colors.black87),
        title: Text(
          tarefa.nome,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _mudarStatus(occ),
          child: Text(occ.status.toString().split('.').last),
        ),

        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.description, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tarefa.descricao.isEmpty ? 'Sem descrição' : tarefa.descricao,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.priority_high, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Prioridade: ${tarefa.prioridade.toString().split('.').last}',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.category, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Categoria: ${tarefa.categoria.toString().split('.').last}',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          if (tarefa.dataVencimento != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Vencimento: '
                  '${tarefa.dataVencimento!.day}/'
                  '${tarefa.dataVencimento!.month}/'
                  '${tarefa.dataVencimento!.year}',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getDayOfWeek(DateTime date) {
    List<String> weekdays = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo'
    ];
    return weekdays[date.weekday - 1];
  }
}

class _TarefaComOcorrencia {
  final Tarefa tarefa;
  final TarefaOcorrencia occurrence;
  _TarefaComOcorrencia(this.tarefa, this.occurrence);
}
