import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  String _error = '';

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;
  
  // Общая сумма всех товаров в корзине
  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + (item.productPrice ?? 0) * item.quantity);
  }

  Future<void> loadCartItems(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Получаем все элементы корзины для данного пользователя
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      final cartItemsData = await db.rawQuery('''
        SELECT c.*, p.name as product_name, p.price as product_price, p.image_url as product_image_url
        FROM cart_items c
        JOIN products p ON c.product_id = p.id
        WHERE c.user_id = ?
      ''', [userId]);
      
      _items = cartItemsData.map((map) => CartItem.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addToCart({
    required String userId,
    required String productId,
    required int quantity,
    required String selectedSize,
    required String selectedColor,
    String? productName,
    double? productPrice,
    String? productImageUrl,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

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
      
      // Обновляем корзину
      await loadCartItems(userId);
      
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

  Future<bool> updateQuantity(String cartItemId, int quantity, String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      await db.update(
        'cart_items',
        {'quantity': quantity},
        where: 'id = ?',
        whereArgs: [cartItemId],
      );
      
      // Обновляем корзину
      await loadCartItems(userId);
      
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

  Future<bool> removeFromCart(String cartItemId, String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      await db.delete(
        'cart_items',
        where: 'id = ?',
        whereArgs: [cartItemId],
      );
      
      // Обновляем корзину
      await loadCartItems(userId);
      
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

  Future<bool> clearCart(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      await db.delete(
        'cart_items',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      _items = [];
      
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
}