import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'qazaq_republic.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Создание таблицы пользователей
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user'
      )
    ''');
    
    // Создание таблицы товаров
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        image_url TEXT NOT NULL,
        sizes TEXT NOT NULL,
        colors TEXT NOT NULL,
        category TEXT NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0
      )
    ''');
    
    // Создание таблицы корзины
    await db.execute('''
      CREATE TABLE cart_items(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        selected_size TEXT NOT NULL,
        selected_color TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
    
    // Создание таблицы заказов
    await db.execute('''
      CREATE TABLE orders(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        orderDate TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        address TEXT,
        paymentMethod TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
    
    // Создание таблицы элементов заказа
    await db.execute('''
      CREATE TABLE order_items(
        id TEXT PRIMARY KEY,
        orderId TEXT NOT NULL,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        selectedSize TEXT,
        selectedColor TEXT,
        FOREIGN KEY (orderId) REFERENCES orders (id),
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');
    
    // Заполнение начальными данными (точно такими же как в web версии)
    await _initializeData(db);
  }
  
  Future<void> _initializeData(Database db) async {
    // Добавляем админа (точно такого же как в web версии)
    await db.insert('users', {
      'id': '1',
      'name': 'Админ',
      'email': 'admin@qazaqrepublic.kz',
      'password': _hashPassword('admin123'),
      'role': 'admin'
    });
    
    // Добавляем точно такие же товары как в web версии
    final products = [
      {
        'id': '1',
        'name': 'QR Футболка',
        'price': 7990.0,
        'image_url': 'assets/images/tshirt_black.jpg',
        'sizes': 'S,M,L,XL,XXL',
        'colors': 'Қара,Ақ,Сұр',
        'category': 'Футболка',
        'stock': 50
      },
      {
        'id': '2',
        'name': 'QR Худи',
        'price': 14990.0,
        'image_url': 'assets/images/Hoode.jpeg',
        'sizes': 'S,M,L,XL,XXL',
        'colors': 'Қара,Сұр,Көк',
        'category': 'Худи',
        'stock': 30
      },
      {
        'id': '3',
        'name': 'QR Жейде',
        'price': 11990.0,
        'image_url': 'assets/images/shirtlongdark-blue.jpeg',
        'sizes': 'S,M,L,XL',
        'colors': 'Ақ,Көк,Қара',
        'category': 'Жейде',
        'stock': 25
      },
      {
        'id': '4',
        'name': 'QR Кепка',
        'price': 8000.0,
        'image_url': 'assets/images/cap.jpg',
        'sizes': 'Стандарт',
        'colors': 'Жасыл',
        'category': 'Аксессуары',
        'stock': 25
      },
      {
        'id': '5',
        'name': 'QR Свитшот',
        'price': 18000.0,
        'image_url': 'assets/images/sweatshirt.jpg',
        'sizes': 'S,M,L,XL',
        'colors': 'Қызыл',
        'category': 'Свитшоты',
        'stock': 25
      },
      {
        'id': '6',
        'name': 'CARGO Ветровка',
        'price': 26500.0,
        'image_url': 'assets/images/windbreaker.jpg',
        'sizes': 'S,M,L,XL',
        'colors': 'Қою көк',
        'category': 'Ветровки',
        'stock': 25
      }
    ];
    
    for (final product in products) {
      await db.insert('products', product);
    }
  }
  
  // Хеширование пароля (такое же как в web версии)
  String _hashPassword(String password) {
    // В реальном приложении здесь должен быть настоящий хеш
    return password; // Для тестирования просто возвращаем пароль
  }
  
  // Методы для работы с данными (совместимые с web версией)
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }
  
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql,
    List<dynamic> arguments,
  ) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }
  
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }
  
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }
  
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
  
  // Методы-прокси для обратной совместимости с web версией
  Future<List<Map<String, dynamic>>> queryTable(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) {
    return query(table, where: where, whereArgs: whereArgs);
  }
  
  Future<List<Map<String, dynamic>>> executeRawQuery(
    String sql,
    List<dynamic> arguments,
  ) {
    return rawQuery(sql, arguments);
  }
  
  Future<int> insertRecord(String table, Map<String, dynamic> data) {
    return insert(table, data);
  }
  
  Future<int> updateRecord(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) {
    return update(table, data, where: where, whereArgs: whereArgs);
  }
  
  Future<int> deleteRecord(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) {
    return delete(table, where: where, whereArgs: whereArgs);
  }
  
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}