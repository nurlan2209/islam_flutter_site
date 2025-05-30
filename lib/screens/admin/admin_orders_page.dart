import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../constants/text_styles.dart';
import '../../models/order.dart';
import '../../services/local_order_service.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({Key? key}) : super(key: key);

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final LocalOrderService _orderService = LocalOrderService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final orders = await _orderService.getAllOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Қайта жүктеу'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Text('Тапсырыстар тізімі бос'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          return _buildOrderItem(_orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderItem(Order order) {
    // Форматируем дату
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final formattedDate = dateFormat.format(order.orderDate);

    // Определяем цвет статуса
    Color statusColor;
    switch (order.status.toLowerCase()) {
      case 'в ожидании':
        statusColor = Colors.orange;
        break;
      case 'обработка':
        statusColor = Colors.blue;
        break;
      case 'отправленный':
        statusColor = Colors.indigo;
        break;
      case 'доставленный':
        statusColor = Colors.green;
        break;
      case 'отменен':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Тапсырыс #${order.id.substring(0, 8)}...',
                    style: AppTextStyles.heading4,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Клиент: ${order.userName}'),
            Text('Күн: $formattedDate'),
            Text('сомасы: ${order.totalAmount} ${AppStrings.currency}'),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Тауарлар (${order.items.length}):',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                  child: Text(
                      '${item.productName} x${item.quantity} - ${item.price * item.quantity} ${AppStrings.currency}'),
                )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: const Text('Толығырақ'),
                    onPressed: () => _showOrderDetails(order),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Күй'),
                    onPressed: () => _editOrderStatus(order),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    // Форматируем дату
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final formattedDate = dateFormat.format(order.orderDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Тапсырыс #${order.id.substring(0, 8)}...'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Клиент: ${order.userName}'),
              Text('Күн: $formattedDate'),
              Text('Күй: ${order.status}'),
              Text('сомасы: ${order.totalAmount} ${AppStrings.currency}'),
              const SizedBox(height: 16),
              const Text('Тауарлар:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Саны: ${item.quantity} x ${item.price} ${AppStrings.currency} = ${item.price * item.quantity} ${AppStrings.currency}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Жабу'),
          ),
        ],
      ),
    );
  }

  void _editOrderStatus(Order order) {
    final statusOptions = [
      'pending',
      'processing',
      'shipped',
      'delivered',
      'cancelled',
    ];
    
    String newStatus = order.status;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тапсырыс күйін өзгерту'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: statusOptions.map((status) => RadioListTile<String>(
              title: Text(status),
              value: status,
              groupValue: newStatus,
              onChanged: (value) {
                setState(() {
                  newStatus = value!;
                });
              },
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Болдырмау'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Показываем индикатор загрузки
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Күйді жаңарту...'),
                  duration: Duration(seconds: 1),
                ),
              );
              
              try {
                final success = await _orderService.updateOrderStatus(order.id, newStatus);
                
                if (success) {
                  await _loadOrders(); // Перезагружаем список заказов
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Тапсырыс күйі сәтті жаңартылды'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } else {
                  throw Exception('Күйді жаңарту мүмкін болмады');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Қате: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Сақтау'),
          ),
        ],
      ),
    );
  }
}
