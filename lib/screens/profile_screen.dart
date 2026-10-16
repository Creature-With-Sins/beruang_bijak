import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _dailyBudget = 100000;
  double _monthlyBudget = 3000000;

  String _formatRupiah(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _editBudget({required bool monthly}) async {
    final currentBudget = monthly ? _monthlyBudget : _dailyBudget;

    final controller = TextEditingController(
      text: currentBudget.toStringAsFixed(0),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            monthly ? 'Budget Bulanan' : 'Budget Harian',
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              labelText: 'Batas pengeluaran (Rupiah)',
              prefixText: 'Rp ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(controller.text);

                if (value == null || value <= 0) {
                  return;
                }

                Navigator.pop(dialogContext, value);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result != null && mounted) {
      setState(() {
        if (monthly) {
          _monthlyBudget = result;
        } else {
          _dailyBudget = result;
        }
      });
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEDF0F4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172B4D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard({
    required String title,
    required String period,
    required double spent,
    required double budget,
    required VoidCallback onEdit,
    required IconData icon,
  }) {
    final progress = (spent / budget).clamp(0.0, 1.0);
    final exceeded = spent > budget;

    final color = exceeded
        ? const Color(0xFFE57373)
        : const Color(0xFF16A6A1);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDF0F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      period,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Ubah budget',
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF087F8C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _formatRupiah(spent),
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172B4D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'dari ${_formatRupiah(budget)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFEDF0F4),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            exceeded
                ? 'Budget terlampaui sebesar '
                    '${_formatRupiah(spent - budget)}'
                : 'Sisa budget ${_formatRupiah(budget - spent)}',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.transactions;
    final now = DateTime.now();

    final todayExpense = transactions
        .where(
          (tx) =>
              tx.type == TransactionType.expense &&
              tx.date.year == now.year &&
              tx.date.month == now.month &&
              tx.date.day == now.day,
        )
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final monthlyExpense = transactions
        .where(
          (tx) =>
              tx.type == TransactionType.expense &&
              tx.date.year == now.year &&
              tx.date.month == now.month,
        )
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Profil & Pengaturan',
          style: TextStyle(
            color: Color(0xFF172B4D),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF087F8C),
                    Color(0xFF16A6A1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengguna Pocket Budget',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Kelola keuanganmu dengan lebih teratur.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'Ringkasan Keuangan',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildStatCard(
                  title: 'Pemasukan',
                  value: _formatRupiah(provider.totalIncome),
                  icon: Icons.south_west_rounded,
                  color: const Color(0xFF16A6A1),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  title: 'Pengeluaran',
                  value: _formatRupiah(provider.totalExpense),
                  icon: Icons.north_east_rounded,
                  color: const Color(0xFFE57373),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEDF0F4)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: Color(0xFF087F8C),
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Total transaksi tercatat',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                  ),
                  Text(
                    '${transactions.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF087F8C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Pengaturan Budget',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Atur batas pengeluaran agar keuangan lebih terkendali.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 14),
            _buildBudgetCard(
              title: 'Budget Harian',
              period: 'Pengeluaran hari ini',
              spent: todayExpense,
              budget: _dailyBudget,
              icon: Icons.today_rounded,
              onEdit: () => _editBudget(monthly: false),
            ),
            const SizedBox(height: 12),
            _buildBudgetCard(
              title: 'Budget Bulanan',
              period: DateFormat('MMMM yyyy', 'id_ID').format(now),
              spent: monthlyExpense,
              budget: _monthlyBudget,
              icon: Icons.calendar_month_rounded,
              onEdit: () => _editBudget(monthly: true),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                'Pocket Budget • Pengelolaan Keuangan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}