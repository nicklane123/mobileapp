import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/message.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'messages.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            imagePath TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertMessage(Message msg) async {
    final db = await database;
    return await db.insert('messages', msg.toMap());
  }

  Future<List<Message>> getMessages() async {
    final db = await database;
    final result = await db.query('messages', orderBy: 'createdAt DESC');
    return result.map((e) => Message.fromMap(e)).toList();
  }

  Future<int> deleteMessage(int id) async {
    final db = await database;
    return await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteMultiple(List<int> ids) async {
    final db = await database;
    final idList = ids.join(',');
    await db.rawDelete('DELETE FROM messages WHERE id IN ($idList)');
  }

  Future<int> updateMessage(Message msg) async {
    final db = await database;
    return await db.update(
      'messages',
      msg.toMap(),
      where: 'id = ?',
      whereArgs: [msg.id],
    );
  }
}
