import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/text_styles.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_button.dart';
import '../routes.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late String _selectedSize;
  late String _selectedColor;
  int _quantity = 1;
  bool _isAddingToCart = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.sizes.isNotEmpty ? widget.product.sizes.first : '';
    _selectedColor = widget.product.colors.isNotEmpty ? widget.product.colors.first : '';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      bottomNavigationBar: _buildBottomBar(authProvider, cartProvider),
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
        'ӨНІМ ТУРАЛЫ',
        style: AppTextStyles.navigation.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? AppColors.favoriteActive : AppColors.textPrimary,
            size: 24,
          ),
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined, size: 24),
          onPressed: () {
            // Логика поделиться
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Левая часть - изображение
            Expanded(
              flex: 3,
              child: _buildProductImage(),
            ),
            
            const SizedBox(width: 60),
            
            // Правая часть - информация
            Expanded(
              flex: 2,
              child: _buildProductInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение товара
          _buildProductImage(),
          
          // Информация о товаре
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildProductInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: double.infinity,
      height: 600,
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Stack(
        children: [
          // Основное изображение
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: widget.product.imageUrl.isNotEmpty
                ? (widget.product.imageUrl.startsWith('http')
                    ? Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      )
                    : Image.asset(
                        widget.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ))
                : _buildImagePlaceholder(),
          ),
          
          // Индикатор наличия
          if (widget.product.stock <= 5 && widget.product.stock > 0)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.9),
                ),
                child: Text(
                  'ҚАЛДЫ ${widget.product.stock} ДАНА',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          
          // Нет в наличии
          if (widget.product.stock == 0)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.9),
                ),
                child: Text(
                  AppStrings.outOfStock.toUpperCase(),
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.lightGray,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_not_supported_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'СУРЕТ ЖОҚ',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Категория
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Text(
            widget.product.category.toUpperCase(),
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Название товара
        Text(
          widget.product.name,
          style: AppTextStyles.displayMedium.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Цена
        Text(
          '${widget.product.price.toInt()} ${AppStrings.currency}',
          style: AppTextStyles.priceLarge.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Описание
        Text(
          'СИПАТТАМА',
          style: AppTextStyles.heading4.copyWith(
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.product.description,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Выбор размера
        Text(
          'ӨЛШЕМДІ ТАҢДАҢЫЗ',
          style: AppTextStyles.heading4.copyWith(
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        _buildSizeSelector(),
        
        const SizedBox(height: 40),
        
        // Выбор цвета
        Text(
          'ТҮСТІ ТАҢДАҢЫЗ',
          style: AppTextStyles.heading4.copyWith(
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        _buildColorSelector(),
        
        const SizedBox(height: 40),
        
        // Выбор количества
        Row(
          children: [
            Text(
              'САНЫ',
              style: AppTextStyles.heading4.copyWith(
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            _buildQuantitySelector(),
          ],
        ),
        
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.product.sizes.map((size) {
        final isSelected = size == _selectedSize;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSize = size;
            });
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.cardBackground,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                size,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isSelected ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: widget.product.colors.map((colorName) {
            final isSelected = colorName == _selectedColor;
            final colorValue = AppColors.productColors[colorName] ?? AppColors.textPrimary;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = colorName;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorValue,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          _selectedColor,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Кнопка уменьшения
          InkWell(
            onTap: _quantity > 1
                ? () {
                    setState(() {
                      _quantity--;
                    });
                  }
                : null,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _quantity > 1 ? AppColors.cardBackground : AppColors.lightGray,
                border: Border(
                  right: BorderSide(color: AppColors.border, width: 2),
                ),
              ),
              child: Icon(
                Icons.remove,
                color: _quantity > 1 ? AppColors.textPrimary : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
          
          // Текущее количество
          Container(
            width: 60,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
            ),
            child: Center(
              child: Text(
                _quantity.toString(),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          
          // Кнопка увеличения
          InkWell(
            onTap: () {
              setState(() {
                _quantity++;
              });
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  left: BorderSide(color: AppColors.border, width: 2),
                ),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(AuthProvider authProvider, CartProvider cartProvider) {
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
          child: Row(
            children: [
              // Добавить в корзину
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: AppStrings.addToCart,
                  onPressed: widget.product.stock > 0
                      ? () => _addToCart(authProvider, cartProvider)
                      : null,
                  isLoading: _isAddingToCart,
                  height: 64,
                  showArrow: true,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Купить сейчас
              Expanded(
                child: CustomButton(
                  text: 'ҚАЗІР САТЫП АЛУ',
                  type: ButtonType.outline,
                  onPressed: widget.product.stock > 0
                      ? () => _buyNow(authProvider, cartProvider)
                      : null,
                  height: 64,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart(AuthProvider authProvider, CartProvider cartProvider) async {
    if (!authProvider.isLoggedIn) {
      _showLoginDialog();
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    final success = await cartProvider.addToCart(
      userId: authProvider.user!.id,
      productId: widget.product.id,
      quantity: _quantity,
      selectedSize: _selectedSize,
      selectedColor: _selectedColor,
      productName: widget.product.name,
      productPrice: widget.product.price,
      productImageUrl: widget.product.imageUrl,
    );

    setState(() {
      _isAddingToCart = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} себетке қосылды'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cartProvider.error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      );
    }
  }

  Future<void> _buyNow(AuthProvider authProvider, CartProvider cartProvider) async {
    if (!authProvider.isLoggedIn) {
      _showLoginDialog();
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    final success = await cartProvider.addToCart(
      userId: authProvider.user!.id,
      productId: widget.product.id,
      quantity: _quantity,
      selectedSize: _selectedSize,
      selectedColor: _selectedColor,
      productName: widget.product.name,
      productPrice: widget.product.price,
      productImageUrl: widget.product.imageUrl,
    );

    setState(() {
      _isAddingToCart = false;
    });

    if (success && mounted) {
      Navigator.pushNamed(context, AppRoutes.cart);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cartProvider.error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      );
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          'КІРУ ҚАЖЕТ',
          style: AppTextStyles.heading3.copyWith(
            letterSpacing: 1.0,
          ),
        ),
        content: Text(
          'Себетке қосу үшін жүйеге кіру қажет',
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
              Navigator.pushNamed(context, AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(
              AppStrings.login.toUpperCase(),
              style: AppTextStyles.buttonMedium,
            ),
          ),
        ],
      ),
    );
  }
}