import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/expense_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vku_bank_expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY NOT NULL,
        amount REAL NOT NULL,
        transfer_content TEXT NOT NULL,
        category TEXT NOT NULL,
        recipient_name TEXT,
        bank_name TEXT,
        transaction_time TEXT NOT NULL,
        image_path TEXT,
        cloud_image_url TEXT,
        sync_status TEXT DEFAULT 'pending',
        created_at INTEGER NOT NULL
      )
    ''');
  }

  // --- CRUD OPERATIONS ---

  Future<int> insertExpense(ExpenseItem item) async {
    final db = await database;
    return await db.insert(
      'expenses',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExpenseItem>> getAllExpenses() async {
    final db = await database;
    final maps = await db.query(
      'expenses',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => ExpenseItem.fromMap(m)).toList();
  }

  Future<ExpenseItem?> getExpenseById(String id) async {
    final db = await database;
    final maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ExpenseItem.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateExpense(ExpenseItem item) async {
    final db = await database;
    return await db.update(
      'expenses',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteExpense(String id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- SYNC QUERIES ---

  Future<List<ExpenseItem>> getPendingExpenses() async {
    final db = await database;
    final maps = await db.query(
      'expenses',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );
    return maps.map((m) => ExpenseItem.fromMap(m)).toList();
  }

  Future<int> markAsSynced(String id, String cloudImageUrl) async {
    final db = await database;
    return await db.update(
      'expenses',
      {
        'sync_status': 'synced',
        'cloud_image_url': cloudImageUrl,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
