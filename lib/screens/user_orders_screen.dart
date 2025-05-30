import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/text_styles.dart';
import '../providers/auth_provider.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/local_order_service.dart';
import '../providers/product_provider.dart';

class UserOrdersScreen extends StatefulWidget {
  const UserOrdersScreen({Key? key}) : super(key: key);

  @override
  State<UserOrdersScreen> createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  final LocalOrderService _orderService = LocalOrderService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadUserOrders();
  }

  Future<void> _loadUserOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isLoggedIn) {
        setState(() {
          _error = 'Пользователь не авторизован';
          _isLoading = false;
        });
        return;
      }

      final orders = await _orderService.getUserOrders(authProvider.user!.id);
      
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'ТАПСЫРЫСТАР',
        style: AppTextStyles.navigation.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 24),
          onPressed: _loadUserOrders,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    if (_error.isNotEmpty) {
      return _buildErrorState();
    }

    if (_orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadUserOrders,
      color: AppColors.primary,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок секции
            Text(
              'МЕНІҢ ТАПСЫРЫСТАРЫМ',
              style: AppTextStyles.heading2.copyWith(
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Сетка заказов
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final crossAxisCount = screenWidth > 1200 ? 4 : (screenWidth > 800 ? 3 : 2);
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.4, // Еще больше уменьшена высота
                  ),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(_orders[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'ОШИБКА ЗАГРУЗКИ',
              style: AppTextStyles.heading2.copyWith(
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _error,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _loadUserOrders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'ПОВТОРИТЬ',
                  style: AppTextStyles.buttonMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 70,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'ТАПСЫРЫСТАР ЖОҚ',
              style: AppTextStyles.heading2.copyWith(
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Сіз әлі ешқандай тапсырыс\nжасаған жоқсыз',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 280,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'САУДА ЖАСАУ',
                      style: AppTextStyles.buttonMedium,
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final formattedDate = dateFormat.format(order.orderDate);

    return GestureDetector(
      onTap: () => _showOrderDetails(order),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхняя часть - номер заказа и статус
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.id.substring(0, 6).toUpperCase()}',
                      style: AppTextStyles.heading4.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        fontSize: 16, // Увеличен размер шрифта
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // Дата заказа
              Text(
                formattedDate,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 16, // Увеличен размер
                ),
              ),
              
              const SizedBox(height: 14),
              
              // Фото первого товара и количество товаров
              if (order.items.isNotEmpty)
                Row(
                  children: [
                    // Фото первого товара
                    _buildProductImage(order.items.first.productId),
                    const SizedBox(width: 14),
                    
                    // Информация о товарах
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Название первого товара
                          Text(
                            order.items.first.productName,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13, // Увеличен размер
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          
                          // Количество товаров
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.lightGray,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${order.items.length} ТАУАР',
                              style: AppTextStyles.overline.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 10, // Увеличен размер
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              
              if (order.items.length > 1) ...[
                const SizedBox(height: 8),
                Text(
                  '+${order.items.length - 1} ЕЩЕ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12, // Увеличен размер
                  ),
                ),
              ],
              
              const Spacer(),
              
              // Разделитель
              Container(
                height: 1,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),
              
              // Итоговая сумма
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'СОМА:',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      fontSize: 12, // Увеличен размер
                    ),
                  ),
                  Text(
                    '${order.totalAmount.toInt()} ₸',
                    style: AppTextStyles.price.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 16, // Увеличен размер
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String productId) {
    return FutureBuilder<Product?>(
      future: Provider.of<ProductProvider>(context, listen: false).getProductById(productId),
      builder: (context, snapshot) {
        String imageUrl = '';
        if (snapshot.hasData && snapshot.data != null) {
          imageUrl = snapshot.data!.imageUrl;
        }
        
        return Container(
          width: 105, // Увеличен размер фото
          height: 105,
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: imageUrl.isNotEmpty
                ? Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textSecondary,
                        size: 28, // Увеличена иконка
                      );
                    },
                  )
                : const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textSecondary,
                    size: 28, // Увеличена иконка
                  ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color statusColor;
    String statusText;
    
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = AppColors.warning;
        statusText = 'КҮТУ';
        break;
      case 'processing':
        statusColor = AppColors.info;
        statusText = 'ӨҢДЕУ';
        break;
      case 'shipped':
        statusColor = AppColors.accent;
        statusText = 'ЖІБЕРУ';
        break;
      case 'delivered':
        statusColor = AppColors.success;
        statusText = 'ДАЙЫН';
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        statusText = 'БАС ТАРТУ';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Увеличен padding
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.overline.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w700,
          fontSize: 10, // Увеличен размер шрифта
        ),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final formattedDate = dateFormat.format(order.orderDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          'ТАПСЫРЫС #${order.id.substring(0, 8).toUpperCase()}',
          style: AppTextStyles.heading3.copyWith(
            letterSpacing: 1.0,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Күн: $formattedDate',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Күй: ',
                    style: AppTextStyles.bodyMedium,
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Сома: ${order.totalAmount.toInt()} ${AppStrings.currency}',
                style: AppTextStyles.price,
              ),
              const SizedBox(height: 16),
              Text(
                'ТАУАРЛАР:',
                style: AppTextStyles.heading4.copyWith(
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    _buildProductImage(item.productId),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Саны: ${item.quantity} x ${item.price.toInt()} ₸ = ${(item.price * item.quantity).toInt()} ₸',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
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
            child: Text(
              'ЖАБУ',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}