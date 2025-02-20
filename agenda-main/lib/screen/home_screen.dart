import 'package:agenda/screen/settings_screen.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/tarefa.dart';
import '../models/tarefa_ocorrencia.dart';
import '../models/status.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService.instance;

  // Dia atual selecionado
  DateTime _selectedDate = DateTime.now();

  // Lista de "tarefa + ocorrência"
  List<_TarefaComOcorrencia> _tarefasComOcorrencias = [];

  @override
  void initState() {
    super.initState();
    _carregarTarefasDoDia(_selectedDate);
  }

  // Carrega tarefas específicas para o dia selecionado, 
  // considerando "Nenhuma" recorrência e dataVencimento, 
  // ou "semanal"/"mensal" etc. 
  Future<void> _carregarTarefasDoDia(DateTime dia) async {
    final tasks = await _dbService.getTasksForDate(dia);

    // Gera ou pega occurrences para cada tarefa
    final lista = <_TarefaComOcorrencia>[];
    for (final t in tasks) {
      final occ = await _dbService.getOccurrenceByDate(t.id!, _stripTime(dia));
      if (occ == null) {
        // Se não existe "ocorrência" no BD, cria com status pendente
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

  // Remove horas/min/seg do DateTime 
  DateTime _stripTime(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  // Vai para a tela de adicionar tarefa
  void _irParaAdicionarTarefa() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
    // Recarrega ao voltar
    _carregarTarefasDoDia(_selectedDate);
  }

  // Alterna status pendente->executando->concluida->pendente
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

  // Atualiza occurrence no BD
  Future<void> _mudarStatus(TarefaOcorrencia occ) async {
    final novoStatus = _proximoStatus(occ.status);
    final atualizado = TarefaOcorrencia(
      id: occ.id,
      taskId: occ.taskId,
      occurrenceDate: occ.occurrenceDate,
      status: novoStatus,
    );
    await _dbService.updateOccurrence(atualizado);
    // Recarrega
    _carregarTarefasDoDia(_selectedDate);
  }

  // Cor do card conforme status
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

  // Formata dia da semana 
  String _getDayOfWeek(DateTime date) {
    // Se date.weekday=1..7, mapeie:
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

  @override
  Widget build(BuildContext context) {
    // Responsividade
    final size = MediaQuery.of(context).size;
    final verticalSpacing = size.height * 0.02;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho (dia da semana, setas)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: verticalSpacing,
              ),
              child: Column(
                children: [
                  // Exibe dia da semana
                  Text(
                    _getDayOfWeek(_selectedDate),
                    style: TextStyle(
                      fontSize: size.height * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  // Setas e data
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: size.height * 0.04,
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
                        style: TextStyle(fontSize: size.height * 0.03),
                      ),
                      IconButton(
                        iconSize: size.height * 0.04,
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

            // Lista de tarefas
            Expanded(
              child: _tarefasComOcorrencias.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma tarefa encontrada.',
                        style: TextStyle(fontSize: size.height * 0.022),
                      ),
                    )
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
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            // Se é tarefa recorrente, pergunta 
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
                              // Tarefa sem recorrencia
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
                            // Deleta do BD
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
                          child: _buildTaskItem(tarefa, occ, size),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // Navegação inferior
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
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }
        },
      ),
    );
  }

  /// Constrói o item (Card + ExpansionTile) para cada tarefa + occurrence
  Widget _buildTaskItem(Tarefa tarefa, TarefaOcorrencia occ, Size size) {
    return Card(
      color: _getStatusColor(occ.status),
      margin: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.01,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.list_alt,
          size: size.height * 0.04,
          color: Colors.black87),
        title: Text(
          tarefa.nome,
          style: TextStyle(
            fontSize: size.height * 0.022,
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
          child: Text(
            occ.status.toString().split('.').last,
            style: TextStyle(fontSize: size.height * 0.02),
          ),
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          size.width * 0.04,
          0,
          size.width * 0.04,
          size.height * 0.01,
        ),
        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.01),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.description, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tarefa.descricao.isEmpty ? 'Sem descrição' : tarefa.descricao,
                  style: TextStyle(
                    fontSize: size.height * 0.018,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            children: [
              const Icon(Icons.priority_high, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Prioridade: ${tarefa.prioridade.toString().split('.').last}',
                style: TextStyle(fontSize: size.height * 0.018),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            children: [
              const Icon(Icons.category, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Categoria: ${tarefa.categoria.toString().split('.').last}',
                style: TextStyle(fontSize: size.height * 0.018),
              ),
            ],
          ),

          // Exibe dataVencimento se for "Nenhuma" recorrencia
          if (tarefa.dataVencimento != null && tarefa.tipoRecorrencia == null)
            ...[
              SizedBox(height: size.height * 0.01),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Data única: '
                    '${tarefa.dataVencimento!.day}/'
                    '${tarefa.dataVencimento!.month}/'
                    '${tarefa.dataVencimento!.year}',
                    style: TextStyle(fontSize: size.height * 0.018),
                  ),
                ],
              ),
            ],

          // Se for mensal/semanal, você já exibe de outras formas...
          SizedBox(height: size.height * 0.02),
        ],
      ),
    );
  }
  
}

// Classe local para agrupar Tarefa+Ocorrencia
class _TarefaComOcorrencia {
  final Tarefa tarefa;
  final TarefaOcorrencia occurrence;
  _TarefaComOcorrencia(this.tarefa, this.occurrence);
}
