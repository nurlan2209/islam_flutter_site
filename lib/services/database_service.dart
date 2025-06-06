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
    
    // Заполнение начальными данными
    await _initializeData(db);
  }
  
  Future<void> _initializeData(Database db) async {
    // Добавляем админа
    await db.insert('users', {
      'id': '1',
      'name': 'Админ',
      'email': 'admin@qazaqrepublic.kz',
      'password': _hashPassword('admin123'),
      'role': 'admin'
    });
    
    // Добавляем 30+ пользователей
    final users = [
      {'id': '2', 'name': 'Айсұлу Қасымова', 'email': 'aisulu.kasymova@gmail.com', 'password': 'user123', 'role': 'user'},
      {'id': '3', 'name': 'Нұрсұлтан Әбдірахманов', 'email': 'nursultan.abdirakhmanov@mail.ru', 'password': 'user123', 'role': 'user'},
      {'id': '4', 'name': 'Мәдина Сейітова', 'email': 'madina.seitova@outlook.com', 'password': 'user123', 'role': 'user'},
      {'id': '5', 'name': 'Қайрат Тұрысбеков', 'email': 'kairat.turysbekov@yahoo.com', 'password': 'user123', 'role': 'user'},
      {'id': '6', 'name': 'Гүлнәр Омарова', 'email': 'gulnar.omarova@gmail.com', 'password': 'user123', 'role': 'user'},
      {'id': '7', 'name': 'Асхат Мұхамеджанов', 'email': 'askhat.mukhamejanov@mail.ru', 'password': 'user123', 'role': 'user'},
      {'id': '8', 'name': 'Дильназ Қалиева', 'email': 'dilnaz.kalieva@gmail.com', 'password': 'user123', 'role': 'user'},
      {'id': '9', 'name': 'Ерлан Жұмабаев', 'email': 'erlan.zhumabaev@outlook.com', 'password': 'user123', 'role': 'user'},
      {'id': '10', 'name': 'Ақбота Сәрсенова', 'email': 'akbota.sarsenova@yahoo.com', 'password': 'user123', 'role': 'user'},
      {'id': '11', 'name': 'Ғалым Бейсенов', 'email': 'galym.beisenov@gmail.com', 'password': 'user123', 'role': 'user'},
      {'id': '12', 'name': 'Сымбат Әлімбекова', 'email': 'symbat.alimbekova@mail.ru', 'password': 'user123', 'role': 'user'},
      {'id': '13', 'name': 'Мұрат Досымов', 'email': 'murat.dosymov@gmail.com', 'password': 'user123', 'role': 'user'},
      {'id': '14', 'name': 'Қуаныш Торғайулы', 'email': 'kuanysh.torgayuly@outlook.com', 'password': 'user123', 'role': 'user'},
      {'id': '15', 'name': 'Жанна Смағұлова', 'email': 'zhanna.smagulova@yahoo.com', 'password': 'user123', 'role': 'user'},
      {'id': '16', 'name': 'Дәурен Қошербаев', 'email': 'dauren.kosherbaev@gmail.com', 'password': 'user123', 'role': 'user'},
      {'id': '17', 'name': 'Әсел Нұрғалиева', 'email': 'asel.nurgalieva@mail.ru', 'password': 'user123', 'role': 'user'},
      {'id': '18', 'name': 'Самат Ермеков', 'email': 'samat.ermekov@outlook.com', 'password': 'user123', 'role': 'user'},
      {'id': '19', 'name': 'Алия Байғабылова', 'email': 'aliya.baigabylova@gmail.com', 'password': 'user123', 'role': 'user'},
      {'id': '20', 'name': 'Болат Қанатұлы', 'email': 'bolat.kanatuly@yahoo.com', 'password': 'user123', 'role': 'user'},
      {'id': '21', 'name': 'Лаура Жақсылыкова', 'email': 'laura.zhaksylykova@gmail.com', 'password': 'user123', 'role': 'user'},
      {'id': '22', 'name': 'Ербол Мамыров', 'email': 'erbol.mamyrov@mail.ru', 'password': 'user123', 'role': 'user'},
      {'id': '23', 'name': 'Карина Өтебаева', 'email': 'karina.otebaeva@outlook.com', 'password': 'user123', 'role': 'user'},
      {'id': '24', 'name': 'Нұрлан Қайырбеков', 'email': 'nurlan.kairbekov@gmail.com', 'password': 'user123', 'role': 'user'},
      {'id': '25', 'name': 'Динара Әбілова', 'email': 'dinara.abilova@yahoo.com', 'password': 'user123', 'role': 'user'},
      {'id': '26', 'name': 'Арман Жұмаділов', 'email': 'arman.zhumadilov@mail.ru', 'password': 'user123', 'role': 'user'},
      {'id': '27', 'name': 'Меруерт Қасымбекова', 'email': 'meruert.kasymbekova@gmail.com', 'password': 'user123', 'role': 'user'},
      {'id': '28', 'name': 'Серікбол Ибрагимов', 'email': 'serikbol.ibragimov@outlook.com', 'password': 'user123', 'role': 'user'},
      {'id': '29', 'name': 'Толқын Әмірова', 'email': 'tolkyn.amirova@yahoo.com', 'password': 'user123', 'role': 'user'},
      {'id': '30', 'name': 'Әлішер Сапарбаев', 'email': 'alisher.saparbaev@gmail.com', 'password': 'user123', 'role': 'user'},
      {'id': '31', 'name': 'Жасмин Тұрарова', 'email': 'zhasmin.turarova@mail.ru', 'password': 'user123', 'role': 'user'},
      {'id': '32', 'name': 'Қасым Бақытұлы', 'email': 'kasym.bakhytuly@outlook.com', 'password': 'user123', 'role': 'user'},
      {'id': '33', 'name': 'Назым Қожабекова', 'email': 'nazym.kozhabekova@gmail.com', 'password': 'user123', 'role': 'user'},
      {'id': '34', 'name': 'Ануар Мұстафин', 'email': 'anuar.mustafin@yahoo.com', 'password': 'user123', 'role': 'user'},
      {'id': '35', 'name': 'Дана Сырымбетова', 'email': 'dana.syrymbetova@mail.ru', 'password': 'user123', 'role': 'user'},
    ];

    for (final user in users) {
      await db.insert('users', user);
    }
    
    // Добавляем старые товары с изображениями из assets
    final oldProducts = [
      {
        'id': '1',
        'name': 'QR Футболка',
        'description': 'Классикалық мақта футболка. 100% табиғи материал.',
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
        'description': 'Жылы худи, қысқа және күзге арналған.',
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
        'description': 'Классикалық стильдегі жейде.',
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
        'description': 'Кепка. Күнделікті лукты толықтыратын ерекше аксессуар.',
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
        'description': 'Жұмсақ свитшот күзге және жазға арналған.',
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
        'description': 'Модная ветровка в стиле карго.',
        'price': 26500.0,
        'image_url': 'assets/images/windbreaker.jpg',
        'sizes': 'S,M,L,XL',
        'colors': 'Қою көк',
        'category': 'Ветровки',
        'stock': 25
      }
    ];

    // Добавляем новые товары с пустыми изображениями (для URL)
    final newProducts = [
      // Футболки
      {
        'id': '7',
        'name': 'QR Classic White Tee',
        'description': 'Ақ түсті классикалық футболка. Premium качество мақта.',
        'price': 8490.0,
        'image_url': '',
        'sizes': 'XS,S,M,L,XL,XXL',
        'colors': 'Ақ,Сұр',
        'category': 'Футболка',
        'stock': 40
      },
      {
        'id': '8',
        'name': 'QR Vintage Logo Shirt',
        'description': 'Винтажды логотипі бар футболка. Ерекше дизайн.',
        'price': 9990.0,
        'image_url': '',
        'sizes': 'S,M,L,XL,XXL',
        'colors': 'Қара,Қоңыр,Жасыл',
        'category': 'Футболка',
        'stock': 35
      },
      {
        'id': '9',
        'name': 'QR Minimalist Tee',
        'description': 'Минималистік стильдегі футболка. Күнделікті киім.',
        'price': 7490.0,
        'image_url': '',
        'sizes': 'XS,S,M,L,XL',
        'colors': 'Ақ,Қара,Сұр,Көк',
        'category': 'Футболка',
        'stock': 60
      },
      
      // Худи
      {
        'id': '10',
        'name': 'QR Oversized Hoodie',
        'description': 'Oversized стильдегі худи. Заманауи кесім.',
        'price': 16990.0,
        'image_url': '',
        'sizes': 'S,M,L,XL,XXL',
        'colors': 'Қара,Сұр,Көк,Қызыл',
        'category': 'Худи',
        'stock': 25
      },
      {
        'id': '11',
        'name': 'QR Zip-Up Hoodie',
        'description': 'Молниялы худи. Практикалық және стильді.',
        'price': 18990.0,
        'image_url': '',
        'sizes': 'S,M,L,XL',
        'colors': 'Қара,Қою көк,Сұр',
        'category': 'Худи',
        'stock': 20
      },
      {
        'id': '12',
        'name': 'QR Cropped Hoodie',
        'description': 'Қысқа худи. Әйелдерге арналған модель.',
        'price': 15490.0,
        'image_url': '',
        'sizes': 'XS,S,M,L,XL',
        'colors': 'Қызыл,Сары,Жасыл,Ақ',
        'category': 'Худи',
        'stock': 30
      },
      
      // Свитшоты
      {
        'id': '13',
        'name': 'QR Crewneck Sweatshirt',
        'description': 'Дөңгелек мойынды свитшот. Классикалық үлгі.',
        'price': 14990.0,
        'image_url': '',
        'sizes': 'S,M,L,XL,XXL',
        'colors': 'Қара,Сұр,Көк',
        'category': 'Свитшоты',
        'stock': 35
      },
      {
        'id': '14',
        'name': 'QR Vintage Sweatshirt',
        'description': 'Винтажды стильдегі свитшот. Ерекше түс өңдеу.',
        'price': 17490.0,
        'image_url': '',
        'sizes': 'S,M,L,XL',
        'colors': 'Қоңыр,Жасыл,Қызыл',
        'category': 'Свитшоты',
        'stock': 28
      },
      {
        'id': '15',
        'name': 'QR Color Block Sweatshirt',
        'description': 'Түрлі түстерді біріктірген свитшот. Заманауи дизайн.',
        'price': 19990.0,
        'image_url': '',
        'sizes': 'XS,S,M,L,XL',
        'colors': 'Көп түсті',
        'category': 'Свитшоты',
        'stock': 22
      },
      
      // Жейдeler
      {
        'id': '16',
        'name': 'QR Oxford Shirt',
        'description': 'Oxford материалынан жасалған жейде. Ресми стиль.',
        'price': 13990.0,
        'image_url': '',
        'sizes': 'S,M,L,XL,XXL',
        'colors': 'Ақ,Көк,Сұр',
        'category': 'Жейде',
        'stock': 40
      },
      {
        'id': '17',
        'name': 'QR Flannel Shirt',
        'description': 'Фланель материалынан жасалған жейде. Жылы және жайлы.',
        'price': 15990.0,
        'image_url': '',
        'sizes': 'S,M,L,XL',
        'colors': 'Қызыл,Жасыл,Қоңыр',
        'category': 'Жейде',
        'stock': 30
      },
      {
        'id': '18',
        'name': 'QR Polo Shirt',
        'description': 'Polo стильдегі жейде. Спортты элегантность.',
        'price': 10990.0,
        'image_url': '',
        'sizes': 'XS,S,M,L,XL,XXL',
        'colors': 'Ақ,Қара,Көк,Жасыл',
        'category': 'Жейде',
        'stock': 45
      },
      
      // Ветровки
      {
        'id': '19',
        'name': 'QR Tech Windbreaker',
        'description': 'Технологиялық материалдан жасалған ветровка. Су өткізбейді.',
        'price': 29990.0,
        'image_url': '',
        'sizes': 'S,M,L,XL,XXL',
        'colors': 'Қара,Көк,Сұр',
        'category': 'Ветровки',
        'stock': 20
      },
      {
        'id': '20',
        'name': 'QR Retro Windbreaker',
        'description': 'Ретро стильдегі ветровка. 90-шы жылдардың рухы.',
        'price': 24990.0,
        'image_url': '',
        'sizes': 'S,M,L,XL',
        'colors': 'Қызыл,Көк,Жасыл',
        'category': 'Ветровки',
        'stock': 25
      },
      {
        'id': '21',
        'name': 'QR Coach Jacket',
        'description': 'Coach стильдегі жеңіл куртка. Көктемге арналған.',
        'price': 22990.0,
        'image_url': '',
        'sizes': 'S,M,L,XL,XXL',
        'colors': 'Қара,Қою көк,Сұр',
        'category': 'Ветровки',
        'stock': 30
      },
      
      // Аксессуары
      {
        'id': '22',
        'name': 'QR Snapback Cap',
        'description': 'Snapback стильдегі бейсболка. Реттелетін өлшем.',
        'price': 6990.0,
        'image_url': '',
        'sizes': 'Стандарт',
        'colors': 'Қара,Көк,Қызыл,Ақ',
        'category': 'Аксессуары',
        'stock': 50
      },
      {
        'id': '23',
        'name': 'QR Beanie Hat',
        'description': 'Жұмсақ шапка. Қысқы маусымға арналған.',
        'price': 4990.0,
        'image_url': '',
        'sizes': 'Стандарт',
        'colors': 'Қара,Сұр,Көк,Қызыл',
        'category': 'Аксессуары',
        'stock': 60
      },
      {
        'id': '24',
        'name': 'QR Canvas Bag',
        'description': 'Canvas материалынан жасалған сөмке. Экологиялық таза.',
        'price': 8990.0,
        'image_url': '',
        'sizes': 'Стандарт',
        'colors': 'Табиғи,Қара,Көк',
        'category': 'Аксессуары',
        'stock': 40
      },
      {
        'id': '25',
        'name': 'QR Leather Belt',
        'description': 'Нағыз теріден жасалған белдік. Premium сапа.',
        'price': 12990.0,
        'image_url': '',
        'sizes': 'S,M,L,XL',
        'colors': 'Қара,Қоңыр',
        'category': 'Аксессуары',
        'stock': 35
      },
      {
        'id': '26',
        'name': 'QR Socks Set',
        'description': 'Мақта шұлық жиынтығы. 3 жұп бірден.',
        'price': 3990.0,
        'image_url': '',
        'sizes': 'S,M,L,XL',
        'colors': 'Қара,Ақ,Сұр',
        'category': 'Аксессуары',
        'stock': 100
      },
      
      // Жаңа категория - Спорт киімдері
      {
        'id': '27',
        'name': 'QR Track Pants',
        'description': 'Спортты шалбар. Жаттығуға және демалысқа арналған.',
        'price': 11990.0,
        'image_url': '',
        'sizes': 'S,M,L,XL,XXL',
        'colors': 'Қара,Сұр,Көк',
        'category': 'Спорт киімдері',
        'stock': 45
      },
      {
        'id': '28',
        'name': 'QR Athletic Shorts',
        'description': 'Спортты шорт. Дем алатын материал.',
        'price': 7990.0,
        'image_url': '',
        'sizes': 'S,M,L,XL',
        'colors': 'Қара,Көк,Сұр,Жасыл',
        'category': 'Спорт киімдері',
        'stock': 55
      },
      
      // Жаңа категория - Жалпы киімдер  
      {
        'id': '29',
        'name': 'QR Denim Jacket',
        'description': 'Джинс куртка. Классикалық американдық стиль.',
        'price': 19990.0,
        'image_url': '',
        'sizes': 'S,M,L,XL,XXL',
        'colors': 'Көк,Қара',
        'category': 'Жалпы киімдер',
        'stock': 30
      },
      {
        'id': '30',
        'name': 'QR Cardigan',
        'description': 'Жұмсақ кардиган. Әйелдерге арналған модель.',
        'price': 16990.0,
        'image_url': '',
        'sizes': 'XS,S,M,L,XL',
        'colors': 'Сұр,Қоңыр,Көк,Қызыл',
        'category': 'Жалпы киімдер',
        'stock': 25
      }
    ];

    // Вставляем старые товары
    for (final product in oldProducts) {
      await db.insert('products', product);
    }
    
    // Вставляем новые товары
    for (final product in newProducts) {
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