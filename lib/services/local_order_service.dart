import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/user.dart';
import '../models/product.dart';
import 'database_service.dart';

class LocalOrderService {
  static final LocalOrderService _instance = LocalOrderService._internal();
  
  factory LocalOrderService() => _instance;
  
  LocalOrderService._internal();

  // Создание нового заказа из товаров в корзине
  Future<String?> createOrderFromCart({
    required String userId, 
    required String userName,
    required List<CartItem> cartItems,
    required double totalAmount,
    required String address,
    required String paymentMethod,
  }) async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      if (cartItems.isEmpty) {
        return null;
      }
      
      // Создаем ID для нового заказа
      var uuid = const Uuid();
      final orderId = uuid.v4();
      
      // Создаем запись о заказе
      await db.insert('orders', {
        'id': orderId,
        'userId': userId,
        'userName': userName,
        'orderDate': DateTime.now().toIso8601String(),
        'totalAmount': totalAmount,
        'status': 'pending', // Начальный статус - в ожидании
        'address': address,
        'paymentMethod': paymentMethod,
      });
      
      // Создаем записи о товарах в заказе
      for (var item in cartItems) {
        await db.insert('order_items', {
          'id': uuid.v4(),
          'orderId': orderId,
          'productId': item.productId,
          'productName': item.productName ?? 'Неизвестный товар',
          'quantity': item.quantity,
          'price': item.productPrice ?? 0.0,
          'selectedSize': item.selectedSize,
          'selectedColor': item.selectedColor,
        });
        
        // Обновляем остаток товара на складе
        final productResult = await db.query(
          'products',
          where: 'id = ?',
          whereArgs: [item.productId],
        );
        
        if (productResult.isNotEmpty) {
          final product = Product.fromMap(productResult.first);
          final newStock = product.stock - item.quantity;
          
          // Убедимся, что количество не уйдет в минус
          final updatedStock = newStock < 0 ? 0 : newStock;
          
          await db.update(
            'products',
            {'stock': updatedStock},
            where: 'id = ?',
            whereArgs: [item.productId],
          );
        }
      }
      
      return orderId;
    } catch (e) {
      print('Create order error: $e');
      return null;
    }
  }

  // Получение всех заказов
  Future<List<Order>> getAllOrders() async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      final ordersData = await db.query('orders');
      final List<Order> orders = [];
      
      for (var orderData in ordersData) {
        // Получаем товары для каждого заказа
        final orderItemsData = await db.query(
          'order_items',
          where: 'orderId = ?',
          whereArgs: [orderData['id']],
        );
        
        final items = orderItemsData.map((item) => OrderItem(
          productId: item['productId'] as String,
          productName: item['productName'] as String,
          quantity: item['quantity'] as int,
          price: (item['price'] is int) 
              ? (item['price'] as int).toDouble() 
              : item['price'] as double,
        )).toList();
        
        orders.add(Order(
          id: orderData['id'] as String,
          userId: orderData['userId'] as String,
          userName: orderData['userName'] as String,
          orderDate: DateTime.parse(orderData['orderDate'] as String),
          totalAmount: (orderData['totalAmount'] is int) 
              ? (orderData['totalAmount'] as int).toDouble() 
              : orderData['totalAmount'] as double,
          status: orderData['status'] as String,
          items: items,
        ));
      }
      
      // Сортируем заказы по дате (новые сверху)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      
      return orders;
    } catch (e) {
      print('Get all orders error: $e');
      return [];
    }
  }

  // Обновление статуса заказа
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      await db.update(
        'orders',
        {'status': newStatus},
        where: 'id = ?',
        whereArgs: [orderId],
      );
      
      return true;
    } catch (e) {
      print('Update order status error: $e');
      return false;
    }
  }

  // Получение заказов пользователя
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      final ordersData = await db.query(
        'orders',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      
      final List<Order> orders = [];
      
      for (var orderData in ordersData) {
        // Получаем товары для каждого заказа
        final orderItemsData = await db.query(
          'order_items',
          where: 'orderId = ?',
          whereArgs: [orderData['id']],
        );
        
        final items = orderItemsData.map((item) => OrderItem(
          productId: item['productId'] as String,
          productName: item['productName'] as String,
          quantity: item['quantity'] as int,
          price: (item['price'] is int) 
              ? (item['price'] as int).toDouble() 
              : item['price'] as double,
        )).toList();
        
        orders.add(Order(
          id: orderData['id'] as String,
          userId: orderData['userId'] as String,
          userName: orderData['userName'] as String,
          orderDate: DateTime.parse(orderData['orderDate'] as String),
          totalAmount: (orderData['totalAmount'] is int) 
              ? (orderData['totalAmount'] as int).toDouble() 
              : orderData['totalAmount'] as double,
          status: orderData['status'] as String,
          items: items,
        ));
      }
      
      // Сортируем заказы по дате (новые сверху)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      
      return orders;
    } catch (e) {
      print('Get user orders error: $e');
      return [];
    }
  }
}