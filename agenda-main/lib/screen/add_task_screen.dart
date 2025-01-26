import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import '../models/prioridade.dart';
import '../models/status.dart';
import '../models/categoria.dart';
import '../services/database_service.dart';
import 'package:agenda/utils/add_task_utils.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  
  final DatabaseService _dbService = DatabaseService.instance;

  DateTime? _dataCriacao = DateTime.now();
  DateTime? _dataVencimento;
  Prioridade? _prioridadeSelecionada; 
  Status _statusSelecionado = Status.pendente;
  Categoria? _categoriaSelecionada;   
  String? tipoRecorrencia;            
  List<bool> diasSelecionados = List.filled(7, false); 
  int? _diaDoMesSelecionado;

  bool _isSaving = false;

  Future<void> _salvarTarefa() async {
    final error = AddTaskUtils.validateTask(
      name: _nomeController.text,
      prioridade: _prioridadeSelecionada,
      categoria: _categoriaSelecionada,
      tipoRecorrencia: tipoRecorrencia,
      dataVencimento: _dataVencimento,
      diasSelecionados: diasSelecionados,
      diaDoMes: _diaDoMesSelecionado,
    );

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return; 
    }

    setState(() => _isSaving = true);

    try {
      List<int>? diasRecorrentes;
      if (tipoRecorrencia == 'semanal') {
        diasRecorrentes = diasSelecionados
            .asMap()
            .entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();
      }

      final novaTarefa = Tarefa(
        nome: _nomeController.text,
        descricao: _descricaoController.text,
        dataCriacao: _dataCriacao!,
        dataVencimento: _dataVencimento,
        prioridade: _prioridadeSelecionada ?? Prioridade.media,
        status: _statusSelecionado,
        categoria: _categoriaSelecionada ?? Categoria.casa,
        tipoRecorrencia: tipoRecorrencia,
        diasRecorrentes: diasRecorrentes,
        diaDoMes: _diaDoMesSelecionado,
      );

      await _dbService.addTask(novaTarefa);

      if (!mounted) return;
      Navigator.of(context).pop();

    } catch (e) {
      print("Erro ao salvar tarefa: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar tarefa.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _selecionarDataVencimento(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _dataVencimento ?? DateTime.now(),
    firstDate: DateTime(2022),
    lastDate: DateTime(2100),
  );
  if (picked != null && picked != _dataVencimento) {
    setState(() {
      _dataVencimento = picked;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Stack(
        children: [
          Form(
            key: _formKey, 
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    const Text(
                      "Nova Tarefa",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Adicione uma nova tarefa para seu menu principal",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Nome da Tarefa",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      controller: _nomeController,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Informe um nome' : null,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<Prioridade>(
                            decoration: InputDecoration(
                              labelText: "Prioridade",
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            value: _prioridadeSelecionada,
                            items: Prioridade.values.map((prioridade) {
                              return DropdownMenuItem(
                                value: prioridade,
                                child: Text(
                                  prioridade.toString().split('.').last,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _prioridadeSelecionada = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<Categoria>(
                            decoration: InputDecoration(
                              labelText: "Categoria",
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            value: _categoriaSelecionada,
                            items: Categoria.values.map((categoria) {
                              return DropdownMenuItem(
                                value: categoria,
                                child: Text(
                                  categoria.toString().split('.').last,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _categoriaSelecionada = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Descrição...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      controller: _descricaoController,
                    ),
                    const SizedBox(height: 30),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Recorrência",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      value: tipoRecorrencia,
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Nenhuma')),
                        DropdownMenuItem(value: 'semanal', child: Text('Semanal')),
                        DropdownMenuItem(value: 'mensal', child: Text('Mensal')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          tipoRecorrencia = value;
                          if (tipoRecorrencia == null) {
                            _dataVencimento = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    if (tipoRecorrencia == null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Selecione a data de vencimento:"),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () => _selecionarDataVencimento(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _dataVencimento == null
                                    ? 'Nenhuma data selecionada'
                                    : 'Data: ${_dataVencimento!.day}/${_dataVencimento!.month}/${_dataVencimento!.year}',
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (tipoRecorrencia == 'semanal')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Selecione os dias da semana:"),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 5.0,
                            runSpacing: 5.0,
                            children: List.generate(7, (index) {
                              final List<String> diasAbreviados = [
                                'Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'
                              ];
                              return FilterChip(
                                label: Text(diasAbreviados[index]),
                                selected: diasSelecionados[index],
                                onSelected: (bool value) {
                                  setState(() {
                                    diasSelecionados[index] = value;
                                  });
                                },
                              );
                            }),
                          ),
                        ],
                      )
                    else if (tipoRecorrencia == 'mensal')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Selecione o dia do mês (1 - 31):"),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<int>(
                            value: _diaDoMesSelecionado,
                            hint: const Text("Dia do mês"),
                            items: List.generate(31, (index) => index + 1)
                                .map((dia) => DropdownMenuItem(
                                      value: dia,
                                      child: Text(dia.toString()),
                                    ))
                                .toList(),
                            onChanged: (valor) {
                              setState(() {
                                _diaDoMesSelecionado = valor;
                              });
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 30),

                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _salvarTarefa,
                        child: const Text(
                          "Adicionar",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
