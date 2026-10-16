import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class ChartWidget extends StatelessWidget {
  final List<TransactionModel> transactions;

  const ChartWidget({
    super.key,
    required this.transactions,
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
    final expenses = transactions
        .where((tx) => tx.type == TransactionType.expense)
        .toList();

    final Map<String, double> categoryTotals = {};

    for (final tx in expenses) {
      categoryTotals[tx.category] =
          (categoryTotals[tx.category] ?? 0) + tx.amount;
    }

    final total = categoryTotals.values.fold<double>(
      0,
      (sum, amount) => sum + amount,
    );

    if (total <= 0) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Belum ada data pengeluaran.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 48,
              sections: List.generate(entries.length, (index) {
                final entry = entries[index];
                final percentage = entry.value / total * 100;

                return PieChartSectionData(
                  color: _colors[index % _colors.length],
                  value: entry.value,
                  title: percentage >= 5
                      ? '${percentage.toStringAsFixed(0)}%'
                      : '',
                  radius: 58,
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
        const SizedBox(height: 20),
        ...List.generate(entries.length, (index) {
          final entry = entries[index];
          final percentage = entry.value / total * 100;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _colors[index % _colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF172B4D),
                    ),
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF172B4D),
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