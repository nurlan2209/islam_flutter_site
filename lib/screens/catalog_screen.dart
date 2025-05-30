import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/text_styles.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

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
  
  // Список всех доступных размеров для фильтрации
  final List<String> _allSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];
  
  // Список всех доступных цветов для фильтрации
  final List<String> _allColors = ['Қара', 'Ақ', 'Сұр', 'Көк', 'Қызыл', 'Жасыл', 'Сары', 'Қоңыр'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      // Если передана категория, устанавливаем её как фильтр
      if (widget.category != null && widget.category!.isNotEmpty) {
        productProvider.setSelectedCategory(widget.category!);
      }
      
      // Определяем минимальную и максимальную цену
      _updatePriceRange(productProvider.products);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Обновление диапазона цен на основе списка товаров
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
    final isTabletOrDesktop = screenWidth > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: widget.category != null && widget.category!.isNotEmpty
            ? Text(widget.category!)
            : const Text(AppStrings.catalog),
        elevation: 0,
        actions: [
          // Кнопка переключения вида (сетка/список)
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: AppStrings.filter,
          ),
        ],
      ),
      body: Column(
        children: [
          // Поисковая строка
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          productProvider.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                productProvider.setSearchQuery(value);
              },
            ),
          ),
          
          // Фильтры и сортировка - основная строка
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.cardBackground,
            child: Row(
              children: [
                // Выпадающий список категорий
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text(AppStrings.categories),
                      value: productProvider.selectedCategory.isNotEmpty
                          ? productProvider.selectedCategory
                          : null,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text(AppStrings.all),
                        ),
                        ...productProvider.categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        productProvider.setSelectedCategory(value ?? '');
                      },
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Сортировка
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text(AppStrings.sort),
                      value: _selectedSortOption.isNotEmpty ? _selectedSortOption : null,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'price_asc',
                          child: Text(AppStrings.sortByPriceAsc),
                        ),
                        DropdownMenuItem<String>(
                          value: 'price_desc',
                          child: Text(AppStrings.sortByPriceDesc),
                        ),
                        DropdownMenuItem<String>(
                          value: 'name',
                          child: Text(AppStrings.sortByName),
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
                ),
              ],
            ),
          ),
          
          // Расширенные фильтры (показываются при нажатии на кнопку фильтров)
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.secondary.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок фильтров
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Расширенные фильтры',
                        style: AppTextStyles.heading4,
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Сбросить'),
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
                  
                  const SizedBox(height: 16),
                  
                  // Диапазон цен
                  Text(
                    '${AppStrings.priceRange}: ${_priceRange.start.toInt()} - ${_priceRange.end.toInt()} ${AppStrings.currency}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  RangeSlider(
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
                  
                  const SizedBox(height: 16),
                  
                  // Фильтр по размерам
                  Text(
                    AppStrings.productSizes,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allSizes.map((size) {
                      final isSelected = _selectedSizes.contains(size);
                      return FilterChip(
                        label: Text(size),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSizes.add(size);
                            } else {
                              _selectedSizes.remove(size);
                            }
                          });
                        },
                        backgroundColor: AppColors.cardBackground,
                        selectedColor: AppColors.accent.withOpacity(0.3),
                        checkmarkColor: AppColors.accent,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Фильтр по цветам
                  Text(
                    AppStrings.productColors,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allColors.map((color) {
                      final isSelected = _selectedColors.contains(color);
                      final colorValue = AppColors.productColors[color] ?? Colors.grey;
                      
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colorValue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(color),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedColors.add(color);
                            } else {
                              _selectedColors.remove(color);
                            }
                          });
                        },
                        backgroundColor: AppColors.cardBackground,
                        selectedColor: AppColors.accent.withOpacity(0.3),
                        checkmarkColor: AppColors.accent,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Кнопки применения/отмены фильтров
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(AppStrings.cancel),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showFilters = false;
                            });
                            // Здесь можно добавить логику применения фильтров
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(AppStrings.confirm),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Счетчик найденных товаров
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Найдено: ${productProvider.products.length} товаров',
                  style: AppTextStyles.bodyMedium,
                ),
                const Spacer(),
                // Кнопки переключения вида: сетка/список
                IconButton(
                  icon: const Icon(Icons.grid_view),
                  onPressed: () {
                    // Переключение на вид сетки
                  },
                  tooltip: 'Вид сетки',
                ),
                IconButton(
                  icon: const Icon(Icons.view_list),
                  onPressed: () {
                    // Переключение на вид списка
                  },
                  tooltip: 'Вид списка',
                ),
              ],
            ),
          ),
          
          // Список товаров
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.products.isEmpty
                    ? _buildEmptyState()
                    : _buildProductGrid(
                        productProvider, 
                        isTabletOrDesktop,
                      ),
          ),
        ],
      ),
    );
  }
  
  // Пустое состояние, когда нет товаров
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noProducts,
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте изменить параметры поиска',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text(AppStrings.filter),
            onPressed: () {
              setState(() {
                _searchController.clear();
                final productProvider = Provider.of<ProductProvider>(context, listen: false);
                productProvider.setSearchQuery('');
                productProvider.setSelectedCategory('');
                productProvider.setSortBy('');
              });
            },
          ),
        ],
      ),
    );
  }
  
  // Сетка товаров
  Widget _buildProductGrid(ProductProvider productProvider, bool isTabletOrDesktop) {
    // Фильтруем товары на основе выбранных фильтров
    final filteredProducts = productProvider.products.where((product) {
      // Фильтр по цене
      if (product.price < _priceRange.start || product.price > _priceRange.end) {
        return false;
      }
      
      // Фильтр по размерам
      if (_selectedSizes.isNotEmpty) {
        bool hasSizeMatch = false;
        for (var size in _selectedSizes) {
          if (product.sizes.contains(size)) {
            hasSizeMatch = true;
            break;
          }
        }
        if (!hasSizeMatch) return false;
      }
      
      // Фильтр по цветам
      if (_selectedColors.isNotEmpty) {
        bool hasColorMatch = false;
        for (var color in _selectedColors) {
          if (product.colors.contains(color)) {
            hasColorMatch = true;
            break;
          }
        }
        if (!hasColorMatch) return false;
      }
      
      return true;
    }).toList();
    
    // Определяем количество колонок в зависимости от ширины экрана
    final crossAxisCount = isTabletOrDesktop ? 3 : 2;
    
    if (filteredProducts.isEmpty) {
      return _buildEmptyState();
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7, // Карточка выше, чем шире
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }
  
  // Карточка товара
  Widget _buildProductCard(Product product) {
    // Здесь будет использоваться улучшенная карточка товара
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: product,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение товара
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    // Изображение товара
                    Hero(
                      tag: 'product-${product.id}',
                      child: product.imageUrl.startsWith('http')
                          ? Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    
                    // Индикатор наличия
                    if (product.stock <= 5)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.stock > 0 
                                ? AppColors.warning.withOpacity(0.9)
                                : AppColors.error.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.stock > 0 
                                ? 'Осталось ${product.stock} шт.'
                                : AppStrings.outOfStock,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                    // Затемнение при наведении
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: AppColors.accent.withOpacity(0.1),
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/product-detail',
                            arguments: product,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Информация о товаре
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Категория товара
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          product.category,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                        
                      const SizedBox(height: 8),
                      
                      // Название товара
                      Text(
                        product.name,
                        style: AppTextStyles.heading4,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const Spacer(),
                      
                      // Цена и кнопка
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Цена товара
                          Text(
                            '${product.price.toStringAsFixed(0)} ${AppStrings.currency}',
                            style: AppTextStyles.price,
                          ),
                          
                          // Кнопка "В корзину"
                          if (product.stock > 0)
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: AppColors.textLight,
                                  size: 20,
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/product-detail',
                                    arguments: product,
                                  );
                                },
                                tooltip: AppStrings.addToCart,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                padding: const EdgeInsets.all(8),
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
      ),
    );
  }
}