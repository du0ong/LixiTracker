import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/li_xi_transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lixi.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(LiXiTransaction tx) async {
    final db = await instance.database;
    return await db.insert('transactions', {
      'name': tx.name,
      'amount': tx.amount,
      'type': tx.type.name,
      'date': tx.date.toIso8601String(),
      'category': tx.category,
    });
  }

  Future<int> update(LiXiTransaction tx) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      {
        'name': tx.name,
        'amount': tx.amount,
        'type': tx.type.name,
        'date': tx.date.toIso8601String(),
        'category': tx.category,
      },
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  Future<List<LiXiTransaction>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) {
      return LiXiTransaction(
        id: json['id'] as int?,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] == 'received' ? LiXiType.received : LiXiType.given,
        date: DateTime.parse(json['date'] as String),
        category: json['category'] as String,
      );
    }).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
