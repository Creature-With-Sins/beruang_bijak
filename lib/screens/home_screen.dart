import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_formatters.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onMenuPressed;

  const HomeScreen({super.key, required this.onMenuPressed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedFilterIndex = 0; // 0: Semua, 1: Pengeluaran, 2: Pemasukan

  // Format mata uang diambil dari AppFormatters terpusat

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final authProvider = context.watch<AuthProvider>();
    final allTransactions = provider.transactions;

    final username = authProvider.currentUsername ?? 'Pengguna';

    // Filter transactions based on selected tab
    final transactions = allTransactions.where((tx) {
      if (_selectedFilterIndex == 1) {
        return tx.type == TransactionType.expense;
      } else if (_selectedFilterIndex == 2) {
        return tx.type == TransactionType.income;
      }
      return true;
    }).toList();

    // Hitung pengeluaran bulan ini untuk budget progress
    final now = DateTime.now();
    final monthlyExpense = allTransactions
        .where(
          (tx) =>
              tx.type == TransactionType.expense &&
              tx.date.year == now.year &&
              tx.date.month == now.month,
        )
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final monthlyBudget = provider.monthlyBudget;
    final budgetProgress =
        monthlyBudget > 0 ? (monthlyExpense / monthlyBudget).clamp(0.0, 1.0) : 0.0;
    final isBudgetOver = monthlyExpense > monthlyBudget && monthlyBudget > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        leading: IconButton(
          tooltip: 'Buka menu',
          onPressed: widget.onMenuPressed,
          icon: const Icon(Icons.menu_rounded, color: Color(0xFF172B4D)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, $username 👋',
              style: const TextStyle(
                color: Color(0xFF172B4D),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Text(
              'Beruang Bijak • Kelola Keuangan',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF087F8C).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      const Color(0xFF087F8C).withValues(alpha: 0.15),
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Color(0xFF087F8C),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            // Kartu saldo utama
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF087F8C), Color(0xFF16A6A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF087F8C).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Total Saldo Anda',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppFormatters.formatCurrency(provider.totalBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryItem(
                          icon: Icons.south_west_rounded,
                          label: 'Pemasukan',
                          amount: AppFormatters.formatCurrency(provider.totalIncome),
                          iconColor: const Color(0xFFA7F3D0),
                        ),
                      ),
                      Container(width: 1, height: 36, color: Colors.white24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SummaryItem(
                          icon: Icons.north_east_rounded,
                          label: 'Pengeluaran',
                          amount: AppFormatters.formatCurrency(provider.totalExpense),
                          iconColor: const Color(0xFFFECDD3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Mini Budget Progress Indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEDF0F4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pie_chart_outline_rounded,
                            size: 18,
                            color: isBudgetOver
                                ? Colors.red
                                : const Color(0xFF087F8C),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Budget Bulanan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${(budgetProgress * 100).toStringAsFixed(0)}% terpakai',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isBudgetOver
                              ? Colors.red
                              : const Color(0xFF087F8C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: budgetProgress,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFEDF0F4),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isBudgetOver ? Colors.red : const Color(0xFF16A6A1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBudgetOver
                        ? 'Melebihi budget sebesar ${AppFormatters.formatCurrency(monthlyExpense - monthlyBudget)}'
                        : 'Sisa budget ${AppFormatters.formatCurrency(monthlyBudget - monthlyExpense)} dari ${AppFormatters.formatCurrency(monthlyBudget)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isBudgetOver ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Filter Tabs
            Row(
              children: [
                _FilterChipTab(
                  label: 'Semua',
                  count: allTransactions.length,
                  isSelected: _selectedFilterIndex == 0,
                  onTap: () => setState(() => _selectedFilterIndex = 0),
                ),
                const SizedBox(width: 8),
                _FilterChipTab(
                  label: 'Pengeluaran',
                  count: allTransactions
                      .where((tx) => tx.type == TransactionType.expense)
                      .length,
                  isSelected: _selectedFilterIndex == 1,
                  onTap: () => setState(() => _selectedFilterIndex = 1),
                ),
                const SizedBox(width: 8),
                _FilterChipTab(
                  label: 'Pemasukan',
                  count: allTransactions
                      .where((tx) => tx.type == TransactionType.income)
                      .length,
                  isSelected: _selectedFilterIndex == 2,
                  onTap: () => setState(() => _selectedFilterIndex = 2),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Judul daftar transaksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaksi Terbaru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172B4D),
                  ),
                ),
                Text(
                  transactions.length > 5
                      ? '5 dari ${transactions.length}'
                      : '${transactions.length} transaksi',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (transactions.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 42,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEDF0F4)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 32,
                        color: Color(0xFF087F8C),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Belum ada transaksi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tekan tombol di bawah untuk mencatat transaksi pertamamu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddTransactionScreen(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF087F8C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Tambah Transaksi'),
                    ),
                  ],
                ),
              )
            else ...[
              ...transactions.take(5).map(
                (transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TransactionCard(transaction: transaction),
                ),
              ),
              if (transactions.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text('Lihat Seluruh Riwayat Transaksi'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF087F8C),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),

      // Tombol tambah transaksi
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        backgroundColor: const Color(0xFF087F8C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Transaksi'),
      ),
    );
  }
}

class _FilterChipTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipTab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF087F8C) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF087F8C)
                  : const Color(0xFFEDF0F4),
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF172B4D),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color iconColor;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.amount,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
