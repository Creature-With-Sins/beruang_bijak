enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  // Konversi ke Map (Buat simpan ke SQLite / Shared Preferences / API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name, // 'income' atau 'expense'
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  // Konversi dari Map (Saat ambil data dari SQLite / API)
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      category: map['category'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}