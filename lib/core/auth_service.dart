import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  String? _currentUserEmail;
  String? _currentUsername;

  String? get currentUserEmail => _currentUserEmail;
  String? get currentUsername => _currentUsername;

  static final Map<String, Map<String, String>> _mockUsers = {};

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserEmail = prefs.getString('email');
    _currentUsername = prefs.getString('username');
    notifyListeners();
  }

  Future<bool> register(String username, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (username.isEmpty || !email.contains('@') || password.length < 6) {
      return false;
    }

    _mockUsers[email] = {'username': username, 'password': password};

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('email', email);
    await prefs.setString('username', username);

    _currentUserEmail = email;
    _currentUsername = username;

    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_mockUsers.containsKey(email) &&
        _mockUsers[email]!['password'] == password) {
      final username = _mockUsers[email]!['username']!;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email', email);
      await prefs.setString('username', username);

      _currentUserEmail = email;
      _currentUsername = username;
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUserEmail = null;
    _currentUsername = null;
    notifyListeners();
  }
}
