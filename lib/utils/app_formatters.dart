import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format angka ke mata uang Rupiah: contoh "Rp 150.000"
  static String formatCurrency(num amount) {
    return _currencyFormat.format(amount);
  }

  /// Format tanggal standar: contoh "21 Okt 2026"
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  /// Format tanggal lengkap hari dan bulan: contoh "Rabu, 21 Oktober 2026"
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
  }

  /// Format bulan dan tahun: contoh "Oktober 2026"
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  /// Format jam dan menit: contoh "14:30"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'id_ID').format(date);
  }

  /// Format cerdas untuk header pengelompokan riwayat transaksi:
  /// Contoh: "Hari ini • 21 Okt 2026", "Kemarin • 20 Okt 2026", atau "Senin • 19 Okt 2026"
  static String formatDayHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    final dateString = DateFormat('dd MMM yyyy', 'id_ID').format(date);

    if (targetDate == today) {
      return 'Hari Ini • $dateString';
    } else if (targetDate == yesterday) {
      return 'Kemarin • $dateString';
    } else {
      final dayName = DateFormat('EEEE', 'id_ID').format(date);
      return '$dayName • $dateString';
    }
  }

  /// Membandingkan apakah dua DateTime berada pada hari, bulan, dan tahun yang sama
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Mendapatkan DateTime hanya dengan komponen tanggal (jam 00:00:00)
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
