import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/custom_button.dart';
import '../routes.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    
    // Если пользователь не авторизован
    if (!authProvider.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context, 0),
        body: _buildLoginPrompt(context),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, cartProvider.itemCount),
      body: cartProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            )
          : cartProvider.isEmpty
              ? _buildEmptyCart(context)
              : _buildCartContent(context, cartProvider, authProvider),
      bottomNavigationBar: cartProvider.isEmpty || cartProvider.isLoading
          ? null
          : _buildCheckoutBar(context, cartProvider),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, int itemCount) {
    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.cart.toUpperCase(),
            style: AppTextStyles.navigation.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          if (itemCount > 0)
            Text(
              '$itemCount товаров',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
      actions: [
        if (itemCount > 0)
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 24),
            onPressed: () => _showClearCartDialog(context),
            tooltip: 'Очистить корзину',
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
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
                Icons.shopping_bag_outlined,
                size: 60,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'ВОЙДИТЕ В АККАУНТ',
              style: AppTextStyles.heading2.copyWith(
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Чтобы просмотреть корзину и\nсделать заказ, необходимо войти в систему',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 280,
              child: CustomButton(
                text: AppStrings.login,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                showArrow: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 280,
              child: CustomButton(
                text: 'Продолжить покупки',
                type: ButtonType.outline,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.catalog);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
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
                Icons.shopping_bag_outlined,
                size: 70,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'КОРЗИНА ПУСТА',
              style: AppTextStyles.heading2.copyWith(
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Добавьте товары, чтобы\nпродолжить покупки',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 280,
              child: CustomButton(
                text: AppStrings.continueShopping,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.catalog);
                },
                showArrow: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    CartProvider cartProvider,
    AuthProvider authProvider,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: cartProvider.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final item = cartProvider.items[index];
        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.delete_outline,
                  color: AppColors.textLight,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'УДАЛИТЬ',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            return await _showRemoveItemDialog(context, item.productName ?? '');
          },
          onDismissed: (direction) {
            cartProvider.removeFromCart(item.id, authProvider.user!.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.productName} удален из корзины'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            );
          },
          child: CartItemWidget(
            item: item,
            onUpdateQuantity: (quantity) {
              cartProvider.updateQuantity(
                item.id,
                quantity,
                authProvider.user!.id,
              );
            },
            onRemove: () {
              cartProvider.removeFromCart(item.id, authProvider.user!.id);
            },
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartProvider cartProvider) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Итоговая информация
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ИТОГО:',
                        style: AppTextStyles.overline.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cartProvider.totalAmount.toInt()} ${AppStrings.currency}',
                        style: AppTextStyles.priceLarge.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${cartProvider.itemCount} товаров',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Кнопка оформления заказа
              CustomButton(
                text: AppStrings.checkout,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.payment,
                    arguments: cartProvider.totalAmount,
                  );
                },
                height: 64,
                showArrow: true,
              ),
              
              const SizedBox(height: 16),
              
              // Дополнительная информация
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Бесплатная доставка от 15 000 ₸',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
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

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          'ОЧИСТИТЬ КОРЗИНУ',
          style: AppTextStyles.heading3.copyWith(
            letterSpacing: 1.0,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите удалить все товары из корзины?',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel.toUpperCase(),
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final cartProvider = Provider.of<CartProvider>(context, listen: false);
              cartProvider.clearCart(authProvider.user!.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Корзина очищена'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textLight,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(
              'ОЧИСТИТЬ',
              style: AppTextStyles.buttonMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showRemoveItemDialog(BuildContext context, String productName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          'УДАЛИТЬ ТОВАР',
          style: AppTextStyles.heading4.copyWith(
            letterSpacing: 1.0,
          ),
        ),
        content: Text(
          'Удалить "$productName" из корзины?',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppStrings.cancel.toUpperCase(),
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textLight,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(
              'УДАЛИТЬ',
              style: AppTextStyles.buttonMedium,
            ),
          ),
        ],
      ),
    );
  }
}