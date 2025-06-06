import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../services/local_order_service.dart'; // Новый сервис
import '../../routes.dart';
import '../../utils/image_helper.dart';
import 'product_form.dart';
import 'users_list.dart';
import 'admin_orders_page.dart'; // Новый импорт

class AdminPanel extends StatefulWidget {
  final int initialTab;

  const AdminPanel({
    Key? key, 
    this.initialTab = 0,
  }) : super(key: key);

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: const Center(child: Text('Доступно только для администраторов')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Продукты'),
            Tab(text: 'Заказы'), // Изменили порядок (заказы стали вторым табом)
            Tab(text: 'Пользователи'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          const AdminOrdersPage(), // Используем отдельный виджет для заказов
          _buildUsersTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.addProduct),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildProductsTab() {
    final productProvider = Provider.of<ProductProvider>(context);
    
    return productProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : productProvider.products.isEmpty
            ? const Center(child: Text('Нет продуктов'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: productProvider.products.length,
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: ImageHelper.buildProductImage(
                            product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(product.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${product.price} ₸'),
                          Text('В наличии: ${product.stock}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.editProduct,
                                arguments: product,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => _confirmDeleteProduct(product),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }

  Widget _buildUsersTab() {
    return const UsersList();
  }

  void _confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить продукт'),
        content: Text('Вы уверены, что хотите удалить ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final productProvider = Provider.of<ProductProvider>(context, listen: false);
              try {
                await productProvider.deleteProduct(product.id);
                if (mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Продукт удален')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка при удалении: $e')),
                );
              }
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}