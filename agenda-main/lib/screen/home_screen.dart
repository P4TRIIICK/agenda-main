import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/tarefa.dart';
import '../models/status.dart'; // Para poder manipular Status
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService.instance;
  List<Tarefa> _tarefas = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    final tarefas = await _dbService.getTasksForDate(_selectedDate);
    setState(() {
      _tarefas = tarefas;
    });
  }

  // Navega até a tela de adicionar tarefa
  void _irParaAdicionarTarefa() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen()),
    );
    _carregarTarefas(); // Recarrega a lista após adicionar
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
  Future<void> _mudarStatus(Tarefa tarefa) async {
    final novoStatus = _proximoStatus(tarefa.status);
    final tarefaAtualizada = Tarefa(
      id: tarefa.id,
      nome: tarefa.nome,
      descricao: tarefa.descricao,
      dataCriacao: tarefa.dataCriacao,
      dataVencimento: tarefa.dataVencimento,
      prioridade: tarefa.prioridade,
      status: novoStatus,
      categoria: tarefa.categoria,
      tipoRecorrencia: tarefa.tipoRecorrencia,
      diasRecorrentes: tarefa.diasRecorrentes,
      diaDoMes: tarefa.diaDoMes,
    );

    await _dbService.updateTask(tarefaAtualizada);
    await _carregarTarefas();
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
                          _carregarTarefas();
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
                          _carregarTarefas();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Lista de Tarefas
            Expanded(
              child: _tarefas.isEmpty
                  ? const Center(child: Text('Nenhuma tarefa encontrada.'))
                  : ListView.builder(
  itemCount: _tarefas.length,
  itemBuilder: (context, index) {
    final tarefa = _tarefas[index];

    // Envolve o item com um Dismissible
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart, 
      // arrastar somente para a esquerda (end to start)

      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      // confirmDismiss é chamado antes de efetivar a remoção
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
                'de todos os dias?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
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
                'Deseja realmente deletar esta tarefa?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
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

      // onDismissed é chamado depois de confirmDismiss (se confirm for true)
      onDismissed: (direction) async {
        // Remove do banco
        await _dbService.deleteTask(tarefa.id!);

        // Remove da lista local (para feedback imediato)
        setState(() {
          _tarefas.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarefa "${tarefa.nome}" foi deletada')),
        );
      },

      child: _buildTaskItem(tarefa),
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
          }
        },
      ),
    );
  }

  // Construímos o item de tarefa com expansão e botão de status
  Widget _buildTaskItem(Tarefa tarefa) {
    return Card(
      color: _getStatusColor(tarefa.status),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          tarefa.nome,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),

        // Botão para alternar status
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _mudarStatus(tarefa),
          child: Text(
            tarefa.status.toString().split('.').last,
            // exibe "pendente", "executando", "concluida"
            style: const TextStyle(fontSize: 14),
          ),
        ),

        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tarefa.descricao,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prioridade: ${tarefa.prioridade.toString().split('.').last}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Categoria: ${tarefa.categoria.toString().split('.').last}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
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
