import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finance.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT DEFAULT '💡'
      );
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT CHECK(type IN ('income','expense')) NOT NULL,
        category_id INTEGER NOT NULL,
        note TEXT DEFAULT '',
        FOREIGN KEY(category_id) REFERENCES categories(id)
      );
    ''');

    // seed kategori dasar
    final seeds = [
      CategoryModel(name: 'Gaji', icon: '💼'),
      CategoryModel(name: 'Makan', icon: '🍜'),
      CategoryModel(name: 'Transport', icon: '🚌'),
      CategoryModel(name: 'Belanja', icon: '🛍️'),
      CategoryModel(name: 'Lainnya', icon: '✨'),
    ];
    for (final c in seeds) {
      await db.insert('categories', c.toMap());
    }
  }

  // Categories
  Future<List<CategoryModel>> getCategories() async {
    final db = await database;
    final res = await db.query('categories', orderBy: 'name ASC');
    return res.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<int> addCategory(CategoryModel c) async {
    final db = await database;
    return db.insert('categories', c.toMap());
  }

  // Transactions
  Future<int> addTransaction(TransactionModel t) async {
    final db = await database;
    return db.insert('transactions', t.toMap());
  }

  Future<int> updateTransaction(TransactionModel t) async {
    final db = await database;
    return db.update('transactions', t.toMap(),
        where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TransactionModel>> getTransactions({DateTime? month}) async {
    final db = await database;
    String? where;
    List<Object?> args = [];
    if (month != null) {
      final start =
          DateTime(month.year, month.month, 1).toIso8601String();
      final end =
          DateTime(month.year, month.month + 1, 1).toIso8601String();
      where = 'date >= ? AND date < ?';
      args = [start, end];
    }
    final res = await db.query('transactions',
        where: where, whereArgs: args, orderBy: 'date DESC');
    return res.map((e) => TransactionModel.fromMap(e)).toList();
  }

  Future<double> sumByType(TxType type, {DateTime? month}) async {
    final db = await database;
    String where = 'type = ?';
    List<Object?> args = [type.name];
    if (month != null) {
      final start =
          DateTime(month.year, month.month, 1).toIso8601String();
      final end =
          DateTime(month.year, month.month + 1, 1).toIso8601String();
      where += ' AND date >= ? AND date < ?';
      args.addAll([start, end]);
    }
    final res = await db.rawQuery(
        'SELECT SUM(amount) as total FROM transactions WHERE $where', args);
    final total = res.first['total'] as num?;
    return (total ?? 0).toDouble();
  }
}
