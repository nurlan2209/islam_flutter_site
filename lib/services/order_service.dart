import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderService {
  static const String apiUrl = 'http://localhost:8080';

  Future<List<Order>> getAllOrders() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/orders'));
      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = json.decode(response.body);
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/orders/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update order status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  Future<String> createOrder(Order order) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': order.userId,
          'userName': order.userName,
          'orderDate': order.orderDate.toIso8601String(),
          'totalAmount': order.totalAmount,
          'status': order.status,
          'items': order.items.map((item) => {
            'productId': item.productId,
            'productName': item.productName,
            'quantity': item.quantity,
            'price': item.price,
          }).toList(),
        }),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['id']; // Предполагаем, что API возвращает ID созданного заказа
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }
}