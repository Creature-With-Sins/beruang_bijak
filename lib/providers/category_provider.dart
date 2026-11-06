import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class CategoryProvider extends ChangeNotifier {
  static const String _incomePrefKey = 'custom_income_categories';
  static const String _expensePrefKey = 'custom_expense_categories';

  static const List<String> defaultIncomeCategories = [
    'Gaji',
    'Pemasukan',
    'Bonus',
    'Investasi',
    'Tabungan',
  ];

  static const List<String> defaultExpenseCategories = [
    'Makanan',
    'Transport',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Tagihan',
    'Tabungan',
    'Lainnya',
  ];

  List<String> _customIncomeCategories = [];
  List<String> _customExpenseCategories = [];
  bool _isLoaded = false;

  CategoryProvider() {
    loadCategories();
  }

  bool get isLoaded => _isLoaded;

  List<String> get incomeCategories => [
        ...defaultIncomeCategories,
        ..._customIncomeCategories,
      ];

  List<String> get expenseCategories => [
        ...defaultExpenseCategories,
        ..._customExpenseCategories,
      ];

  List<String> getCategories(TransactionType type) {
    return type == TransactionType.income
        ? incomeCategories
        : expenseCategories;
  }

  bool isCustomCategory(TransactionType type, String category) {
    if (type == TransactionType.income) {
      return _customIncomeCategories.contains(category);
    } else {
      return _customExpenseCategories.contains(category);
    }
  }

  Future<void> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final incomeList = prefs.getStringList(_incomePrefKey);
      final expenseList = prefs.getStringList(_expensePrefKey);

      if (incomeList != null) {
        _customIncomeCategories = List.from(incomeList);
      }
      if (expenseList != null) {
        _customExpenseCategories = List.from(expenseList);
      }
    } catch (_) {
      // Fallback to empty custom categories
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<bool> addCategory(TransactionType type, String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return false;

    final currentList = getCategories(type);
    final exists = currentList.any(
      (c) => c.toLowerCase() == trimmedName.toLowerCase(),
    );

    if (exists) return false;

    if (type == TransactionType.income) {
      _customIncomeCategories.add(trimmedName);
      await _saveCategories(_incomePrefKey, _customIncomeCategories);
    } else {
      _customExpenseCategories.add(trimmedName);
      await _saveCategories(_expensePrefKey, _customExpenseCategories);
    }

    notifyListeners();
    return true;
  }

  Future<bool> removeCategory(TransactionType type, String name) async {
    final trimmedName = name.trim();
    if (!isCustomCategory(type, trimmedName)) return false;

    if (type == TransactionType.income) {
      _customIncomeCategories.remove(trimmedName);
      await _saveCategories(_incomePrefKey, _customIncomeCategories);
    } else {
      _customExpenseCategories.remove(trimmedName);
      await _saveCategories(_expensePrefKey, _customExpenseCategories);
    }

    notifyListeners();
    return true;
  }

  Future<void> _saveCategories(String key, List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, list);
  }
}

