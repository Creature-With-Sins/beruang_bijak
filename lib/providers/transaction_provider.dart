import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  static const String _dailyBudgetKey = 'daily_budget';
  static const String _monthlyBudgetKey = 'monthly_budget';

  List<TransactionModel> _transactions = [];
  double _dailyBudget = 100000;
  double _monthlyBudget = 3000000;
  String? _currentUserId;

  List<TransactionModel> get transactions => [..._transactions];
  double get dailyBudget => _dailyBudget;
  double get monthlyBudget => _monthlyBudget;
  String? get currentUserId => _currentUserId;

  TransactionProvider() {
    loadTransactions(); // Otomatis muat data dari SQLite saat provider dibuat
    loadBudgets(); // Muat batas budget dari SharedPreferences
  }

  /// Sinkronkan user yang aktif ke provider transaksi
  void setCurrentUser(String? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      loadTransactions();
      loadBudgets();
    }
  }

  // Muat Data dari SQLite sesuai User Aktif
  Future<void> loadTransactions() async {
    _transactions = await DatabaseHelper.instance.getAllTransactions(
      userId: _currentUserId,
    );
    notifyListeners();
  }

  // Muat Data Budget dari SharedPreferences
  Future<void> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final userSuffix = _currentUserId != null && _currentUserId!.isNotEmpty
        ? '_$_currentUserId'
        : '';
    _dailyBudget = prefs.getDouble('$_dailyBudgetKey$userSuffix') ?? 100000;
    _monthlyBudget =
        prefs.getDouble('$_monthlyBudgetKey$userSuffix') ?? 3000000;
    notifyListeners();
  }

  // Simpan Budget Harian
  Future<void> setDailyBudget(double amount) async {
    _dailyBudget = amount;
    final prefs = await SharedPreferences.getInstance();
    final userSuffix = _currentUserId != null && _currentUserId!.isNotEmpty
        ? '_$_currentUserId'
        : '';
    await prefs.setDouble('$_dailyBudgetKey$userSuffix', amount);
    notifyListeners();
  }

  // Simpan Budget Bulanan
  Future<void> setMonthlyBudget(double amount) async {
    _monthlyBudget = amount;
    final prefs = await SharedPreferences.getInstance();
    final userSuffix = _currentUserId != null && _currentUserId!.isNotEmpty
        ? '_$_currentUserId'
        : '';
    await prefs.setDouble('$_monthlyBudgetKey$userSuffix', amount);
    notifyListeners();
  }

  // Hitung Total Pemasukan
  double get totalIncome {
    return _transactions
        .where((item) => item.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Hitung Total Pengeluaran
  double get totalExpense {
    return _transactions
        .where((item) => item.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Total Sisa Saldo
  double get totalBalance => totalIncome - totalExpense;

  // Tambah Transaksi Ke Memory & SQLite
  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    final newTx = TransactionModel(
      id: const Uuid().v4(),
      userId: _currentUserId,
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note,
    );

    // Simpan ke SQLite
    await DatabaseHelper.instance.insertTransaction(newTx);

    _transactions.insert(0, newTx);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  // Perbarui Transaksi
  Future<void> updateTransaction({
    required String id,
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    final updatedTx = TransactionModel(
      id: id,
      userId: _currentUserId,
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note,
    );

    await DatabaseHelper.instance.updateTransaction(updatedTx);

    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index != -1) {
      _transactions[index] = updatedTx;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  // Hapus Transaksi Dari Memory & SQLite
  Future<void> deleteTransaction(String id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }
}