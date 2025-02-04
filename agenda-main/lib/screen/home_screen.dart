import 'package:agenda/screen/settings_screen.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/tarefa.dart';
import '../models/tarefa_ocorrencia.dart';
import '../models/status.dart'; // Para poder manipular Status
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

    // Para cada tarefa, pegar ou criar uma occurrence
    final lista = <_TarefaComOcorrencia>[];
    for (final t in tasks) {
      // pega occurrence
      final occ = await _dbService.getOccurrenceByDate(t.id!, _stripTime(dia));
      // se nao existir, cria
      if (occ == null) {
        final nova = TarefaOcorrencia(
          taskId: t.id!,
          occurrenceDate: _stripTime(dia), // "strip" ou use date sem time
          status: Status.pendente, // default
        );
        final newId = await _dbService.addOccurrence(nova);
        final novaOcorrencia = nova.copyWith(id: newId);
        // ou crie um construtor de copy
        lista.add(_TarefaComOcorrencia(t, novaOcorrencia));
      } else {
        lista.add(_TarefaComOcorrencia(t, occ));
      }
    }

    setState(() {
      _tarefasComOcorrencias = lista;
    });
  }

  // helper para remover hora/min/seg do DateTime
  DateTime _stripTime(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  // Navega até a tela de adicionar tarefa
  void _irParaAdicionarTarefa() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen()),
    );
    _carregarTarefasDoDia(_selectedDate); // Recarrega a lista após adicionar
  }


  // Alterna o status da tarefa na ordem: pendente -> executando -> concluida -> pendente
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

  // Atualiza a tarefa no banco de dados com o novo status e recarrega
  Future<void> _mudarStatus(TarefaOcorrencia occ) async {
    final novoStatus = _proximoStatus(occ.status);
    final atualizado = TarefaOcorrencia(
      id: occ.id,
      taskId: occ.taskId,
      occurrenceDate: occ.occurrenceDate,
      status: novoStatus,
    );
    await _dbService.updateOccurrence(atualizado);
    // recarrega
    _carregarTarefasDoDia(_selectedDate);
  }

  // Define a cor de fundo conforme o status
  Color _getStatusColor(Status status) {
    switch (status) {
      case Status.pendente:
        return Colors.white; // cor padrão (ou um cinza bem claro)
      case Status.executando:
        return Colors.orange.shade100; // laranja claro
      case Status.concluida:
        return Colors.green.shade100; // verde claro
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removemos appBar (ou mantemos se quiser algo minimal)
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho (dia da semana + data)
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

            // Lista de Tarefas
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
                            // Se quiser perguntar antes de deletar
                            if (tarefa.tipoRecorrencia != null) {
                              // Se a tarefa é recorrente, por ex.
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
                              // Se não é recorrente, pode perguntar de modo genérico ou nem perguntar
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
                            // Remove do banco
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
      // Navega para a tela de configurações
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
      color: _getStatusColor(occ.status), // fundo dependendo do status
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        // Leading (à esquerda) é opcional. Pode pôr um ícone representando a tarefa
        leading: const Icon(Icons.list_alt, size: 30, color: Colors.black87),

        // Título principal (sem estar expandido)
        title: Text(
          tarefa.nome,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        // Trailing fixo, um botão para mudar status
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

        // Espaçamento para o conteúdo ao expandir
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

        // Alinhamentos ao expandir
        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,

        // Conteúdo que aparece ao expandir
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
