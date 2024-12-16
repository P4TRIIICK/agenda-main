import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/tarefa.dart';
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
    final tarefas = await _dbService.getTasks();
    setState(() {
      _tarefas = tarefas;
    });
  }

  // Função para navegar até a tela de adicionar tarefas
  void _irParaAdicionarTarefa() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen()),
    );
    _carregarTarefas(); // Recarregar a lista após adicionar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela Principal'),
      ),
      body: Column(
        children: [
          // Exibe o dia atual e navegação de datas
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${_getDayOfWeek(_selectedDate)}',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_left),
                      onPressed: () {
                        setState(() {
                          _selectedDate =
                              _selectedDate.subtract(Duration(days: 1));
                        });
                      },
                    ),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: TextStyle(fontSize: 24),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_right),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(Duration(days: 1));
                        });
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
                ? Center(child: Text('Nenhuma tarefa encontrada.'))
                : ListView.builder(
                    itemCount: _tarefas.length,
                    itemBuilder: (context, index) {
                      final tarefa = _tarefas[index];
                      return Card(
                        child: ListTile(
                          title: Text(tarefa.nome),
                          subtitle: Text(tarefa.descricao),
                          trailing: Text(
                              'Prioridade: ${tarefa.prioridade.toString().split('.').last}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tarefa', // Nome alterado
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

  String _getDayOfWeek(DateTime date) {
    List<String> weekdays = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado'
    ];
    return weekdays[date.weekday - 1];
  }
}
