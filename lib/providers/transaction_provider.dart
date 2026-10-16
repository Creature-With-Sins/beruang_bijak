import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => [..._transactions];

  TransactionProvider() {
    loadTransactions(); // Otomatis muat data dari SQLite saat provider dibuat
  }

  // Muat Data dari SQLite
  Future<void> loadTransactions() async {
    _transactions = await DatabaseHelper.instance.getAllTransactions();
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
    notifyListeners();
  }

  // Hapus Transaksi Dari Memory & SQLite
  Future<void> deleteTransaction(String id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }
}