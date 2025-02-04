import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tarefa.dart';
import '../models/tarefa_ocorrencia.dart';
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
      );
    ''');

    await db.execute('''
      CREATE TABLE task_occurrences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        occurrenceDate TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      );
    ''');
  }

  Future<int> updateTask(Tarefa tarefa) async {
    final db = await database;
    return db.update(
      'tasks',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  Future<int> deleteTask(int id) async {
  final db = await database;
  return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Se alguém já tiver a versão antiga
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN diaDoMes INTEGER');

      // Também crie a tabela task_occurrences
      await db.execute('''
        CREATE TABLE IF NOT EXISTS task_occurrences (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          task_id INTEGER NOT NULL,
          occurrenceDate TEXT NOT NULL,
          status TEXT NOT NULL,
          FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
        );
      ''');
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

  // Exemplo de busca de tarefas para uma data (se quiser filtrar recorrência)
  // No database_service.dart

  Future<List<Tarefa>> getTasksForDate(DateTime date) async {
    final db = await database;

    // 1. Buscar tarefas sem recorrência que tenham dataVencimento = date (ajuste se quiser a parte "date(dataVencimento) = date(...)")
    // 2. Buscar tarefas com recorrência = "semanal" e dayOfWeek
    // 3. Buscar tarefas com recorrência = "mensal" e dayOfMonth
    // ...
    // Junte tudo numa lista e retorne. (Isso você já faz.)

    // Exemplo simplificado que já existia:
    final int weekday = date.weekday % 7; // 0=Dom, 1=Seg etc., se preferir
    final result = await db.rawQuery('''
      SELECT * FROM tasks
      WHERE (tipoRecorrencia IS NULL AND date(dataVencimento) = ?)
        OR (tipoRecorrencia = "semanal" AND diasRecorrentes LIKE ?)
        OR (tipoRecorrencia = "mensal" AND diaDoMes = ?)
    ''', [
      date.toIso8601String().split('T')[0],
      '%$weekday%',
      date.day
    ]);

    return result.map((json) => Tarefa.fromMap(json)).toList();
  }


  // Insere uma ocorrência
  Future<int> addOccurrence(TarefaOcorrencia occ) async {
    final db = await database;
    return db.insert('task_occurrences', occ.toMap());
  }

  // Atualiza uma ocorrência
  Future<int> updateOccurrence(TarefaOcorrencia occ) async {
    final db = await database;
    return db.update(
      'task_occurrences',
      occ.toMap(),
      where: 'id = ?',
      whereArgs: [occ.id],
    );
  }

  // Deleta uma ocorrência
  Future<int> deleteOccurrence(int occurrenceId) async {
    final db = await database;
    return db.delete(
      'task_occurrences',
      where: 'id = ?',
      whereArgs: [occurrenceId],
    );
  }

  // Busca ocorrência específica
  Future<TarefaOcorrencia?> getOccurrenceByDate(int taskId, DateTime date) async {
    final db = await database;
    final result = await db.query(
      'task_occurrences',
      where: 'task_id = ? AND occurrenceDate = ?',
      whereArgs: [taskId, date.toIso8601String()],
    );
    if (result.isNotEmpty) {
      return TarefaOcorrencia.fromMap(result.first);
    }
    return null;
  }

  // Busca todas as ocorrências de uma tarefa
  Future<List<TarefaOcorrencia>> getOccurrencesForTask(int taskId) async {
    final db = await database;
    final result = await db.query(
      'task_occurrences',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
    return result.map((map) => TarefaOcorrencia.fromMap(map)).toList();
  }

}
