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
    // Reset database & prefs for clean test run
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.delete('transactions');
  });

  test('Test synced goal (isSyncedWithWallet: true) automatically syncs deposit & withdrawal with Kas Utama', () async {
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

    // 3. User creates a synced goal "Beli HP" target 2.000.000 (isSyncedWithWallet: true)
    await goalProv.addGoal(
      title: 'Beli HP',
      targetAmount: 2000000,
      initialAmount: 0,
      category: 'Elektronik',
      isSyncedWithWallet: true,
    );
    final goal = goalProv.goals.first;
    expect(goal.isSyncedWithWallet, isTrue);

    // Deposit Rp 200.000 into Celengan, synced mode: deducts wallet
    await goalProv.deposit(goal.id, 200000);
    if (goal.isSyncedWithWallet) {
      await txProv.addTransaction(
        title: 'Nabung: ${goal.title}',
        amount: 200000,
        type: TransactionType.expense,
        category: 'Tabungan',
        date: DateTime.now(),
        note: 'Alokasi ke Celengan Impian (${goal.title})',
      );
    }

    expect(goalProv.goals.first.savedAmount, 200000.0);
    expect(txProv.totalExpense, 200000.0);
    expect(txProv.totalBalance, 800000.0);

    // Withdraw Rp 200.000 from Celengan, synced mode: restores wallet
    await goalProv.withdraw(goal.id, 200000);
    if (goal.isSyncedWithWallet) {
      await txProv.addTransaction(
        title: 'Tarik Celengan: ${goal.title}',
        amount: 200000,
        type: TransactionType.income,
        category: 'Tabungan',
        date: DateTime.now(),
        note: 'Penarikan dari Celengan Impian (${goal.title})',
      );
    }

    expect(goalProv.goals.first.savedAmount, 0.0);
    expect(txProv.totalIncome, 1200000.0);
    expect(txProv.totalExpense, 200000.0);
    expect(txProv.totalBalance, 1000000.0);
  });

  test('Test standalone goal (isSyncedWithWallet: false) does not affect Kas Utama', () async {
    final txProv = TransactionProvider();
    final goalProv = GoalProvider();
    await txProv.loadTransactions();
    await goalProv.loadGoals();

    // 1. Initial income
    await txProv.addTransaction(
      title: 'Gaji',
      amount: 1000000,
      type: TransactionType.income,
      category: 'Gaji',
      date: DateTime.now(),
    );
    expect(txProv.totalBalance, 1000000.0);

    // 2. User creates a standalone goal (celengan fisik di kamar)
    await goalProv.addGoal(
      title: 'Celengan Fisik Ayam',
      targetAmount: 500000,
      initialAmount: 0,
      category: 'Lainnya',
      isSyncedWithWallet: false,
    );
    final standaloneGoal = goalProv.goals.first;
    expect(standaloneGoal.isSyncedWithWallet, isFalse);

    // Deposit Rp 100.000 into standalone goal: wallet balance untouched!
    await goalProv.deposit(standaloneGoal.id, 100000);
    if (standaloneGoal.isSyncedWithWallet) {
      await txProv.addTransaction(
        title: 'Nabung: ${standaloneGoal.title}',
        amount: 100000,
        type: TransactionType.expense,
        category: 'Tabungan',
        date: DateTime.now(),
      );
    }

    expect(goalProv.goals.first.savedAmount, 100000.0);
    expect(txProv.totalExpense, 0.0); // No expense recorded!
    expect(txProv.totalBalance, 1000000.0); // Wallet balance completely unchanged!

    // Withdraw Rp 50.000 from standalone goal: wallet balance untouched!
    await goalProv.withdraw(standaloneGoal.id, 50000);
    if (standaloneGoal.isSyncedWithWallet) {
      await txProv.addTransaction(
        title: 'Tarik Celengan: ${standaloneGoal.title}',
        amount: 50000,
        type: TransactionType.income,
        category: 'Tabungan',
        date: DateTime.now(),
      );
    }

    expect(goalProv.goals.first.savedAmount, 50000.0);
    expect(txProv.totalIncome, 1000000.0); // No new income recorded!
    expect(txProv.totalBalance, 1000000.0); // Wallet balance stays exactly 1.000.000!
  });
}


