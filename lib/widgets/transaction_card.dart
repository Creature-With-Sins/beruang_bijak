import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/goal_provider.dart';
import '../providers/transaction_provider.dart';
import '../screens/add_transaction_screen.dart';
import '../utils/app_formatters.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final bool showDate;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.showDate = true,
  });

  bool get _isGoalTransaction =>
      transaction.goalId != null ||
      (transaction.category == 'Tabungan' &&
          (transaction.title.startsWith('Nabung:') ||
              transaction.title.startsWith('Tarik Celengan:') ||
              transaction.title.startsWith('Setoran Awal:') ||
              transaction.title.startsWith('Penutupan Celengan:')));

  void _showDetailModal(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? const Color(0xFF16A36A) : const Color(0xFFE05252);
    final formattedAmount = AppFormatters.formatCurrency(transaction.amount);
    final fullDate =
        '${AppFormatters.formatFullDate(transaction.date)}, ${AppFormatters.formatTime(transaction.date)}';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getCategoryIcon(transaction.category),
                      color: color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isIncome ? 'Pemasukan' : 'Pengeluaran',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFEDF0F4),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                label: 'Nominal',
                value: '${isIncome ? '+' : '−'} $formattedAmount',
                valueColor: color,
                isBold: true,
                valueSize: 18,
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                context,
                label: 'Kategori',
                value: transaction.category,
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                context,
                label: 'Tanggal',
                value: fullDate,
              ),
              if (transaction.note != null &&
                  transaction.note!.trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildDetailRow(
                  context,
                  label: 'Catatan',
                  value: transaction.note!,
                ),
              ],
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(modalContext);
                        _confirmDelete(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(
                          color: isDark ? Colors.red.shade900 : const Color(0xFFFFCDD2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      label: const Text('Hapus'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(modalContext);
                        if (_isGoalTransaction) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Transaksi Celengan Impian dikelola otomatis. Gunakan tombol Tabung / Tarik di menu Celengan Impian untuk mengubah saldo.',
                              ),
                              backgroundColor: Color(0xFF087F8C),
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTransactionScreen(
                              transactionToEdit: transaction,
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      label: const Text('Edit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
    double valueSize = 14,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Hapus Transaksi?'),
              content: Text(
                _isGoalTransaction
                    ? 'Transaksi "${transaction.title}" terhubung dengan Celengan Impian. Menghapus transaksi ini akan secara otomatis membatalkan/menyesuaikan saldo di celengan terkait agar pembukuan kas tetap seimbang.'
                    : 'Transaksi "${transaction.title}" akan dihapus permanen.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Hapus'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmed && context.mounted) {
      final goalProv = context.read<GoalProvider>();
      final txProv = context.read<TransactionProvider>();
      if (_isGoalTransaction) {
        await goalProv.adjustGoalOnTransactionDeleted(transaction);
      }
      await txProv.deleteTransaction(transaction.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isGoalTransaction
                  ? 'Transaksi dihapus & saldo Celengan terkait telah disesuaikan.'
                  : 'Transaksi berhasil dihapus.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == TransactionType.income;

    final Color transactionColor =
        isIncome ? const Color(0xFF16A36A) : const Color(0xFFE05252);

    final String formattedAmount =
        AppFormatters.formatCurrency(transaction.amount);

    final String subtitleText = showDate
        ? '${transaction.category} • ${AppFormatters.formatDate(transaction.date)} • ${AppFormatters.formatTime(transaction.date)}'
        : '${transaction.category} • ${AppFormatters.formatTime(transaction.date)}';

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text('Hapus Transaksi?'),
                  content: Text(
                    _isGoalTransaction
                        ? 'Transaksi "${transaction.title}" terhubung dengan Celengan Impian. Menghapus transaksi ini akan menyesuaikan saldo celengan terkait agar pembukuan tetap seimbang.'
                        : 'Transaksi "${transaction.title}" akan dihapus.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Hapus'),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      onDismissed: (_) async {
        final goalProv = context.read<GoalProvider>();
        final txProv = context.read<TransactionProvider>();
        if (_isGoalTransaction) {
          await goalProv.adjustGoalOnTransactionDeleted(transaction);
        }
        await txProv.deleteTransaction(transaction.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isGoalTransaction
                    ? 'Transaksi dihapus & saldo Celengan telah disesuaikan'
                    : 'Transaksi berhasil dihapus',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailModal(context),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF334155)
                    : const Color(0xFFEDF0F4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.2
                        : 0.025,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Ikon kategori
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: transactionColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getCategoryIcon(transaction.category),
                    color: transactionColor,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 12),

                // Informasi transaksi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF94A3B8)
                              : Colors.grey,
                        ),
                      ),
                      if (transaction.note != null &&
                          transaction.note!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          transaction.note!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF64748B)
                                : Colors.blueGrey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Nominal transaksi
                Flexible(
                  child: Text(
                    '${isIncome ? '+' : '−'}$formattedAmount',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: transactionColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Icons.restaurant_rounded;

      case 'transport':
      case 'transportasi':
        return Icons.directions_car_rounded;

      case 'gaji':
      case 'pemasukan':
        return Icons.account_balance_wallet_rounded;

      case 'belanja':
        return Icons.shopping_bag_rounded;

      case 'hiburan':
        return Icons.movie_rounded;

      case 'kesehatan':
        return Icons.health_and_safety_rounded;

      case 'pendidikan':
        return Icons.school_rounded;

      case 'tagihan':
        return Icons.receipt_long_rounded;

      case 'tabungan':
      case 'celengan':
        return Icons.savings_rounded;

      case 'investasi':
        return Icons.trending_up_rounded;

      case 'bonus':
        return Icons.card_giftcard_rounded;

      default:
        return Icons.category_rounded;
    }
  }
}
