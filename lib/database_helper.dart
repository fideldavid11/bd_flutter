import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqlite_flutter/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database?
      _database; // Cambiamos a tipo 'Database?' para permitir nulos

  DatabaseHelper._privateConstructor();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initDatabase();
    return _database;
  }

  Future<Database?> initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, completed INTEGER)",
        );
      },
    );
    return _database;
  }

  Future<int> insertTask(Task task) async {
    final db = await database;

    // Genera un valor de 'id' único (puedes adaptarlo a tus necesidades)
    task.id = (await db
        ?.rawQuery("SELECT COALESCE(MAX(id), 0) + 1 AS id FROM tasks")
        .then((value) => value[0]['id'] as int?))!;

    final result = await db?.insert('tasks', task.toMap()) ?? 0;
    return result;
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>>? maps = await db?.query('tasks');
    return List.generate(maps?.length ?? 0, (i) {
      return Task.fromMap(maps?[i] ?? {});
    });
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    final result = await db?.update(
          'tasks',
          task.toMap(),
          where: 'id = ?',
          whereArgs: [task.id],
        ) ??
        0;
    return result;
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    final result =
        await db?.delete('tasks', where: 'id = ?', whereArgs: [id]) ?? 0;
    return result;
  }
}
