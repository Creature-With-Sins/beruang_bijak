class GoalModel {
  final String id;
  final String? userId;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final DateTime? targetDate;
  final String category;
  final String? note;
  final DateTime createdAt;
  final bool isSyncedWithWallet;

  const GoalModel({
    required this.id,
    this.userId,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0.0,
    this.targetDate,
    this.category = 'Lainnya',
    this.note,
    required this.createdAt,
    this.isSyncedWithWallet = true,
  });

  double get progress => targetAmount <= 0
      ? 0.0
      : (savedAmount / targetAmount).clamp(0.0, 1.0);

  double get progressPercentage => (progress * 100);

  double get remainingAmount => (targetAmount - savedAmount).clamp(0.0, double.infinity);

  bool get isCompleted => savedAmount >= targetAmount && targetAmount > 0;

  int? get remainingDays {
    if (targetDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate!.year, targetDate!.month, targetDate!.day);
    return target.difference(today).inDays;
  }

  GoalModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    String? category,
    String? note,
    DateTime? createdAt,
    bool? isSyncedWithWallet,
  }) {
    return GoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      isSyncedWithWallet: isSyncedWithWallet ?? this.isSyncedWithWallet,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': targetDate?.toIso8601String(),
      'category': category,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'isSyncedWithWallet': isSyncedWithWallet,
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] as String,
      userId: map['userId'] as String?,
      title: map['title'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      savedAmount: (map['savedAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: map['targetDate'] != null
          ? DateTime.parse(map['targetDate'] as String)
          : null,
      category: map['category'] as String? ?? 'Lainnya',
      note: map['note'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      isSyncedWithWallet: map['isSyncedWithWallet'] as bool? ?? true,
    );
  }
}

