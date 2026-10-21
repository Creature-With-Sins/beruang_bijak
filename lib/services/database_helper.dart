import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('beruang_bijak.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Membuat tabel transaksi di SQLite
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        userId TEXT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  // Migrasi database dari versi lama ke baru
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN userId TEXT;');
    }
  }

  // 1. Simpan Transaksi Baru
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  // 2. Ambil Semua Data Transaksi (Opsional Filter per User)
  Future<List<TransactionModel>> getAllTransactions({String? userId}) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result;

    if (userId != null && userId.isNotEmpty) {
      result = await db.query(
        'transactions',
        where: 'userId = ? OR userId IS NULL',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );
    } else {
      result = await db.query('transactions', orderBy: 'date DESC');
    }

    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  // 3. Update Transaksi
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // 4. Hapus Transaksi Berdasarkan ID
  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}