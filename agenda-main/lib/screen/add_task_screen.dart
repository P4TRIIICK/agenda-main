import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import '../models/prioridade.dart';
import '../models/status.dart';
import '../models/categoria.dart';
import '../services/database_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final DateTime _dataCriacao = DateTime.now();
  
  DateTime? _dataVencimento;
  Prioridade _prioridadeSelecionada = Prioridade.media;
  final Status _statusSelecionado = Status.pendente;
  Categoria _categoriaSelecionada = Categoria.trabalho;

  // tipoRecorrencia:
  //   null  -> "Nenhuma"
  //   "semanal"
  //   "mensal"
  String? tipoRecorrencia;

  // Se for semanal:
  List<bool> diasSelecionados = List.filled(7, false);

  // Se for mensal:
  int? _diaDoMesSelecionado;

  final DatabaseService _dbService = DatabaseService.instance;

  Future<void> _salvarTarefa() async {
    if (_formKey.currentState!.validate()) {
      // Se for "semanal", monta lista de dias
      List<int>? diasRecorrentes = (tipoRecorrencia == 'semanal')
          ? diasSelecionados
              .asMap()
              .entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .toList()
          : null;

      // Cria nova Tarefa
      final novaTarefa = Tarefa(
        nome: _nomeController.text,
        descricao: _descricaoController.text,
        dataCriacao: _dataCriacao,
        dataVencimento: _dataVencimento,
        prioridade: _prioridadeSelecionada,
        status: _statusSelecionado,
        categoria: _categoriaSelecionada,
        tipoRecorrencia: tipoRecorrencia,
        diasRecorrentes: diasRecorrentes,
        diaDoMes: _diaDoMesSelecionado,
      );

      await _dbService.addTask(novaTarefa);
      
      // Fecha a tela
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  /// Abre o DatePicker para selecionar data (caso “Nenhuma”)
  Future<void> _selecionarDataVencimento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataVencimento ?? DateTime.now(),
      firstDate: DateTime(2020),
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
    // Responsividade
    final size = MediaQuery.of(context).size;
    final verticalSpacing = size.height * 0.02;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Conteúdo principal rolável
          SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.08), // espaço para o botão "voltar"

                  // Título e subtítulo
                  Text(
                    "Nova Tarefa",
                    style: TextStyle(
                      fontSize: size.height * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    "Adicione uma nova tarefa para seu menu principal",
                    style: TextStyle(
                      fontSize: size.height * 0.02,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),

                  // Nome da tarefa
                  TextFormField(
                    controller: _nomeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe um nome para a tarefa';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Nome da Tarefa",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(fontSize: size.height * 0.02),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Row de Prioridade e Categoria
                  Row(
                    children: [
                      // Prioridade
                      Expanded(
                        child: DropdownButtonFormField<Prioridade>(
                          value: _prioridadeSelecionada,
                          decoration: InputDecoration(
                            labelText: "Prioridade",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: Prioridade.values.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text(p.toString().split('.').last),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _prioridadeSelecionada = value!;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),

                      // Categoria
                      Expanded(
                        child: DropdownButtonFormField<Categoria>(
                          value: _categoriaSelecionada,
                          decoration: InputDecoration(
                            labelText: "Categoria",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: Categoria.values.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(c.toString().split('.').last),
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
                  SizedBox(height: verticalSpacing),

                  // Descrição
                  TextFormField(
                    controller: _descricaoController,
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
                    style: TextStyle(fontSize: size.height * 0.02),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Dropdown de Recorrência
                  DropdownButtonFormField<String>(
                    value: tipoRecorrencia,
                    decoration: InputDecoration(
                      labelText: "Recorrência",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text('Nenhuma'),
                      ),
                      DropdownMenuItem(
                        value: 'semanal',
                        child: Text('Semanal'),
                      ),
                      DropdownMenuItem(
                        value: 'mensal',
                        child: Text('Mensal'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tipoRecorrencia = value;
                      });
                    },
                  ),
                  SizedBox(height: verticalSpacing),

                  // Se recorrência == null ("Nenhuma"), exibir DatePicker
                  if (tipoRecorrencia == null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selecione a data de vencimento:",
                          style: TextStyle(fontSize: size.height * 0.02),
                        ),
                        SizedBox(height: verticalSpacing * 0.5),
                        InkWell(
                          onTap: () => _selecionarDataVencimento(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.015,
                              horizontal: size.width * 0.03,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              (_dataVencimento == null)
                                  ? 'Nenhuma data selecionada'
                                  : 'Data: ${_dataVencimento!.day}/${_dataVencimento!.month}/${_dataVencimento!.year}',
                              style: TextStyle(fontSize: size.height * 0.02),
                            ),
                          ),
                        ),
                        SizedBox(height: verticalSpacing),
                      ],
                    )
                  else if (tipoRecorrencia == 'semanal')
                    // Se for semanal, exibir dias da semana
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selecione os dias da semana:",
                          style: TextStyle(fontSize: size.height * 0.02),
                        ),
                        SizedBox(height: verticalSpacing / 2),
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 5.0,
                          children: List.generate(7, (index) {
                            final List<String> diasAbreviados = [
                              'Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'
                            ];
                            return FilterChip(
                              label: Text(
                                diasAbreviados[index],
                                style: TextStyle(
                                  fontSize: size.height * 0.018,
                                ),
                              ),
                              selected: diasSelecionados[index],
                              onSelected: (bool value) {
                                setState(() {
                                  diasSelecionados[index] = value;
                                });
                              },
                            );
                          }),
                        ),
                        SizedBox(height: verticalSpacing),
                      ],
                    )
                  else if (tipoRecorrencia == 'mensal')
                    // Se for mensal, exibir dia do mês
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selecione o dia do mês (1 - 31):",
                          style: TextStyle(fontSize: size.height * 0.02),
                        ),
                        SizedBox(height: verticalSpacing / 2),
                        DropdownButtonFormField<int>(
                          value: _diaDoMesSelecionado,
                          hint: const Text("Dia do mês"),
                          items: List.generate(31, (index) => index + 1)
                              .map((dia) => DropdownMenuItem(
                                    value: dia,
                                    child: Text(
                                      dia.toString(),
                                      style: TextStyle(
                                          fontSize: size.height * 0.018),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (valor) {
                            setState(() {
                              _diaDoMesSelecionado = valor;
                            });
                          },
                        ),
                        SizedBox(height: verticalSpacing),
                      ],
                    ),

                  // Botão de Adicionar
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: size.height * 0.07,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _salvarTarefa,
                        child: Text(
                          "Adicionar",
                          style: TextStyle(
                            fontSize: size.height * 0.022,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                ],
              ),
            ),
          ),

          // Botão de voltar no canto superior esquerdo
          Positioned(
            top: size.height * 0.05,
            left: size.width * 0.05,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, 
                  color: Colors.black, 
                  size: size.height * 0.03),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
