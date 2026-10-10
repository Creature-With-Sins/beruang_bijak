import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  // Data Dummy Awal buat Testing UI Tim
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: const Uuid().v4(),
      title: 'Transfer Uang Saku',
      amount: 1500000,
      type: TransactionType.income,
      category: 'Pemasukan',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TransactionModel(
      id: const Uuid().v4(),
      title: 'Makan Siang Warteg',
      amount: 25000,
      type: TransactionType.expense,
      category: 'Makanan',
      date: DateTime.now(),
      note: 'Ayam + Es Teh',
    ),
  ];

  List<TransactionModel> get transactions => [..._transactions];

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

  // Fungsi Tambah Transaksi (Dikerjakan Anggota 1 & dipanggil Anggota 2)
  void addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    String? note,
  }) {
    final newTx = TransactionModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note,
    );

    _transactions.insert(0, newTx); // Tambah ke urutan paling atas
    notifyListeners(); // Otomatis refresh UI di semua screen!
  }

  // Fungsi Hapus Transaksi
  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }
}