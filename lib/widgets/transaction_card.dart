import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == TransactionType.income;

    final Color transactionColor =
        isIncome ? const Color(0xFF16A36A) : const Color(0xFFE05252);

    final String formattedAmount = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(transaction.amount);

    final String formattedDate = DateFormat(
      'dd MMM yyyy',
      'id_ID',
    ).format(transaction.date);

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
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text('Hapus Transaksi?'),
                  content: Text(
                    'Transaksi "${transaction.title}" akan dihapus.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext, false);
                      },
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext, true);
                      },
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      onDismissed: (direction) {
        context.read<TransactionProvider>().deleteTransaction(transaction.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil dihapus'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEDF0F4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF172B4D),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${transaction.category} • $formattedDate',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  if (transaction.note != null &&
                      transaction.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      transaction.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.blueGrey,
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

      default:
        return Icons.category_rounded;
    }
  }
}
