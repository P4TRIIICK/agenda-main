import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tarefa.dart';
import '../models/prioridade.dart';
import '../models/status.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  static Database? _database;

  DatabaseService._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa o banco de dados
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Criação das tabelas
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
        categoria TEXT NOT NULL
      )
    ''');
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
}
