import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/admin/admin_panel.dart';
import 'screens/admin/admin_orders_page.dart';
import 'screens/admin/product_form.dart';
import 'screens/admin/users_list.dart';
import 'models/product.dart';


class AppRoutes {
  static const String home = '/';
  static const String catalog = '/catalog';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String payment = '/payment';
  static const String login = '/login';
  static const String register = '/register';
  static const String adminPanel = '/admin-panel';
  static const String adminProducts = '/admin-products';
  static const String addProduct = '/add-product';
  static const String editProduct = '/edit-product';
  static const String adminUsers = '/admin-users';
  static const String adminOrders = '/admin-orders'; // Добавьте этот маршрут


  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case catalog:
        final String? category = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CatalogScreen(category: category),
        );
      
      case productDetail:
        final product = settings.arguments as Product;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        );
      
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      
      case payment:
        final double? total = settings.arguments as double?;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(totalAmount: total ?? 0),
        );
      
      case login:
        return MaterialPageRoute(
          builder: (_) => const AuthScreen(isLogin: true),
        );
      
      case register:
        return MaterialPageRoute(
          builder: (_) => const AuthScreen(isLogin: false),
        );
      
      case adminPanel:
        return MaterialPageRoute(builder: (_) => const AdminPanel());
      
      case adminProducts:
        return MaterialPageRoute(
          builder: (_) => const AdminPanel(initialTab: 0),
        );
      
      case addProduct:
        return MaterialPageRoute(builder: (_) => const ProductForm());
      
      case editProduct:
        final product = settings.arguments as Product;
        return MaterialPageRoute(
          builder: (_) => ProductForm(product: product),
        );

      case adminUsers:
        return MaterialPageRoute(
          builder: (_) => const AdminPanel(initialTab: 1),
        );
      case adminOrders: // Добавьте этот маршрут
        return MaterialPageRoute(
          builder: (_) => const AdminPanel(initialTab: 2),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}