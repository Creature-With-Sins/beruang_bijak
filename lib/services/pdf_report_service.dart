import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/transaction_model.dart';
import '../utils/app_formatters.dart';

class PdfReportService {
  PdfReportService._();

  static const PdfColor _primaryColor = PdfColor.fromInt(0xFF087F8C);
  static const PdfColor _incomeColor = PdfColor.fromInt(0xFF16A36A);
  static const PdfColor _expenseColor = PdfColor.fromInt(0xFFDC2626);
  static const PdfColor _textDark = PdfColor.fromInt(0xFF0F172A);
  static const PdfColor _textMuted = PdfColor.fromInt(0xFF475569);
  static const PdfColor _borderLight = PdfColor.fromInt(0xFFCBD5E1);
  static const PdfColor _bgLight = PdfColor.fromInt(0xFFF1F5F9);

  /// Menghasilkan file PDF bytes untuk laporan bulanan
  static Future<Uint8List> generateMonthlyReport({
    required DateTime month,
    required String username,
    required List<TransactionModel> transactions,
  }) async {
    final pdf = pw.Document();

    final monthTitle = AppFormatters.formatMonthYear(month);
    final printDate = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now());

    // Hitung total pemasukan dan pengeluaran
    final monthlyIncome = transactions
        .where((tx) => tx.type == TransactionType.income)
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final monthlyExpense = transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final netCashFlow = monthlyIncome - monthlyExpense;
    final isSurplus = netCashFlow >= 0;

