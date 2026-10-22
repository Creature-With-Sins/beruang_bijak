import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utils/app_formatters.dart';

class ChartWidget extends StatelessWidget {
  final List<TransactionModel> transactions;
  final TransactionType type;

  const ChartWidget({
    super.key,
    required this.transactions,
    this.type = TransactionType.expense,
  });

  static const List<Color> _colors = [
    Color(0xFF087F8C),
    Color(0xFF16A6A1),
    Color(0xFFFFB74D),
    Color(0xFFE57373),
    Color(0xFF7986CB),
    Color(0xFF9575CD),
    Color(0xFF4DB6AC),
    Color(0xFF90A4AE),
  ];



  @override
  Widget build(BuildContext context) {
    final filtered = transactions.where((tx) => tx.type == type).toList();

    final Map<String, double> categoryTotals = {};

    for (final tx in filtered) {
      categoryTotals[tx.category] =
          (categoryTotals[tx.category] ?? 0) + tx.amount;
    }

    final total = categoryTotals.values.fold<double>(
      0,
      (sum, amount) => sum + amount,
    );

    if (total <= 0) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 42,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 10),
              Text(
                type == TransactionType.expense
                    ? 'Belum ada data pengeluaran pada periode ini.'
                    : 'Belum ada data pemasukan pada periode ini.',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 44,
              sections: List.generate(entries.length, (index) {
                final entry = entries[index];
                final percentage = entry.value / total * 100;

                return PieChartSectionData(
                  color: _colors[index % _colors.length],
                  value: entry.value,
                  title: percentage >= 8
                      ? '${percentage.toStringAsFixed(0)}%'
                      : '',
                  radius: 54,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 22),
        ...List.generate(entries.length, (index) {
          final entry = entries[index];
          final percentage = entry.value / total * 100;
          final color = _colors[index % _colors.length];
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      AppFormatters.formatCurrency(entry.value),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 5,
                    backgroundColor: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFF0F3F6),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}