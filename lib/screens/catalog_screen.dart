import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/text_styles.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class CatalogScreen extends StatefulWidget {
  final String? category;

  const CatalogScreen({Key? key, this.category}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSortOption = '';
  bool _showFilters = false;
  RangeValues _priceRange = const RangeValues(0, 50000);
  double _minPrice = 0;
  double _maxPrice = 50000;
  List<String> _selectedSizes = [];
  List<String> _selectedColors = [];
  
  final List<String> _allSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];
  final List<String> _allColors = ['Қара', 'Ақ', 'Сұр', 'Көк', 'Қызыл', 'Жасыл', 'Сары', 'Қоңыр'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      // Если передана категория, устанавливаем ее как выбранную
      if (widget.category != null && widget.category!.isNotEmpty) {
        if (widget.category == 'ЛЕТНЯЯ_КОЛЛЕКЦИЯ') {
          // Для летней коллекции не устанавливаем конкретную категорию
          // Фильтрация будет происходить в _getFilteredProducts
          productProvider.setSelectedCategory('');
        } else {
          // Нормализуем название категории для поиска
          String normalizedCategory = _normalizeCategory(widget.category!);
          productProvider.setSelectedCategory(normalizedCategory);
        }
      }
      
      _updatePriceRange(productProvider.products);
    });
  }

  // Функция для нормализации названий категорий
  String _normalizeCategory(String category) {
    switch (category.toUpperCase()) {
      case 'ФУТБОЛКА':
      case 'ФУТБОЛКАЛАР':
        return 'Футболка';
      case 'ХУДИ':
        return 'Худи';
      case 'ЖЕЙДЕ':
        return 'Жейде';
      case 'СВИТШОТЫ':
        return 'Свитшоты';
      case 'ВЕТРОВКИ':
        return 'Ветровки';
      case 'АКСЕССУАРЫ':
        return 'Аксессуары';
      default:
        return category;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _updatePriceRange(List<Product> products) {
    if (products.isEmpty) return;
    
    double min = double.infinity;
    double max = 0;
    
    for (var product in products) {
      if (product.price < min) min = product.price;
      if (product.price > max) max = product.price;
    }
    
    setState(() {
      _minPrice = min;
      _maxPrice = max > min ? max : min + 10000;
      _priceRange = RangeValues(_minPrice, _maxPrice);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Поисковая строка в стиле Adidas
          _buildSearchSection(productProvider),
          
          // Фильтры и сортировка
          _buildFiltersSection(productProvider),
          
          // Счетчик товаров
          _buildProductCounter(productProvider),
          
          // Список товаров
          Expanded(
            child: productProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : _buildProductGrid(productProvider, isDesktop, isTablet),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    String titleText;
    if (widget.category == 'ЛЕТНЯЯ_КОЛЛЕКЦИЯ') {
      titleText = 'ЛЕТНЯЯ КОЛЛЕКЦИЯ';
    } else if (widget.category != null && widget.category!.isNotEmpty) {
      titleText = widget.category!.toUpperCase();
    } else {
      titleText = AppStrings.catalog.toUpperCase();
    }

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
        titleText,
        style: AppTextStyles.navigation.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _showFilters ? Icons.tune : Icons.tune,
            size: 24,
            color: _showFilters ? AppColors.primary : AppColors.textPrimary,
          ),
          onPressed: () {
            setState(() {
              _showFilters = !_showFilters;
            });
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchSection(ProductProvider productProvider) {
    return Container(
      padding: const EdgeInsets.all(16), // Уменьшил с 24 до 16
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.inputText,
        decoration: InputDecoration(
          hintText: AppStrings.search.toUpperCase(),
          hintStyle: AppTextStyles.inputHint.copyWith(
            letterSpacing: 1.0,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    productProvider.setSearchQuery('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.lightGray,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, // Уменьшил с 20
            vertical: 12,   // Уменьшил с 16
          ),
        ),
        onChanged: (value) {
          productProvider.setSearchQuery(value);
        },
      ),
    );
  }
  Widget _buildFiltersSection(ProductProvider productProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Уменьшил отступы
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Основные фильтры
          Row(
            children: [
              // Категории
              Expanded(
                child: _buildDropdown(
                  hint: 'САНАТТАР', // Сократил название
                  value: productProvider.selectedCategory.isNotEmpty
                      ? productProvider.selectedCategory
                      : null,
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('БАРЛЫҒЫ'),
                    ),
                    ...productProvider.categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category.toUpperCase()),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    productProvider.setSelectedCategory(value ?? '');
                  },
                ),
              ),
              
              const SizedBox(width: 12), // Уменьшил с 16
              
              // Сортировка
              Expanded(
                child: _buildDropdown(
                  hint: 'СОРТИРОВКА',
                  value: _selectedSortOption.isNotEmpty ? _selectedSortOption : null,
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'price_asc',
                      child: Text('БАҒАСЫ ↑'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'price_desc',
                      child: Text('БАҒАСЫ ↓'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'name',
                      child: Text('ӘЛІПБИ'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSortOption = value ?? '';
                      productProvider.setSortBy(_selectedSortOption);
                    });
                  },
                ),
              ),
            ],
          ),
          
          // Расширенные фильтры
          if (_showFilters) ...[
            const SizedBox(height: 16), // Уменьшил с 24
            _buildAdvancedFilters(),
          ],
        ],
      ),
    );
  }
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'РАСШИРЕННЫЕ ФИЛЬТРЫ',
                style: AppTextStyles.heading4.copyWith(
                  letterSpacing: 1.0,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('СБРОСИТЬ'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _priceRange = RangeValues(_minPrice, _maxPrice);
                    _selectedSizes = [];
                    _selectedColors = [];
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Диапазон цен
          Text(
            'ЦЕНА: ${_priceRange.start.toInt()} - ${_priceRange.end.toInt()} ${AppStrings.currency}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              trackHeight: 2,
            ),
            child: RangeSlider(
              values: _priceRange,
              min: _minPrice,
              max: _maxPrice,
              divisions: 20,
              labels: RangeLabels(
                '${_priceRange.start.toInt()} ${AppStrings.currency}',
                '${_priceRange.end.toInt()} ${AppStrings.currency}',
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Размеры
          Text(
            'РАЗМЕРЫ',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allSizes.map((size) {
              final isSelected = _selectedSizes.contains(size);
              return _buildFilterChip(
                label: size,
                isSelected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSizes.add(size);
                    } else {
                      _selectedSizes.remove(size);
                    }
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Цвета
          Text(
            'ЦВЕТА',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allColors.map((color) {
              final isSelected = _selectedColors.contains(color);
              final colorValue = AppColors.productColors[color] ?? Colors.grey;
              
              return _buildColorChip(
                label: color,
                color: colorValue,
                isSelected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedColors.add(color);
                    } else {
                      _selectedColors.remove(color);
                    }
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Кнопки применения фильтров
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    AppStrings.cancel.toUpperCase(),
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = false;
                    });
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
                  child: Text(
                    'ПРИМЕНИТЬ',
                    style: AppTextStyles.buttonMedium.copyWith(
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: AppColors.cardBackground,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textLight,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? AppColors.textLight : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppColors.border),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildColorChip({
    required String label,
    required Color color,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: AppColors.cardBackground,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textLight,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? AppColors.textLight : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppColors.border),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildProductCounter(ProductProvider productProvider) {
    final filteredProducts = _getFilteredProducts(productProvider.products);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Уменьшил отступы
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'НАЙДЕНО: ${filteredProducts.length} ТОВАРОВ',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontSize: 12, // Уменьшил размер шрифта
            ),
          ),
          Row(
            children: [
              // Grid view button
              Container(
                width: 32, // Уменьшил размер
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.grid_view,
                    color: Colors.white,
                    size: 16, // Уменьшил размер иконки
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
              
              const SizedBox(width: 8),
              
              // List view button
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.view_list,
                    color: Colors.black,
                    size: 16,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildProductGrid(ProductProvider productProvider, bool isDesktop, bool isTablet) {
    final filteredProducts = _getFilteredProducts(productProvider.products);
    
    if (filteredProducts.isEmpty) {
      return _buildEmptyState();
    }
    
    // Всегда 2 колонки для мобилки
    final crossAxisCount = 2;
    
    return GridView.builder(
      padding: const EdgeInsets.all(16), // Уменьшил с 24
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12, // Уменьшил с 24
        mainAxisSpacing: 16,  // Уменьшил с 32
        childAspectRatio: 0.7, // Изменил для лучшего вида на мобилке
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildMobileProductCard(filteredProducts[index]);
      },
    );
  }

  Widget _buildMobileProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product_detail', // Замените на правильный маршрут
          arguments: product,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение товара
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
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
            
            // Информация о товаре
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Название товара
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Цена
                    Text(
                      '${product.price.toInt()} ₸',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
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
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 120,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 32),
            Text(
              'ТОВАРЫ НЕ НАЙДЕНЫ',
              style: AppTextStyles.heading3.copyWith(
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Попробуйте изменить параметры поиска\nили сбросить фильтры',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('СБРОСИТЬ ФИЛЬТРЫ'),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  final productProvider = Provider.of<ProductProvider>(context, listen: false);
                  productProvider.setSearchQuery('');
                  productProvider.setSelectedCategory('');
                  productProvider.setSortBy('');
                  _priceRange = RangeValues(_minPrice, _maxPrice);
                  _selectedSizes = [];
                  _selectedColors = [];
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    List<Product> result = List.from(products);
    
    // Специальная фильтрация для летней коллекции
    if (widget.category == 'ЛЕТНЯЯ_КОЛЛЕКЦИЯ') {
      final summerCategories = ['Футболка', 'Свитшоты', 'Аксессуары', 'Жейде'];
      result = result.where((product) {
        return summerCategories.contains(product.category);
      }).toList();
    }
    
    // Фильтр по цене
    result = result.where((product) {
      return product.price >= _priceRange.start && product.price <= _priceRange.end;
    }).toList();
    
    // Фильтр по размерам
    if (_selectedSizes.isNotEmpty) {
      result = result.where((product) {
        return _selectedSizes.any((size) => product.sizes.contains(size));
      }).toList();
    }
    
    // Фильтр по цветам
    if (_selectedColors.isNotEmpty) {
      result = result.where((product) {
        return _selectedColors.any((color) => product.colors.contains(color));
      }).toList();
    }
    
    return result;
  }
}