    // Hitung rekap per kategori pengeluaran
    final Map<String, double> expenseCategoryTotals = {};
    for (final tx in transactions.where((t) => t.type == TransactionType.expense)) {
      expenseCategoryTotals[tx.category] =
          (expenseCategoryTotals[tx.category] ?? 0) + tx.amount;
    }
    final sortedExpenseCategories = expenseCategoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Urutkan transaksi dari terlama ke terbaru untuk pembacaan pembukuan rapi
    final sortedTransactions = List<TransactionModel>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 32),
        header: (context) => _buildHeader(
          monthTitle: monthTitle,
          username: username,
          printDate: printDate,
        ),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 14),

          // Ringkasan Keuangan (3 Kartu Ringkas dengan kontras tinggi)
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildSummaryBox(
                  title: 'Total Pemasukan',
                  amount: AppFormatters.formatCurrency(monthlyIncome),
                  accentColor: _incomeColor,
                  bgColor: const PdfColor.fromInt(0xFFF0FDF4),
                  borderColor: const PdfColor.fromInt(0xFF86EFAC),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: _buildSummaryBox(
                  title: 'Total Pengeluaran',
                  amount: AppFormatters.formatCurrency(monthlyExpense),
                  accentColor: _expenseColor,
                  bgColor: const PdfColor.fromInt(0xFFFEF2F2),
                  borderColor: const PdfColor.fromInt(0xFFFCA5A5),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: _buildSummaryBox(
                  title: isSurplus ? 'Surplus Arus Kas' : 'Defisit Arus Kas',
                  amount: '${isSurplus ? '+' : ''}${AppFormatters.formatCurrency(netCashFlow)}',
                  accentColor: isSurplus ? _primaryColor : _expenseColor,
                  bgColor: const PdfColor.fromInt(0xFFF0FDFA),
                  borderColor: isSurplus
                      ? const PdfColor.fromInt(0xFF99F6E4)
                      : const PdfColor.fromInt(0xFFFCA5A5),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // Rekap Pengeluaran per Kategori (jika ada)
          if (sortedExpenseCategories.isNotEmpty) ...[
            pw.Text(
              'Distribusi Pengeluaran per Kategori',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: _textDark,
              ),
            ),
            pw.SizedBox(height: 8),
            _buildCategoryBreakdownTable(
              sortedExpenseCategories,
              monthlyExpense,
            ),
            pw.SizedBox(height: 20),
          ],

          // Rincian Riwayat Transaksi
          pw.Text(
            'Rincian Transaksi (${sortedTransactions.length} transaksi)',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: _textDark,
            ),
          ),
          pw.SizedBox(height: 8),

          if (sortedTransactions.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 24),
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _borderLight),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'Tidak ada catatan transaksi pada bulan ini.',
                style: const pw.TextStyle(color: _textMuted, fontSize: 11),
              ),
            )
          else
            _buildTransactionsTable(sortedTransactions),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader({
    required String monthTitle,
    required String username,
    required String printDate,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _primaryColor, width: 2.5),
        ),
      ),
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BERUANG BIJAK',
                style: pw.TextStyle(
                  fontSize: 19,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Laporan Arus Kas Bulanan',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: _textDark,
                ),
              ),
              pw.SizedBox(height: 5),
              // Badge Periode dengan Kontras Tajam & Mudah Dibaca
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFE6F5F5),
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(
                    color: const PdfColor.fromInt(0xFFB5E4E0),
                    width: 0.8,
                  ),
                ),
                child: pw.Text(
                  'Periode: $monthTitle',
                  style: pw.TextStyle(
                    fontSize: 10.5,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: _bgLight,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: _borderLight, width: 0.8),
                ),
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      'Pengguna: ',
                      style: const pw.TextStyle(fontSize: 10, color: _textMuted),
                    ),
                    pw.Text(
                      username,
                      style: pw.TextStyle(
                        fontSize: 10.5,
                        fontWeight: pw.FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Dicetak: $printDate WIB',
                style: const pw.TextStyle(fontSize: 8.5, color: _textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 14),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: _borderLight, width: 0.8),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Beruang Bijak | Solusi Pengelolaan Keuangan Cerdas & Teratur',
            style: const pw.TextStyle(fontSize: 8, color: _textMuted),
          ),
          pw.Text(
            'Halaman ${context.pageNumber} dari ${context.pagesCount}',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryBox({
    required String title,
    required String amount,
    required PdfColor accentColor,
    required PdfColor bgColor,
    required PdfColor borderColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: borderColor, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _textMuted,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            amount,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCategoryBreakdownTable(
    List<MapEntry<String, double>> categories,
    double totalExpense,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: _borderLight, width: 0.6),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _bgLight),
          children: [
            _tableHeaderCell('Kategori Pengeluaran'),
            _tableHeaderCell('Nominal', align: pw.TextAlign.right),
            _tableHeaderCell('Porsi (%)', align: pw.TextAlign.right),
          ],
        ),
        ...categories.map((entry) {
          final percentage = totalExpense > 0 ? (entry.value / totalExpense * 100) : 0.0;
          return pw.TableRow(
            children: [
              _tableDataCell(entry.key),
              _tableDataCell(
                AppFormatters.formatCurrency(entry.value),
                align: pw.TextAlign.right,
              ),
              _tableDataCell(
                '${percentage.toStringAsFixed(1)}%',
                align: pw.TextAlign.right,
                bold: true,
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTransactionsTable(List<TransactionModel> txs) {
    return pw.Table(
      border: pw.TableBorder.all(color: _borderLight, width: 0.6),
      columnWidths: {
        0: const pw.FixedColumnWidth(24),
        1: const pw.FlexColumnWidth(1.8),
        2: const pw.FlexColumnWidth(2.6),
        3: const pw.FlexColumnWidth(1.8),
        4: const pw.FlexColumnWidth(1.4),
        5: const pw.FlexColumnWidth(2.2),
        6: const pw.FlexColumnWidth(2.2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _bgLight),
          children: [
            _tableHeaderCell('No', align: pw.TextAlign.center),
            _tableHeaderCell('Waktu'),
            _tableHeaderCell('Judul'),
            _tableHeaderCell('Kategori'),
            _tableHeaderCell('Tipe', align: pw.TextAlign.center),
            _tableHeaderCell('Nominal', align: pw.TextAlign.right),
            _tableHeaderCell('Catatan'),
          ],
        ),
        ...List.generate(txs.length, (index) {
          final tx = txs[index];
          final isIncome = tx.type == TransactionType.income;
          final dateTimeStr =
              '${DateFormat('dd/MM/yy', 'id_ID').format(tx.date)} ${DateFormat('HH:mm').format(tx.date)}';

          // Gunakan '-' biasa (ASCII 45) agar tidak terjadi missing glyph box pada font PDF
          final sign = isIncome ? '+' : '-';

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index % 2 == 1 ? const PdfColor.fromInt(0xFFFAFAFA) : PdfColors.white,
            ),
            children: [
              _tableDataCell('${index + 1}', align: pw.TextAlign.center),
              _tableDataCell(dateTimeStr, fontSize: 8),
              _tableDataCell(tx.title, bold: true),
              _tableDataCell(tx.category),
              _tableDataCell(
                isIncome ? 'Masuk' : 'Keluar',
                align: pw.TextAlign.center,
                color: isIncome ? _incomeColor : _expenseColor,
                bold: true,
                fontSize: 8,
              ),
              _tableDataCell(
                '$sign ${AppFormatters.formatCurrency(tx.amount)}',
                align: pw.TextAlign.right,
                color: isIncome ? _incomeColor : _expenseColor,
                bold: true,
                fontSize: 8.5,
              ),
              _tableDataCell(
                tx.note ?? '-',
                fontSize: 8,
                color: tx.note != null && tx.note!.isNotEmpty ? _textDark : _textMuted,
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: _textDark,
        ),
      ),
    );
  }

  static pw.Widget _tableDataCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    bool bold = false,
    double fontSize = 8.5,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? _textDark,
        ),
      ),
    );
  }
}
