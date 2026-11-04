import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/csv_export_service.dart';
import '../services/pdf_report_service.dart';
import '../utils/app_formatters.dart';

class PdfPreviewScreen extends StatefulWidget {
  final DateTime initialMonth;

  const PdfPreviewScreen({super.key, required this.initialMonth});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  Future<void> _exportCsv({
    required String username,
    required List<dynamic> transactions,
  }) async {
    final csvBytes = CsvExportService.generateMonthlyReportCsv(
      month: _selectedMonth,
      username: username,
      transactions: transactions.cast(),
    );

    final csvFileName =
        'Laporan_Keuangan_${_selectedMonth.year}_${_selectedMonth.month.toString().padLeft(2, '0')}.csv';

    await Printing.sharePdf(
      bytes: csvBytes,
      filename: csvFileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allTransactions = context.watch<TransactionProvider>().transactions;
    final username = context.watch<AuthProvider>().currentUsername ?? 'Pengguna';

    final monthlyTransactions = allTransactions.where((tx) {
      return tx.date.year == _selectedMonth.year && tx.date.month == _selectedMonth.month;
    }).toList();

    final monthTitle = AppFormatters.formatMonthYear(_selectedMonth);
    final fileName = 'Laporan_Keuangan_${_selectedMonth.year}_${_selectedMonth.month.toString().padLeft(2, '0')}.pdf';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Laporan PDF & Excel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Export ke CSV / Excel',
            icon: const Icon(Icons.table_chart_rounded),
            onPressed: () => _exportCsv(
              username: username,
              transactions: monthlyTransactions,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Month Selector Header
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFEDF0F4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(Icons.chevron_left_rounded),
                    tooltip: 'Bulan sebelumnya',
                  ),
                  Column(
                    children: [
                      Text(
                        monthTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${monthlyTransactions.length} transaksi tercatat',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right_rounded),
                    tooltip: 'Bulan berikutnya',
                  ),
                ],
              ),
            ),

            // Banner Export Excel & info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: InkWell(
                onTap: () => _exportCsv(
                  username: username,
                  transactions: monthlyTransactions,
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF134E4A).withValues(alpha: 0.3)
                        : const Color(0xFFE6F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFB5E4E0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.table_view_rounded,
                        color: Color(0xFF087F8C),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Ingin buka di Excel? Ketuk untuk Export CSV',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF087F8C),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Color(0xFF087F8C),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // PDF Viewer / Action Widget
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: PdfPreview(
                  key: ValueKey('${_selectedMonth.year}_${_selectedMonth.month}'),
                  build: (format) => PdfReportService.generateMonthlyReport(
                    month: _selectedMonth,
                    username: username,
                    transactions: monthlyTransactions,
                  ),
                  pdfFileName: fileName,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  loadingWidget: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: theme.colorScheme.primary),
                        const SizedBox(height: 12),
                        const Text(
                          'Menyiapkan dokumen PDF...',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
