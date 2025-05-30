import '../models/user.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

// Временный сервис для хранения данных без SQLite
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static bool _initialized = false;
  
  // Хранилище данных в памяти
  static final Map<String, dynamic> _store = {
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
      await _initializeData();
      _initialized = true;
    }
    return Future.value();
  }
  
  // Заполнение начальными данными
  Future<void> _initializeData() async {
    // Добавляем админа
    _store['users'].add({
      'id': '10',
      'name': 'Админ',
      'email': 'admin@gmail.kz',
      'password': 'admin123',
      'role': 'admin'
    });

    
    // Добавляем тестовые товары
    _store['products'].addAll([
      {
        'id': '1',
        'name': 'Qazaq Republic Classic футболка',
        'description': 'Классикалық мақта футболка. 100% табиғи материал.',
        'price': 7990.0,
        'image_url': 'assets/images/tshirt_black.jpg',
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
        'image_url': 'assets/images/hoodie_gray.jpg',
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
        'image_url': 'assets/images/shirt_white.jpg',
        'sizes': 'S,M,L,XL',
        'colors': 'Ақ,Көк,Қара',
        'category': 'Жейде',
        'stock': 25
      },
      {
        'id': '4',
        'name': 'QR Кепка',
        'description': 'кепка. күнделікті лукты толықтыратын ерекше аксессуар.',
        'price': 8000.0,
        'image_url': '/assets/images/shirtlongdark-blue.jpeg',
        'sizes': 'Стандарт',
        'colors': 'Жасыл',
        'category': 'Акссессуар',
        'stock': 25
      }
    ]);
  }
  
  // Методы для работы с данными
  
  // Получение данных из таблицы
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final List<Map<String, dynamic>> data = List.from(_store[table] ?? []);
    
    if (where != null && whereArgs != null) {
      // Очень простая имитация условий WHERE
      // В реальном приложении нужна более сложная логика
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
  
  // Выполнение произвольного запроса (имитация)
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql,
    List<dynamic> arguments,
  ) async {
    // Очень упрощенная имитация JOIN-запросов
    if (sql.contains('cart_items') && sql.contains('products')) {
      final userId = arguments[0];
      final cartItems = await query('cart_items', where: 'user_id = ?', whereArgs: [userId]);
      
      // Объединяем данные корзины и товаров
      return Future.wait(cartItems.map((item) async {
        final productId = item['product_id'];
        final products = await query('products', where: 'id = ?', whereArgs: [productId]);
        
        if (products.isNotEmpty) {
          final product = products.first;
          return {
            ...item,
            'product_name': product['name'],
            'product_price': product['price'],
            'product_image_url': product['image_url'],
          };
        }
        
        return item;
      }).toList());
    }
    
    // Для других запросов просто возвращаем пустой список
    return [];
  }
  
  // Вставка данных
  Future<int> insert(String table, Map<String, dynamic> data) async {
    _store[table].add(data);
    return 1; // Имитация успешной вставки
  }
  
  // Обновление данных
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (where != null && whereArgs != null) {
      final items = _store[table] as List<Map<String, dynamic>>;
      
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
    }
    
    return 1; // Имитация успешного обновления
  }
  
  // Удаление данных
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    if (where != null && whereArgs != null) {
      final items = _store[table] as List<Map<String, dynamic>>;
      
      // Простая имитация условия WHERE
      _store[table] = items.where((item) {
        if (where.contains('=')) {
          final parts = where.split('=');
          final field = parts[0].trim();
          return item[field].toString() != whereArgs[0].toString();
        }
        return true;
      }).toList();
    }
    
    return 1; // Имитация успешного удаления
  }
}