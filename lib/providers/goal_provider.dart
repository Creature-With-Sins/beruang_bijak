import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal_model.dart';
import '../models/transaction_model.dart';

class GoalProvider extends ChangeNotifier {
  static const String _goalsPrefKey = 'savings_goals_data';

  List<GoalModel> _goals = [];
  String? _currentUserId;
  bool _isLoading = false;

  GoalProvider() {
    loadGoals();
  }

  List<GoalModel> get goals {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      return List.unmodifiable(_goals);
    }
    return List.unmodifiable(
      _goals.where((g) => g.userId == null || g.userId == _currentUserId),
    );
  }

  bool get isLoading => _isLoading;

  double get totalTargetAmount =>
      goals.fold<double>(0.0, (sum, g) => sum + g.targetAmount);

  double get totalSavedAmount =>
      goals.fold<double>(0.0, (sum, g) => sum + g.savedAmount);

  double get overallProgress => totalTargetAmount <= 0
      ? 0.0
      : (totalSavedAmount / totalTargetAmount).clamp(0.0, 1.0);

  int get completedGoalsCount => goals.where((g) => g.isCompleted).length;

  int get activeGoalsCount => goals.where((g) => !g.isCompleted).length;

  void setCurrentUser(String? username) {
    if (_currentUserId != username) {
      _currentUserId = username;
      notifyListeners();
    }
  }

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_goalsPrefKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        _goals = decoded
            .map((item) => GoalModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _goals = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal({
    required String title,
    required double targetAmount,
    double initialAmount = 0.0,
    DateTime? targetDate,
    String category = 'Lainnya',
    String? note,
    bool isSyncedWithWallet = true,
  }) async {
    final newGoal = GoalModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUserId,
      title: title.trim(),
      targetAmount: targetAmount,
      savedAmount: initialAmount,
      targetDate: targetDate,
      category: category,
      note: note?.trim(),
      createdAt: DateTime.now(),
      isSyncedWithWallet: isSyncedWithWallet,
    );

    _goals.insert(0, newGoal);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateGoal(GoalModel updatedGoal) async {
    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<bool> deposit(String goalId, double amount) async {
    if (amount <= 0) return false;
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index == -1) return false;

    final current = _goals[index];
    final newSaved = current.savedAmount + amount;
    _goals[index] = current.copyWith(savedAmount: newSaved);

    await _saveToPrefs();
    notifyListeners();
    return true;
  }

  Future<bool> withdraw(String goalId, double amount) async {
    if (amount <= 0) return false;
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index == -1) return false;

    final current = _goals[index];
    final newSaved = (current.savedAmount - amount).clamp(0.0, double.infinity);
    _goals[index] = current.copyWith(savedAmount: newSaved);

    await _saveToPrefs();
    notifyListeners();
    return true;
  }

  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
    await _saveToPrefs();
    notifyListeners();
  }

  /// Menyesuaikan saldo celengan jika transaksi terkait dihapus dari Kas Utama
  /// Mengembalikan true jika celengan ditemukan dan saldo disesuaikan
  Future<bool> adjustGoalOnTransactionDeleted(TransactionModel tx) async {
    String? targetGoalId = tx.goalId;

    // Fallback pencocokan jika transaksi belum memiliki goalId (misal transaksi dari versi lama)
    if (targetGoalId == null || targetGoalId.isEmpty) {
      if (tx.category == 'Tabungan' || tx.note?.contains('Celengan Impian') == true) {
        final match = _goals.cast<GoalModel?>().firstWhere(
          (g) => g != null && tx.title.contains(g.title),
          orElse: () => null,
        );
        if (match != null) {
          targetGoalId = match.id;
        }
      }
    }

    if (targetGoalId == null || targetGoalId.isEmpty) return false;

    final index = _goals.indexWhere((g) => g.id == targetGoalId);
    if (index == -1) return false;

    final goal = _goals[index];
    if (tx.type == TransactionType.expense) {
      // Transaksi setor/nabung dihapus dari kas -> batalkan penambahan celengan
      final newSaved = (goal.savedAmount - tx.amount).clamp(0.0, double.infinity);
      _goals[index] = goal.copyWith(savedAmount: newSaved);
    } else if (tx.type == TransactionType.income) {
      // Transaksi tarik dihapus dari kas -> kembalikan dana ke dalam celengan
      final newSaved = goal.savedAmount + tx.amount;
      _goals[index] = goal.copyWith(savedAmount: newSaved);
    }

    await _saveToPrefs();
    notifyListeners();
    return true;
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_goals.map((g) => g.toMap()).toList());
    await prefs.setString(_goalsPrefKey, encoded);
  }
}

