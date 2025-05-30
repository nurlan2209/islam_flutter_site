import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/custom_button.dart';
import '../routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Загружаем продукты при открытии страницы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
      
      // Если пользователь авторизован, загружаем его корзину
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn) {
        Provider.of<CartProvider>(context, listen: false).loadCartItems(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          // Иконка корзины
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.cart);
                },
              ),
              if (authProvider.isLoggedIn && cartProvider.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cartProvider.itemCount.toString(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textLight,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          
          // Профиль или вход
          IconButton(
            icon: Icon(authProvider.isLoggedIn ? Icons.person : Icons.login),
            onPressed: () {
              if (authProvider.isLoggedIn) {
                _showProfileMenu(context);
              } else {
                Navigator.pushNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Баннер
                  _buildBanner(),
                  
                  const SizedBox(height: 24),
                  
                  // О бренде
                  _buildAboutSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Категории
                  _buildCategories(productProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Новые поступления
                  _buildNewArrivals(productProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Популярные товары
                  _buildPopularItems(productProvider),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildBanner() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Фоновое изображение
        Image.asset(
          'assets/images/banner.jpg',
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 300,
              width: double.infinity,
              color: AppColors.primary,
            );
          },
        ),
        
        // Затемнение
        Container(
          height: 300,
          width: double.infinity,
          color: Colors.black.withOpacity(0.5),
        ),
        
        // Текст и кнопка
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.welcomeTitle,
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.textLight,
                  fontSize: 32,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.welcomeSubtitle,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: AppStrings.exploreCollection,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.catalog);
                },
                isFullWidth: false,
                width: 200,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.aboutUs,
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.aboutUsDescription,
            style: AppTextStyles.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(ProductProvider productProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.categories,
                style: AppTextStyles.heading2,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.catalog);
                },
                child: Text(AppStrings.viewAll),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: productProvider.categories.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context, 
                      AppRoutes.catalog,
                      arguments: category,
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _getCategoryIcon(category),
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'футболкалар':
        return Icons.check_box_outline_blank;
      case 'худи':
        return Icons.people_alt_outlined;
      case 'жейде':
        return Icons.checkroom_outlined;
      default:
        return Icons.category;
    }
  }

  Widget _buildNewArrivals(ProductProvider productProvider) {
    // Для демонстрации просто показываем первые 4 товара
    final newProducts = productProvider.products.take(4).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.newArrivals,
                style: AppTextStyles.heading2,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.catalog);
                },
                child: Text(AppStrings.viewAll),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: newProducts.map((product) {
              return Container(
                width: 180,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ProductCard(product: product),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularItems(ProductProvider productProvider) {
    // Для демонстрации используем те же товары в другом порядке
    final popularProducts = List.from(productProvider.products.reversed).take(4).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.popularItems,
                style: AppTextStyles.heading2,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.catalog);
                },
                child: Text(AppStrings.viewAll),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: popularProducts.length,
          itemBuilder: (context, index) {
            return ProductCard(product: popularProducts[index]);
          },
        ),
      ],
    );
  }

  void _showProfileMenu(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(authProvider.user?.name ?? ''),
                  subtitle: Text(authProvider.user?.email ?? ''),
                ),
                const Divider(),
                if (authProvider.isAdmin)
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text(AppStrings.adminPanel),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.adminPanel);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: const Text(AppStrings.orders),
                  onTap: () {
                    Navigator.pop(context);
                    // Переход к экрану заказов (в будущем)
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text(AppStrings.logout),
                  onTap: () {
                    Navigator.pop(context);
                    authProvider.logout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}