import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String _error = '';

  User? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  AuthProvider() {
    // Проверка, если пользователь уже авторизован
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    
    if (userId != null) {
      await _getUserById(userId);
    }
  }

  Future<void> _getUserById(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Убедимся, что база данных инициализирована
      await DatabaseService().database;
      
      final db = DatabaseService();
      final users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (users.isNotEmpty) {
        _user = User.fromMap(users.first);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // Убедимся, что база данных инициализирована
      await DatabaseService().database;
      
      final db = DatabaseService();
      // Для тестирования используем нехешированный пароль
      // В реальном приложении нужно использовать хеширование

      final users = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (users.isEmpty) {
        _isLoading = false;
        _error = 'Қате электрондық пошта немесе құпия сөз';
        notifyListeners();
        return false;
      }

      _user = User.fromMap(users.first);
      
      // Сохраняем ID пользователя для автоматического входа
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _user!.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // Убедимся, что база данных инициализирована
      await DatabaseService().database;
      
      final db = DatabaseService();
      
      // Проверяем, существует ли пользователь с таким email
      final existingUsers = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existingUsers.isNotEmpty) {
        _isLoading = false;
        _error = 'Бұл электрондық пошта тіркелген';
        notifyListeners();
        return false;
      }

      // Создаем нового пользователя
      final userId = DateTime.now().millisecondsSinceEpoch.toString();

      final newUser = User(
        id: userId,
        name: name,
        email: email,
        password: password, // В реальном приложении нужно хешировать
        role: 'user', // По умолчанию роль - обычный пользователь
      );

      await db.insert('users', newUser.toMap());

      _user = newUser;
      
      // Сохраняем ID пользователя для автоматического входа
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _user!.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    
    _user = null;
    notifyListeners();
  }
}