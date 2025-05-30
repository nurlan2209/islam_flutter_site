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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
      
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
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(authProvider, cartProvider),
      body: productProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Главный баннер в стиле Adidas
                  _buildHeroBanner(),
                  
                  const SizedBox(height: 80),
                  
                  // О бренде
                  _buildAboutSection(),
                  
                  const SizedBox(height: 80),
                  
                  // Категории
                  _buildCategories(productProvider),
                  
                  const SizedBox(height: 80),
                  
                  // Новые поступления
                  _buildNewArrivals(productProvider),
                  
                  const SizedBox(height: 80),
                  
                  // Популярные товары
                  _buildPopularItems(productProvider),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(AuthProvider authProvider, CartProvider cartProvider) {
    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Text(
        AppStrings.appName.toUpperCase(),
        style: AppTextStyles.navigation.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      ),
      actions: [
        // Поиск
        IconButton(
          icon: const Icon(Icons.search, size: 24),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.catalog);
          },
        ),
        
        // Корзина в стиле Adidas
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, size: 24),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.cart);
              },
            ),
            if (authProvider.isLoggedIn && cartProvider.itemCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      cartProvider.itemCount.toString(),
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.textLight,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        // Профиль
        IconButton(
          icon: Icon(
            authProvider.isLoggedIn ? Icons.person_outline : Icons.person_outline,
            size: 24,
          ),
          onPressed: () {
            if (authProvider.isLoggedIn) {
              _showProfileMenu(context);
            } else {
              Navigator.pushNamed(context, AppRoutes.login);
            }
          },
        ),
        
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      height: 600,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        image: DecorationImage(
          image: AssetImage('assets/images/banner.jpg'),
          fit: BoxFit.cover,
          onError: (error, stackTrace) {},
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.bannerGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Основной заголовок как у Adidas
              Text(
                'QAZAQ\nREPUBLIC',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.textLight,
                  fontSize: 64,
                  height: 0.9,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'CLASSIC',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.textLight,
                  fontSize: 48,
                  letterSpacing: 4.0,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                AppStrings.welcomeSubtitle.toUpperCase(),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textLight,
                  letterSpacing: 1.0,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Кнопка в стиле Adidas
              _buildAdidasButton(
                text: AppStrings.exploreCollection.toUpperCase(),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.catalog);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdidasButton({
    required String text,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return Container(
      height: 56,
      constraints: const BoxConstraints(minWidth: 200),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? AppColors.background : AppColors.primary,
          foregroundColor: isOutlined ? AppColors.primary : AppColors.textLight,
          side: isOutlined ? const BorderSide(color: AppColors.primary, width: 2) : null,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Прямоугольные кнопки как у Adidas
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: AppTextStyles.buttonLarge.copyWith(
                color: isOutlined ? AppColors.primary : AppColors.textLight,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.arrow_forward,
              size: 20,
              color: isOutlined ? AppColors.primary : AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.aboutUs.toUpperCase(),
            style: AppTextStyles.heading1.copyWith(
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.aboutUsDescription,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
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
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.categories.toUpperCase(),
                style: AppTextStyles.heading2.copyWith(
                  letterSpacing: 1.5,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.catalog);
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(
                  AppStrings.viewAll.toUpperCase(),
                  style: AppTextStyles.navigation,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Container(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            itemCount: productProvider.categories.length,
            itemBuilder: (context, index) {
              final category = productProvider.categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 24),
                child: _buildCategoryCard(category),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String category) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          AppRoutes.catalog,
          arguments: category,
        );
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              category.toUpperCase(),
              style: AppTextStyles.categoryLabel.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'футболкалар':
        return Icons.checkroom_outlined;
      case 'худи':
        return Icons.dry_cleaning_outlined;
      case 'жейде':
        return Icons.business_center_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildNewArrivals(ProductProvider productProvider) {
    final newProducts = productProvider.products.take(4).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.newArrivals.toUpperCase(),
                style: AppTextStyles.heading2.copyWith(
                  letterSpacing: 1.5,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.catalog);
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(
                  AppStrings.viewAll.toUpperCase(),
                  style: AppTextStyles.navigation,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Container(
          height: 400,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            itemCount: newProducts.length,
            itemBuilder: (context, index) {
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 24),
                child: ProductCard(product: newProducts[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularItems(ProductProvider productProvider) {
    final popularProducts = List.from(productProvider.products.reversed).take(6).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.popularItems.toUpperCase(),
                style: AppTextStyles.heading2.copyWith(
                  letterSpacing: 1.5,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.catalog);
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(
                  AppStrings.viewAll.toUpperCase(),
                  style: AppTextStyles.navigation,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 32,
              childAspectRatio: 0.75,
            ),
            itemCount: popularProducts.length,
            itemBuilder: (context, index) {
              return ProductCard(product: popularProducts[index]);
            },
          ),
        ),
      ],
    );
  }

  void _showProfileMenu(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'МОЙ АККАУНТ',
                  style: AppTextStyles.heading3.copyWith(
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 32),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.textLight,
                    ),
                  ),
                  title: Text(
                    authProvider.user?.name ?? '',
                    style: AppTextStyles.productTitle,
                  ),
                  subtitle: Text(
                    authProvider.user?.email ?? '',
                    style: AppTextStyles.productSubtitle,
                  ),
                ),
                const SizedBox(height: 32),
                if (authProvider.isAdmin)
                  _buildMenuTile(
                    icon: Icons.admin_panel_settings_outlined,
                    title: AppStrings.adminPanel,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.adminPanel);
                    },
                  ),
                _buildMenuTile(
                  icon: Icons.shopping_bag_outlined,
                  title: AppStrings.orders,
                  onTap: () {
                    Navigator.pop(context);
                    // Здесь можно добавить переход к заказам пользователя
                  },
                ),
                _buildMenuTile(
                  icon: Icons.settings_outlined,
                  title: 'НАСТРОЙКИ',
                  onTap: () {
                    Navigator.pop(context);
                    // Здесь можно добавить экран настроек
                  },
                ),
                _buildMenuTile(
                  icon: Icons.help_outline,
                  title: 'ПОМОЩЬ',
                  onTap: () {
                    Navigator.pop(context);
                    // Здесь можно добавить экран помощи
                  },
                ),
                _buildMenuTile(
                  icon: Icons.logout,
                  title: AppStrings.logout,
                  onTap: () {
                    Navigator.pop(context);
                    authProvider.logout();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 24,
        ),
        title: Text(
          title.toUpperCase(),
          style: AppTextStyles.navigation.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: onTap,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        hoverColor: AppColors.hoverOverlay,
      ),
    );
  }
}