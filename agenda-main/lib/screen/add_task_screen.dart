import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import '../models/prioridade.dart';
import '../models/status.dart';
import '../services/database_service.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores e valores do formulário
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  DateTime _dataCriacao = DateTime.now();
  DateTime? _dataVencimento;
  Prioridade _prioridadeSelecionada = Prioridade.media;
  Status _statusSelecionado = Status.pendente;
  String _categoriaSelecionada = "Geral";

  // Serviço de banco de dados
  final DatabaseService _dbService = DatabaseService.instance;

  Future<void> _salvarTarefa() async {
    if (_formKey.currentState!.validate()) {
      final novaTarefa = Tarefa(
        nome: _nomeController.text,
        descricao: _descricaoController.text,
        dataCriacao: _dataCriacao,
        dataVencimento: _dataVencimento,
        prioridade: _prioridadeSelecionada,
        status: _statusSelecionado,
        categoria: _categoriaSelecionada,
      );

      // Salva no banco de dados
      await _dbService.addTask(novaTarefa);

      // Voltar para a tela anterior
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(labelText: 'Nome da Tarefa'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome da tarefa.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descricaoController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                ),
                SizedBox(height: 16),
                Text('Data de Vencimento:'),
                Row(
                  children: [
                    Text(
                      _dataVencimento != null
                          ? '${_dataVencimento!.day}/${_dataVencimento!.month}/${_dataVencimento!.year}'
                          : 'Nenhuma data selecionada',
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _dataVencimento = selectedDate;
                          });
                        }
                      },
                      child: Text('Selecionar Data'),
                    ),
                  ],
                ),
                DropdownButtonFormField<Prioridade>(
                  value: _prioridadeSelecionada,
                  decoration: InputDecoration(labelText: 'Prioridade'),
                  items: Prioridade.values.map((Prioridade prioridade) {
                    return DropdownMenuItem(
                      value: prioridade,
                      child: Text(prioridade.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _prioridadeSelecionada = value!;
                    });
                  },
                ),
                DropdownButtonFormField<Status>(
                  value: _statusSelecionado,
                  decoration: InputDecoration(labelText: 'Status'),
                  items: Status.values.map((Status status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _statusSelecionado = value!;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Categoria'),
                  initialValue: _categoriaSelecionada,
                  onChanged: (value) {
                    setState(() {
                      _categoriaSelecionada = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _salvarTarefa,
                    child: Text('Salvar Tarefa'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
