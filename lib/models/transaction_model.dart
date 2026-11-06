enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String? userId;
  final String? goalId; // ID Celengan jika transaksi ini terikat dengan Celengan Impian
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? note;

  TransactionModel({
    required this.id,
    this.userId,
    this.goalId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? goalId,
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  // Konversi ke Map (Buat simpan ke SQLite / Shared Preferences / API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'goalId': goalId,
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
      userId: map['userId'],
      goalId: map['goalId'],
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