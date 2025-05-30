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
    
    // Если пользователь не авторизован, показываем экран с просьбой войти
    if (!authProvider.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.cart),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Себетті көру үшін жүйеге кіріңіз',
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: CustomButton(
                  text: AppStrings.login,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cart),
        actions: [
          if (cartProvider.itemCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmClearCart(context, cartProvider, authProvider),
              tooltip: AppStrings.clearCart,
            ),
        ],
      ),
      body: cartProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartProvider.isEmpty
              ? _buildEmptyCart()
              : _buildCartContent(context, cartProvider, authProvider),
      bottomNavigationBar: cartProvider.isEmpty || cartProvider.isLoading
          ? null
          : _buildCheckoutBar(context, cartProvider),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.emptyCart,
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 240,
            child: CustomButton(
              text: AppStrings.continueShopping,
              onPressed: () {},
              icon: Icons.arrow_back,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    CartProvider cartProvider,
    AuthProvider authProvider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartProvider.items.length,
      itemBuilder: (context, index) {
        final item = cartProvider.items[index];
        return Dismissible(
          key: Key(item.id),
          background: Container(
            color: AppColors.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(
              Icons.delete,
              color: AppColors.textLight,
            ),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            cartProvider.removeFromCart(item.id, authProvider.user!.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppStrings.removeFromCartSuccess)),
            );
          },
          child: Column(
            children: [
              CartItemWidget(
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
              if (index < cartProvider.items.length - 1)
                const Divider(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Общая сумма
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.total,
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  '${cartProvider.totalAmount} ${AppStrings.currency}',
                  style: AppTextStyles.price,
                ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Кнопка оформления заказа
            Expanded(
              child: CustomButton(
                text: AppStrings.checkout,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.payment,
                    arguments: cartProvider.totalAmount,
                  );
                },
                height: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearCart(
    BuildContext context,
    CartProvider cartProvider,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.clearCart),
        content: const Text('Себетті толығымен тазалауды қалайсыз ба?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              cartProvider.clearCart(authProvider.user!.id);
            },
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }
}