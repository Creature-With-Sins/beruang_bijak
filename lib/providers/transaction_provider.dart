import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  String? _currentUserId;

  List<TransactionModel> get transactions => [..._transactions];

  // Set User ID & muat data spesifik milik user tersebut
  Future<void> loadTransactionsForUser(String userId) async {
    _currentUserId = userId;
    _transactions = await DatabaseHelper.instance.getTransactionsByUserId(userId);
    notifyListeners();
  }

  // Hitung Total Pemasukan khusus user aktif
  double get totalIncome {
    return _transactions
        .where((item) => item.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Hitung Total Pengeluaran khusus user aktif
  double get totalExpense {
    return _transactions
        .where((item) => item.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Total Sisa Saldo khusus user aktif
  double get totalBalance => totalIncome - totalExpense;

  // Tambah Transaksi Ke Memory & SQLite milik user aktif
  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    if (_currentUserId == null) return;

    final newTx = TransactionModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note,
    );

    // Simpan ke SQLite dengan membawa ID user
    await DatabaseHelper.instance.insertTransaction(newTx, _currentUserId!);

    _transactions.insert(0, newTx);
    notifyListeners();
  }

  // Hapus Transaksi Dari Memory & SQLite
  Future<void> deleteTransaction(String id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }

  // Reset memori transaksi saat user logout
  void clearOnLogout() {
    _currentUserId = null;
    _transactions = [];
    notifyListeners();
  }
}