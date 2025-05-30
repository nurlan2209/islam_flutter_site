import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() => _instance;
  
  AuthService._internal();

  /// Авторизация пользователя
  Future<User?> login(String email, String password) async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      // В нашей упрощенной реализации для Web мы не хешируем пароль
      // Для реального приложения нужно использовать хеширование
      
      final users = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      
      if (users.isEmpty) {
        return null;
      }
      
      final user = User.fromMap(users.first);
      
      // Сохраняем ID пользователя для автоматического входа
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.id);
      
      return user;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
  
  /// Регистрация нового пользователя
  Future<User?> register(String name, String email, String password) async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      // Проверяем, существует ли пользователь с таким email
      final existingUsers = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (existingUsers.isNotEmpty) {
        return null;
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
      
      // Сохраняем ID пользователя для автоматического входа
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', newUser.id);
      
      return newUser;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }
  
  /// Получение данных текущего пользователя
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        return null;
      }
      
      return await getUserById(userId);
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }
  
  /// Получение данных пользователя по ID
  Future<User?> getUserById(String userId) async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      final users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      if (users.isEmpty) {
        return null;
      }
      
      return User.fromMap(users.first);
    } catch (e) {
      print('Get user by id error: $e');
      return null;
    }
  }
  
  /// Получение списка всех пользователей (только для админа)
  Future<List<User>> getAllUsers() async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      final users = await db.query('users');
      
      return users.map((map) => User.fromMap(map)).toList();
    } catch (e) {
      print('Get all users error: $e');
      return [];
    }
  }
  
  /// Выход пользователя
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      return true;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }
  
  /// Обновление данных пользователя
  Future<bool> updateUser(User user) async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      
      return true;
    } catch (e) {
      print('Update user error: $e');
      return false;
    }
  }
  
  /// Удаление пользователя
  Future<bool> deleteUser(String userId) async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      return true;
    } catch (e) {
      print('Delete user error: $e');
      return false;
    }
  }
  
  /// Хеширование пароля - в нашей упрощенной версии не используется
  String _hashPassword(String password) {
    // В реальном приложении здесь должен быть настоящий хеш
    return password; // Для тестирования просто возвращаем пароль
  }
}