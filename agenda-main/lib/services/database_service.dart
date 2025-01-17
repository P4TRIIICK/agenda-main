import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tarefa.dart';
// ... importações necessárias

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  static Database? _database;

  DatabaseService._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Se o seu db version já for 1, suba para 2:
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return openDatabase(
      path,
      version: 2,            // Aumente para 2
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT,
        dataCriacao TEXT NOT NULL,
        dataVencimento TEXT,
        prioridade TEXT NOT NULL,
        status TEXT NOT NULL,
        categoria TEXT NOT NULL,
        tipoRecorrencia TEXT,
        diasRecorrentes TEXT,
        diaDoMes INTEGER
      )
    ''');
  }

  // Se alguém já tiver a versão antiga
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adiciona a coluna diaDoMes se não existir
      await db.execute('ALTER TABLE tasks ADD COLUMN diaDoMes INTEGER');
    }
  }

  // Inserir uma tarefa
  Future<int> addTask(Tarefa tarefa) async {
    final db = await database;
    return db.insert('tasks', tarefa.toMap());
  }

  // Buscar todas as tarefas
  Future<List<Tarefa>> getTasks() async {
    final db = await database;
    final result = await db.query('tasks');
    return result.map((json) => Tarefa.fromMap(json)).toList();
  }

  // Deletar uma tarefa
  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Exemplo de busca de tarefas para uma data (se quiser filtrar recorrência)
  Future<List<Tarefa>> getTasksForDate(DateTime date) async {
    final db = await database;
    final int weekday = date.weekday % 7;

    final result = await db.rawQuery('''
      SELECT * FROM tasks
      WHERE (tipoRecorrencia IS NULL AND date(dataVencimento) = ?)
        OR (tipoRecorrencia = "semanal" AND diasRecorrentes LIKE ?)
    ''', [date.toIso8601String().split('T')[0], '%$weekday%']);

    return result.map((json) => Tarefa.fromMap(json)).toList();
  }
}
