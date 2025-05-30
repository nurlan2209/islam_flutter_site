import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';
  String _selectedCategory = '';
  String _sortBy = ''; // price_asc, price_desc, name

  List<Product> get products => _getFilteredProducts();
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;

  ProductProvider() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      final productsData = await db.query('products');
      
      _products = productsData.map((map) => Product.fromMap(map)).toList();
      
      // Собираем уникальные категории
      final Set<String> uniqueCategories = {};
      for (var product in _products) {
        uniqueCategories.add(product.category);
      }
      _categories = uniqueCategories.toList()..sort();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      final productsData = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (productsData.isEmpty) {
        return null;
      }
      
      return Product.fromMap(productsData.first);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> addProduct(Product product) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      // Генерируем ID для нового продукта
      var uuid = const Uuid();
      final productWithId = product.copyWith(id: uuid.v4());
      
      await db.insert('products', productWithId.toMap());
      
      // Обновляем список продуктов
      await loadProducts();
      
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

  Future<bool> updateProduct(Product product) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      await db.update(
        'products',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
      
      // Обновляем список продуктов
      await loadProducts();
      
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

  Future<bool> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = DatabaseService();
      await db.database; // Убедимся, что база данных инициализирована
      
      await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [productId],
      );
      
      // Обновляем список продуктов
      await loadProducts();
      
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

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  List<Product> _getFilteredProducts() {
    List<Product> result = List.from(_products);
    
    // Фильтрация по категории
    if (_selectedCategory.isNotEmpty) {
      result = result.where((product) => product.category == _selectedCategory).toList();
    }
    
    // Фильтрация по поисковому запросу
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((product) {
        return product.name.toLowerCase().contains(query) ||
               product.description.toLowerCase().contains(query);
      }).toList();
    }
    
    // Сортировка
    if (_sortBy.isNotEmpty) {
      switch (_sortBy) {
        case 'price_asc':
          result.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          result.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'name':
          result.sort((a, b) => a.name.compareTo(b.name));
          break;
      }
    }
    
    return result;
  }
}