import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const String _usersKey = 'auth_users';
  static const String _currentUsernameKey = 'auth_current_username';

  String? _currentUsername;

  String? get currentUsername => _currentUsername;

  bool get isAuthenticated => _currentUsername != null;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUsername = prefs.getString(_currentUsernameKey);
    notifyListeners();
  }

  Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final users = _getUsers(prefs);

    final normalizedUsername = username.trim();

    if (normalizedUsername.isEmpty || password.isEmpty) {
      return false;
    }

    if (users.containsKey(normalizedUsername)) {
      return false;
    }

    users[normalizedUsername] = password;

    await prefs.setString(_usersKey, jsonEncode(users));

    return true;
  }

  Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final users = _getUsers(prefs);

    final normalizedUsername = username.trim();

    if (users[normalizedUsername] != password) {
      return false;
    }

    _currentUsername = normalizedUsername;

    await prefs.setString(
      _currentUsernameKey,
      normalizedUsername,
    );

    notifyListeners();

    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    _currentUsername = null;

    await prefs.remove(_currentUsernameKey);

    notifyListeners();
  }

  Map<String, dynamic> _getUsers(SharedPreferences prefs) {
    final rawUsers = prefs.getString(_usersKey);

    if (rawUsers == null || rawUsers.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(rawUsers);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {};
    } catch (_) {
      return {};
    }
  }
}