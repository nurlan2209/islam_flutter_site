import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import './database_service.dart';
import 'product_service.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  
  factory CartService() => _instance;
  
  CartService._internal();

  /// Получение всех элементов корзины пользователя
  Future<List<CartItem>> getCartItems(String userId) async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      // Получаем элементы корзины с информацией о товарах
      final cartItemsData = await db.rawQuery('''
        SELECT c.*, p.name as product_name, p.price as product_price, p.image_url as product_image_url
        FROM cart_items c
        JOIN products p ON c.product_id = p.id
        WHERE c.user_id = ?
      ''', [userId]);
      
      return cartItemsData.map((map) => CartItem.fromMap(map)).toList();
    } catch (e) {
      print('Get cart items error: $e');
      return [];
    }
  }
  
  /// Добавление товара в корзину
  Future<bool> addToCart({
    required String userId,
    required String productId,
    required int quantity,
    required String selectedSize,
    required String selectedColor,
  }) async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      // Проверяем, есть ли уже такой товар в корзине
      final existingItems = await db.query(
        'cart_items',
        where: 'user_id = ? AND product_id = ? AND selected_size = ? AND selected_color = ?',
        whereArgs: [userId, productId, selectedSize, selectedColor],
      );
      
      if (existingItems.isNotEmpty) {
        // Если товар уже есть, увеличиваем количество
        final existingItem = CartItem.fromMap(existingItems.first);
        final updatedQuantity = existingItem.quantity + quantity;
        
        await db.update(
          'cart_items',
          {'quantity': updatedQuantity},
          where: 'id = ?',
          whereArgs: [existingItem.id],
        );
      } else {
        // Если товара нет, добавляем новый
        var uuid = const Uuid();
        final newCartItem = CartItem(
          id: uuid.v4(),
          userId: userId,
          productId: productId,
          quantity: quantity,
          selectedSize: selectedSize,
          selectedColor: selectedColor,
        );
        
        await db.insert('cart_items', newCartItem.toMap());
      }
      
      return true;
    } catch (e) {
      print('Add to cart error: $e');
      return false;
    }
  }
  
  /// Обновление количества товара в корзине
  Future<bool> updateCartItemQuantity(
    String cartItemId,
    int quantity,
  ) async {
    try {
      if (quantity <= 0) {
        return false;
      }
      
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      await db.update(
        'cart_items',
        {'quantity': quantity},
        where: 'id = ?',
        whereArgs: [cartItemId],
      );
      
      return true;
    } catch (e) {
      print('Update cart item quantity error: $e');
      return false;
    }
  }
  
  /// Удаление товара из корзины
  Future<bool> removeFromCart(String cartItemId) async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      await db.delete(
        'cart_items',
        where: 'id = ?',
        whereArgs: [cartItemId],
      );
      
      return true;
    } catch (e) {
      print('Remove from cart error: $e');
      return false;
    }
  }
  
  /// Очистка корзины пользователя
  Future<bool> clearCart(String userId) async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      await db.delete(
        'cart_items',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      return true;
    } catch (e) {
      print('Clear cart error: $e');
      return false;
    }
  }
  
  /// Получение общей суммы корзины
Future<double> getCartTotal(String userId) async {
  try {
    final items = await getCartItems(userId);
    double total = 0;
    for (var item in items) {
      total += (item.productPrice ?? 0) * item.quantity;
    }
    return total;
  } catch (e) {
    print('Get cart total error: $e');
    return 0;
  }
}
  /// Создание заказа из корзины
  Future<String?> createOrder(
    String userId,
    String address,
    String phone,
    String paymentMethod,
  ) async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      // Получаем содержимое корзины
      final cartItems = await getCartItems(userId);
      
      if (cartItems.isEmpty) {
        return null;
      }
      
      // Вычисляем общую сумму
      final totalAmount = await getCartTotal(userId);
      
      // Создаем запись о заказе
      var uuid = const Uuid();
      final orderId = uuid.v4();
      
      await db.insert('orders', {
        'id': orderId,
        'user_id': userId,
        'total_amount': totalAmount,
        'order_date': DateTime.now().toIso8601String(),
        'status': 'pending', // Начальный статус - в ожидании
        'address': address,
        'phone': phone,
      });
      
      // Создаем записи о товарах в заказе
      for (var item in cartItems) {
        final db = DatabaseService();
        final result = await db.query(
          'products',
          where: 'id = ?',
          whereArgs: [item.productId],
        );
        final product = result.isNotEmpty ? Product.fromMap(result.first) : null;

        
        if (product != null) {
          await db.insert('order_items', {
            'id': uuid.v4(),
            'order_id': orderId,
            'product_id': item.productId,
            'quantity': item.quantity,
            'price': product.price,
            'selected_size': item.selectedSize,
            'selected_color': item.selectedColor,
          });
          
          // Обновляем остаток товара на складе
          final newStock = product.stock - item.quantity;
          await db.update(
            'products',
            {'stock': newStock},
            where: 'id = ?',
            whereArgs: [item.productId],
          );

        }
      }
      
      // Очищаем корзину
      await clearCart(userId);
      
      return orderId;
    } catch (e) {
      print('Create order error: $e');
      return null;
    }
  }
}