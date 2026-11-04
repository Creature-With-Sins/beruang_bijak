import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../utils/app_formatters.dart';

class CsvExportService {
  CsvExportService._();

  /// Menghasilkan file CSV dalam format Uint8List dengan encoding UTF-8 (dengan BOM agar rapi di Microsoft Excel)
  static Uint8List generateMonthlyReportCsv({
    required DateTime month,
    required String username,
    required List<TransactionModel> transactions,
  }) {
    final buffer = StringBuffer();
    final monthTitle = AppFormatters.formatMonthYear(month);

    // Metadata Header CSV
    buffer.writeln('BERUANG BIJAK - LAPORAN KEUANGAN BULANAN');
    buffer.writeln('Periode:,"$monthTitle"');
    buffer.writeln('Pengguna:,"$username"');
    buffer.writeln('Waktu Export:,"${DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(DateTime.now())}"');
    buffer.writeln('');

    // Ringkasan
    final monthlyIncome = transactions
        .where((tx) => tx.type == TransactionType.income)
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final monthlyExpense = transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final netCashFlow = monthlyIncome - monthlyExpense;

    buffer.writeln('RINGKASAN');
    buffer.writeln('Total Pemasukan,${monthlyIncome.toInt()}');
    buffer.writeln('Total Pengeluaran,${monthlyExpense.toInt()}');
    buffer.writeln('Arus Kas Bersih,${netCashFlow.toInt()}');
    buffer.writeln('');

    // Tabel Transaksi
    buffer.writeln('No,Tanggal,Jam,Judul,Kategori,Tipe,Nominal,Catatan');

    final sortedTxs = List<TransactionModel>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (int i = 0; i < sortedTxs.length; i++) {
      final tx = sortedTxs[i];
      final dateStr = DateFormat('yyyy-MM-dd').format(tx.date);
      final timeStr = DateFormat('HH:mm').format(tx.date);
      final typeStr = tx.type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran';
      final cleanTitle = tx.title.replaceAll('"', '""');
      final cleanCategory = tx.category.replaceAll('"', '""');
      final cleanNote = (tx.note ?? '').replaceAll('"', '""');
      final amount = tx.amount.toInt();

      buffer.writeln(
        '${i + 1},"$dateStr","$timeStr","$cleanTitle","$cleanCategory","$typeStr",$amount,"$cleanNote"',
      );
    }

    // UTF-8 BOM agar aksen dan karakter terbaca sempurna di Microsoft Excel
    final bom = [0xEF, 0xBB, 0xBF];
    final csvBytes = utf8.encode(buffer.toString());
    return Uint8List.fromList([...bom, ...csvBytes]);
  }
}

