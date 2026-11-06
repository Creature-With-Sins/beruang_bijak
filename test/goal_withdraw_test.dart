import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

import 'package:beruang_bijak/models/transaction_model.dart';
import 'package:beruang_bijak/providers/goal_provider.dart';
import 'package:beruang_bijak/providers/transaction_provider.dart';
import 'package:beruang_bijak/services/database_helper.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    // Reset database for clean test run
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'beruang_bijak.db');
    await databaseFactory.deleteDatabase(path);
    // Also reset any cached database in DatabaseHelper
    final db = await DatabaseHelper.instance.database;
    await db.delete('transactions');
  });

  test('Test deposit and withdraw interaction with TransactionProvider', () async {
    final txProv = TransactionProvider();
    final goalProv = GoalProvider();
    await txProv.loadTransactions();
    await goalProv.loadGoals();

    // 1. Initial State: Saldo 0
    expect(txProv.totalIncome, 0.0);
    expect(txProv.totalExpense, 0.0);
    expect(txProv.totalBalance, 0.0);

    // 2. User has initial Income: Gaji Rp 1.000.000
    await txProv.addTransaction(
      title: 'Gaji',
      amount: 1000000,
      type: TransactionType.income,
      category: 'Gaji',
      date: DateTime.now(),
    );
    expect(txProv.totalIncome, 1000000.0);
    expect(txProv.totalBalance, 1000000.0);

    // 3. User creates a goal "Beli HP" target 2.000.000, and deposits 200.000
    await goalProv.addGoal(
      title: 'Beli HP',
      targetAmount: 2000000,
      initialAmount: 0,
      category: 'Elektronik',
    );
    final goal = goalProv.goals.first;

    // Deposit Rp 200.000 into Celengan, recordAsExpense: true (Category: Tabungan)
    await goalProv.deposit(goal.id, 200000);
    await txProv.addTransaction(
      title: 'Nabung: ${goal.title}',
      amount: 200000,
      type: TransactionType.expense,
      category: 'Tabungan',
      date: DateTime.now(),
      note: 'Alokasi ke Celengan Impian (${goal.title})',
    );

    expect(goalProv.goals.first.savedAmount, 200000.0);
    expect(txProv.totalExpense, 200000.0);
    expect(txProv.totalBalance, 800000.0);

    // 4. User withdraws Rp 200.000 from Celengan, recordAsIncome: true (Category: Tabungan)
    await goalProv.withdraw(goal.id, 200000);
    await txProv.addTransaction(
      title: 'Tarik Celengan: ${goal.title}',
      amount: 200000,
      type: TransactionType.income,
      category: 'Tabungan',
      date: DateTime.now(),
      note: 'Penarikan dari Celengan Impian (${goal.title})',
    );

    expect(goalProv.goals.first.savedAmount, 0.0);
    expect(txProv.totalIncome, 1200000.0);
    expect(txProv.totalExpense, 200000.0);
    expect(txProv.totalBalance, 1000000.0);
  });
}


