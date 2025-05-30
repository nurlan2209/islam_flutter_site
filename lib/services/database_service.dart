import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import '../models/user.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static bool _initialized = false;
  
  // Ключи для localStorage
  static const String _usersKey = 'qr_users';
  static const String _productsKey = 'qr_products';
  static const String _cartItemsKey = 'qr_cart_items';
  static const String _ordersKey = 'qr_orders';
  static const String _orderItemsKey = 'qr_order_items';
  
  // Хранилище данных в памяти
  static Map<String, List<Map<String, dynamic>>> _store = {
    'users': <Map<String, dynamic>>[],
    'products': <Map<String, dynamic>>[],
    'cart_items': <Map<String, dynamic>>[],
    'orders': <Map<String, dynamic>>[],
    'order_items': <Map<String, dynamic>>[],
  };
  
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();
  
  // Метод для инициализации базы данных
  Future<void> get database async {
    if (!_initialized) {
      _loadFromLocalStorage();
      if (_store['users']!.isEmpty) {
        await _initializeData();
      }
      _initialized = true;
    }
    return Future.value();
  }
  
  // Загрузка данных из localStorage
  void _loadFromLocalStorage() {
    try {
      if (html.window.localStorage.containsKey(_usersKey)) {
        _store['users'] = List<Map<String, dynamic>>.from(
          jsonDecode(html.window.localStorage[_usersKey]!).map((item) => 
            Map<String, dynamic>.from(item)
          )
        );
      }
      
      if (html.window.localStorage.containsKey(_productsKey)) {
        _store['products'] = List<Map<String, dynamic>>.from(
          jsonDecode(html.window.localStorage[_productsKey]!).map((item) => 
            Map<String, dynamic>.from(item)
          )
        );
      }
      
      if (html.window.localStorage.containsKey(_cartItemsKey)) {
        _store['cart_items'] = List<Map<String, dynamic>>.from(
          jsonDecode(html.window.localStorage[_cartItemsKey]!).map((item) => 
            Map<String, dynamic>.from(item)
          )
        );
      }
      
      if (html.window.localStorage.containsKey(_ordersKey)) {
        _store['orders'] = List<Map<String, dynamic>>.from(
          jsonDecode(html.window.localStorage[_ordersKey]!).map((item) => 
            Map<String, dynamic>.from(item)
          )
        );
      }
      
      if (html.window.localStorage.containsKey(_orderItemsKey)) {
        _store['order_items'] = List<Map<String, dynamic>>.from(
          jsonDecode(html.window.localStorage[_orderItemsKey]!).map((item) => 
            Map<String, dynamic>.from(item)
          )
        );
      }
    } catch (e) {
      print('Ошибка загрузки данных из localStorage: $e');
      _store = {
        'users': <Map<String, dynamic>>[],
        'products': <Map<String, dynamic>>[],
        'cart_items': <Map<String, dynamic>>[],
        'orders': <Map<String, dynamic>>[],
        'order_items': <Map<String, dynamic>>[],
      };
    }
  }
  
  // Сохранение данных в localStorage
  void _saveToLocalStorage() {
    try {
      html.window.localStorage[_usersKey] = jsonEncode(_store['users']);
      html.window.localStorage[_productsKey] = jsonEncode(_store['products']);
      html.window.localStorage[_cartItemsKey] = jsonEncode(_store['cart_items']);
      html.window.localStorage[_ordersKey] = jsonEncode(_store['orders']);
      html.window.localStorage[_orderItemsKey] = jsonEncode(_store['order_items']);
    } catch (e) {
      print('Ошибка сохранения данных в localStorage: $e');
    }
  }
  
  // Заполнение начальными данными
  Future<void> _initializeData() async {
    // Добавляем админа
    _store['users'] = [
      {
        'id': '1',
        'name': 'Админ',
        'email': 'admin@qazaqrepublic.kz',
        'password': _hashPassword('admin123'),
        'role': 'admin'
      }
    ];
    
    // Добавляем тестовые товары с URL изображениями
    _store['products'] = [
      {
        'id': '1',
        'name': 'Qazaq Republic Classic футболка',
        'description': 'Классикалық мақта футболка. 100% табиғи материал.',
        'price': 7990.0,
        'image_url': '/assets/images/tshirt_black.jpg',
        'sizes': 'S,M,L,XL,XXL',
        'colors': 'Қара,Ақ,Сұр',
        'category': 'Футболкалар',
        'stock': 50
      },
      {
        'id': '2',
        'name': 'Qazaq Republic Худи',
        'description': 'Жылы худи, қысқа және күзге арналған.',
        'price': 14990.0,
        'image_url': '/assets/images/Hoode.jpeg',
        'sizes': 'S,M,L,XL,XXL',
        'colors': 'Қара,Сұр,Көк',
        'category': 'Худи',
        'stock': 30
      },
      {
        'id': '3',
        'name': 'Qazaq Republic Жейде',
        'description': 'Классикалық стильдегі жейде.',
        'price': 11990.0,
        'image_url': '/assets/images/shirtlongdark-blue.jpeg',
        'sizes': 'S,M,L,XL',
        'colors': 'Ақ,Көк,Қара',
        'category': 'Жейде',
        'stock': 25
      }
    ];
    
    // Сохраняем данные в localStorage
    _saveToLocalStorage();
  }
  
  // Методы для работы с данными
  
  // Получение данных из таблицы - переименовано из query
  Future<List<Map<String, dynamic>>> queryTable(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final List<Map<String, dynamic>> data = List.from(_store[table] ?? []);
    
    if (where != null && whereArgs != null) {
      // Очень простая имитация условий WHERE
      return data.where((item) {
        if (where.contains('=')) {
          final parts = where.split('=');
          final field = parts[0].trim();
          return item[field].toString() == whereArgs[0].toString();
        }
        return true;
      }).toList();
    }
    
    return data;
  }
  
  // Выполнение произвольного запроса - переименовано из rawQuery
  Future<List<Map<String, dynamic>>> executeRawQuery(
    String sql,
    List<dynamic> arguments,
  ) async {
    // Очень упрощенная имитация JOIN-запросов
    if (sql.contains('cart_items') && sql.contains('products')) {
      final userId = arguments[0];
      final cartItems = await queryTable('cart_items', where: 'user_id = ?', whereArgs: [userId]);
      
      // Объединяем данные корзины и товаров
      final result = <Map<String, dynamic>>[];
      
      for (var item in cartItems) {
        final productId = item['product_id'];
        final products = await queryTable('products', where: 'id = ?', whereArgs: [productId]);
        
        if (products.isNotEmpty) {
          final product = products.first;
          result.add({
            ...item,
            'product_name': product['name'],
            'product_price': product['price'],
            'product_image_url': product['image_url'],
          });
        } else {
          result.add(item);
        }
      }
      
      return result;
    }
    
    // Для других запросов просто возвращаем пустой список
    return [];
  }
  
  // Вставка данных - переименовано из insert
  Future<int> insertRecord(String table, Map<String, dynamic> data) async {
    _store[table]!.add(Map<String, dynamic>.from(data));
    _saveToLocalStorage();
    return 1; // Имитация успешной вставки
  }
  
  // Обновление данных - переименовано из update
  Future<int> updateRecord(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (where != null && whereArgs != null) {
      final items = _store[table]!;
      
      for (int i = 0; i < items.length; i++) {
        // Простая имитация условия WHERE
        if (where.contains('=')) {
          final parts = where.split('=');
          final field = parts[0].trim();
          
          if (items[i][field].toString() == whereArgs[0].toString()) {
            // Обновляем только переданные поля
            data.forEach((key, value) {
              items[i][key] = value;
            });
          }
        }
      }
      
      _saveToLocalStorage();
    }
    
    return 1; // Имитация успешного обновления
  }
  
  // Удаление данных - переименовано из delete
  Future<int> deleteRecord(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (where != null && whereArgs != null) {
      final items = _store[table]!;
      
      // Простая имитация условия WHERE
      _store[table] = items.where((item) {
        if (where.contains('=')) {
          final parts = where.split('=');
          final field = parts[0].trim();
          return item[field].toString() != whereArgs[0].toString();
        }
        return true;
      }).toList();
      
      _saveToLocalStorage();
    }
    
    return 1; // Имитация успешного удаления
  }
  
  // Хеширование пароля
  String _hashPassword(String password) {
    // В реальном приложении здесь должен быть настоящий хеш
    return password; // Для тестирования просто возвращаем пароль
  }
  
  // Методы-прокси для обратной совместимости
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs}) {
    return queryTable(table, where: where, whereArgs: whereArgs);
  }
  
  Future<List<Map<String, dynamic>>> rawQuery(String sql, List<dynamic> arguments) {
    return executeRawQuery(sql, arguments);
  }
  
  Future<int> insert(String table, Map<String, dynamic> data) {
    return insertRecord(table, data);
  }
  
  Future<int> update(String table, Map<String, dynamic> data, {String? where, List<dynamic>? whereArgs}) {
    return updateRecord(table, data, where: where, whereArgs: whereArgs);
  }
  
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) {
    return deleteRecord(table, where: where, whereArgs: whereArgs);
  }
}