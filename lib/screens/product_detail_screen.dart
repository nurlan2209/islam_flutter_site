import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/text_styles.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/size_selector.dart';
import '../widgets/color_selector.dart';
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

  @override
  void initState() {
    super.initState();
    // Устанавливаем первый размер и цвет по умолчанию
    _selectedSize = widget.product.sizes.isNotEmpty ? widget.product.sizes.first : '';
    _selectedColor = widget.product.colors.isNotEmpty ? widget.product.colors.first : '';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.productDetails),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение товара
            SizedBox(
              height: 300,
              width: double.infinity,
              child: widget.product.imageUrl.startsWith('http')
                ? Image.network(
                    widget.product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.secondary,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  )
                : Image.asset(
                    widget.product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.secondary,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название и цена
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: AppTextStyles.heading2,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${widget.product.price} ${AppStrings.currency}',
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Описание
                  Text(
                    AppStrings.description,
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: AppTextStyles.bodyLarge,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Выбор размера
                  Text(
                    AppStrings.chooseSize,
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  SizeSelector(
                    sizes: widget.product.sizes,
                    selectedSize: _selectedSize,
                    onSizeSelected: (size) {
                      setState(() {
                        _selectedSize = size;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Выбор цвета
                  Text(
                    AppStrings.chooseColor,
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  ColorSelector(
                    colors: widget.product.colors,
                    selectedColor: _selectedColor,
                    onColorSelected: (color) {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Выбор количества
                  Row(
                    children: [
                      Text(
                        AppStrings.quantity,
                        style: AppTextStyles.heading3,
                      ),
                      const Spacer(),
                      _buildQuantitySelector(),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Кнопки действий
                  Row(
                    children: [
                      // Добавить в корзину
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.addToCart,
                          onPressed: () => _addToCart(authProvider, cartProvider),
                          isLoading: _isAddingToCart,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Купить сейчас
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.buyNow,
                          type: ButtonType.outline,
                          onPressed: () => _buyNow(authProvider, cartProvider),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Уменьшение количества
          IconButton(
            onPressed: _quantity > 1
                ? () {
                    setState(() {
                      _quantity--;
                    });
                  }
                : null,
            icon: const Icon(Icons.remove),
            color: _quantity > 1 ? AppColors.primary : AppColors.buttonDisabled,
          ),
          
          // Текущее количество
          SizedBox(
            width: 40,
            child: Text(
              _quantity.toString(),
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          
          // Увеличение количества
          IconButton(
            onPressed: () {
              setState(() {
                _quantity++;
              });
            },
            icon: const Icon(Icons.add),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _addToCart(AuthProvider authProvider, CartProvider cartProvider) async {
    // Проверяем, авторизован ли пользователь
    if (!authProvider.isLoggedIn) {
      _showLoginDialog();
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    // Добавляем товар в корзину
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

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.addToCartSuccess)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cartProvider.error)),
      );
    }
  }

  Future<void> _buyNow(AuthProvider authProvider, CartProvider cartProvider) async {
    // Проверяем, авторизован ли пользователь
    if (!authProvider.isLoggedIn) {
      _showLoginDialog();
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    // Добавляем товар в корзину
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

    if (success) {
      // Переходим на экран корзины
      Navigator.pushNamed(context, AppRoutes.cart);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cartProvider.error)),
      );
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.login),
        content: const Text('Тіркелу немесе кіру қажет'),
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
              Navigator.pushNamed(context, AppRoutes.login);
            },
            child: Text(AppStrings.login),
          ),
        ],
      ),
    );
  }
}