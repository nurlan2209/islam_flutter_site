import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
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
      backgroundColor: Colors.white,
      body: productProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            )
          : CustomScrollView(
              slivers: [
                // App Bar
                _buildAppBar(authProvider, cartProvider),
                
                // Hero Section
                _buildHeroSection(),
                
                // Categories Section
                _buildCategoriesSection(),
                
                // Products Section
                _buildProductsSection(productProvider),
              ],
            ),
    );
  }

  Widget _buildAppBar(AuthProvider authProvider, CartProvider cartProvider) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      floating: true,
      pinned: true,
      toolbarHeight: 70, // Уменьшил с 80 до 70
      flexibleSpace: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15), // Уменьшил отступы
        child: Row(
          children: [
            // Меню кнопка для мобилки
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 22),
              onPressed: () {
                _showMobileMenu(context);
              },
              padding: const EdgeInsets.all(8),
            ),

            // Logo (компактнее для мобилки)
            Expanded(
              child: Center(
                child: Text(
                  'QAZAQ REPUBLIC',
                  style: TextStyle(
                    fontSize: 16, // Немного увеличил для центрального расположения
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            // Icons (компактнее)
            Row(
              children: [
                // Search
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black, size: 22), // Уменьшил размер
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.catalog);
                  },
                  padding: const EdgeInsets.all(8), // Уменьшил padding
                ),

                // Cart с badge
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 22),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.cart);
                      },
                      padding: const EdgeInsets.all(8),
                    ),
                    if (authProvider.isLoggedIn && cartProvider.itemCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 16, // Уменьшил с 18
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              cartProvider.itemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10, // Уменьшил с 11
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Profile (меньше размер)
                Container(
                  width: 40, // Уменьшил с 48
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.person, color: Colors.white, size: 20), // Уменьшил размер
                    onPressed: () {
                      if (authProvider.isLoggedIn) {
                        _showProfileMenu(context);
                      } else {
                        Navigator.pushNamed(context, AppRoutes.login);
                      }
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Мобильное меню
  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'МЕНЮ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 24),
                _buildMobileMenuItem('КАТАЛОГ', Icons.grid_view, () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.catalog);
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: Icon(
          icon,
          color: Colors.black,
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        onTap: onTap,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.black54,
        ),
      ),
    );
  }
  Widget _buildNavItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 500, // Уменьшил с 600 до 500 для мобилки
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Уменьшил отступы
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/banner.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE8E8E8),
                    );
                  },
                ),
              ),
            ),
            
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.8), // Увеличил непрозрачность
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Content (адаптированный для мобилки)
            Positioned(
              left: 24, // Уменьшил с 60 до 24
              top: 0,
              bottom: 0,
              right: 24, // Добавил правый отступ
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок (разбил на отдельные строки)
                  Text(
                    'QAZAQ',
                    style: TextStyle(
                      fontSize: 32, // Уменьшил с 56 до 32
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 0.9,
                    ),
                  ),
                  Text(
                    'REPUBLIC',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 0.9,
                    ),
                  ),
                  Text(
                    'CLASSIC',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 0.9,
                    ),
                  ),
                  const SizedBox(height: 16), // Уменьшил с 20
                  Text(
                    'Қазақстандық классикалық\nкиім бренді',
                    style: TextStyle(
                      fontSize: 14, // Уменьшил с 16
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32), // Добавил отступ перед кнопкой
                  
                  // Кнопка (переместил в основной контент)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.catalog);
                      },
                      child: const Text(
                        'В КАТАЛОГ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32), // Уменьшил отступы
        child: Column(
          children: [
            // Categories Grid
            Row(
              children: [
                // Left Category
                Expanded(
                  child: Container(
                    height: 220, // Уменьшил с 280 до 220
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Category List
                        Positioned(
                          left: 20, // Уменьшил с 30 до 20
                          top: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCategoryItem('ФУТБОЛКАЛАР'),
                              _buildCategoryItem('ХУДИ'),
                              _buildCategoryItem('ЖЕЙДЕ'),
                              _buildCategoryItem('СВИТШОТЫ'),
                              _buildCategoryItem('ВЕТРОВКИ'),
                              _buildCategoryItem('АКСЕССУАРЫ'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 12), // Уменьшил с 20 до 12
                
                // Right Category
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context, 
                        AppRoutes.catalog, 
                        arguments: 'ЛЕТНЯЯ_КОЛЛЕКЦИЯ'
                      );
                    },
                    child: Container(
                      height: 220, // Уменьшил с 280 до 220
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8E8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          // Background Image
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/banner2.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFFE8E8E8),
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          // Gradient Overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7), // Увеличил непрозрачность
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Text (адаптированный для мобилки)
                          Positioned(
                            bottom: 20, // Уменьшил с 30 до 20
                            left: 16,   // Уменьшил с 30 до 16
                            right: 16,  // Добавил правый отступ
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ЛЕТНЯЯ',
                                  style: TextStyle(
                                    fontSize: 16, // Уменьшил с 20
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                    height: 1.0,
                                  ),
                                ),
                                Text(
                                  'КОЛЛЕКЦИЯ',
                                  style: TextStyle(
                                    fontSize: 16, // Уменьшил с 20
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCategoryItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8), // Уменьшил с 12 до 8
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.catalog, arguments: title);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2), // Уменьшил с 4 до 2
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12, // Уменьшил с 14 до 12
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsSection(ProductProvider productProvider) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            children: [
              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'БЕСТСЕЛЛЕРЫ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.catalog);
                      },
                      child: const Text(
                        'В КАТАЛОГ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Products Horizontal List - УВЕЛИЧИЛ ВЫСОТУ И ШИРИНУ
              SizedBox(
                height: 380, // Увеличил с 320 до 380
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.products[index];
                    return Container(
                      width: 230, // Увеличил с 200 до 230
                      margin: const EdgeInsets.only(right: 16),
                      child: _buildMobileProductCard(product),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  Widget _buildMobileProductCard(product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: product,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image - ИЗМЕНИЛ ПРОПОРЦИИ
            Expanded(
              flex: 5, // Увеличил с 3 до 5 для картинки
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? Image.asset(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: Colors.black26,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: Colors.black26,
                          ),
                        ),
                ),
              ),
            ),
            
            // Product Info - УВЕЛИЧИЛ МЕСТО ДЛЯ ТЕКСТА
            Expanded(
              flex: 3, // Увеличил с 1 до 3 для текста
              child: Padding(
                padding: const EdgeInsets.all(16), // Увеличил отступы
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Изменил на spaceEvenly
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 15, // Увеличил размер шрифта
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.2, // Добавил межстрочный интервал
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Price and Category
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product.price.toInt()} ₸',
                          style: const TextStyle(
                            fontSize: 17, // Увеличил размер
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4), // Добавил отступ
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12, // Увеличил размер
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModernProductCard(product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: product,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? Image.asset(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 60,
                                color: Colors.black26,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 60,
                            color: Colors.black26,
                          ),
                        ),
                ),
              ),
            ),
            
            // Product Info
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price.toInt()} ₸',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'МОЙ АККАУНТ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
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
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    authProvider.user?.name ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    authProvider.user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
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
                    Navigator.pushNamed(context, AppRoutes.userOrders);
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
          color: Colors.black,
          size: 24,
        ),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        onTap: onTap,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.black54,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    );
  }
}