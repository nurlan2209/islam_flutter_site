
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../constants/text_styles.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';

class ProductForm extends StatefulWidget {
  final Product? product;

  const ProductForm({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _sizesController = TextEditingController();
  final _colorsController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEdit = false;
  
  // Предлагаемые категории
  final List<String> _suggestedCategories = ['Футболкалар', 'Худи', 'Жейде', 'Шапки', 'Аксессуары'];
  
  // Предлагаемые размеры
  final List<String> _commonSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  
  // Предлагаемые цвета
  final List<String> _commonColors = ['Қара', 'Ақ', 'Сұр', 'Көк', 'Қызыл', 'Жасыл', 'Сары', 'Қоңыр'];

  @override
  void initState() {
    super.initState();
    _isEdit = widget.product != null;
    
    if (_isEdit) {
      // Заполняем форму данными существующего товара
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _imageUrlController.text = widget.product!.imageUrl;
      _sizesController.text = widget.product!.sizes.join(',');
      _colorsController.text = widget.product!.colors.join(',');
      _categoryController.text = widget.product!.category;
      _stockController.text = widget.product!.stock.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _sizesController.dispose();
    _colorsController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? AppStrings.editProduct : AppStrings.addProduct;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Карточка с основной информацией
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Основная информация',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 16),
                        
                        // Название товара
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.productName,
                            prefixIcon: Icon(Icons.shopping_bag),
                            helperText: 'Введите полное название товара',
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.fieldRequired;
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Описание товара
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.productDescription,
                            prefixIcon: Icon(Icons.description),
                            helperText: 'Подробное описание характеристик товара',
                          ),
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.fieldRequired;
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Цена товара
                        TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: AppStrings.productPrice,
                            prefixIcon: const Icon(Icons.attach_money),
                            suffixText: AppStrings.currency,
                            helperText: 'Цена в тенге без пробелов и знаков',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.fieldRequired;
                            }
                            if (double.tryParse(value) == null) {
                              return 'Жарамды баға енгізіңіз';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Карточка с категорией
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Категория',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 16),
                        
                        // Категория с выпадающим списком
                        DropdownButtonFormField<String>(
                          value: _suggestedCategories.contains(_categoryController.text) 
                              ? _categoryController.text 
                              : null,
                          decoration: const InputDecoration(
                            labelText: AppStrings.productCategory,
                            prefixIcon: Icon(Icons.category),
                            helperText: 'Выберите категорию из списка или введите новую',
                          ),
                          items: _suggestedCategories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _categoryController.text = value;
                            }
                          },
                          validator: (value) {
                            if (_categoryController.text.isEmpty) {
                              return AppStrings.fieldRequired;
                            }
                            return null;
                          },
                          isExpanded: true,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Поле для ручного ввода категории
                        if (!_suggestedCategories.contains(_categoryController.text))
                          TextFormField(
                            controller: _categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Другая категория',
                              prefixIcon: Icon(Icons.edit),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.fieldRequired;
                              }
                              return null;
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Карточка с изображением
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Изображение товара',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 16),
                        
                        // URL изображения
                        TextFormField(
                          controller: _imageUrlController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.productImage,
                            prefixIcon: Icon(Icons.image),
                            hintText: 'https://example.com/image.jpg',
                            helperText: 'Укажите прямую ссылку на изображение',
                          ),
                          onChanged: (value) {
                            // Обновляем предпросмотр при изменении URL
                            setState(() {});
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.fieldRequired;
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Предпросмотр изображения
                        if (_imageUrlController.text.isNotEmpty)
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _imageUrlController.text.startsWith('http')
                                ? Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              color: AppColors.error,
                                              size: 48,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Сурет жүктелмеді',
                                              style: AppTextStyles.bodySmall,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Text(
                                      'URL суретті енгізіңіз',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Карточка с размерами и цветами
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Размеры и цвета',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 16),
                        
                        // Размеры с выбором чипсами
                        Text(
                          'Доступные размеры:',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _commonSizes.map((size) {
                            final isSelected = _sizesController.text
                                .split(',')
                                .map((s) => s.trim())
                                .contains(size);
                            
                            return FilterChip(
                              label: Text(size),
                              selected: isSelected,
                              onSelected: (selected) {
                                final currentSizes = _sizesController.text
                                    .split(',')
                                    .map((s) => s.trim())
                                    .where((s) => s.isNotEmpty)
                                    .toList();
                                
                                if (selected) {
                                  if (!currentSizes.contains(size)) {
                                    currentSizes.add(size);
                                  }
                                } else {
                                  currentSizes.remove(size);
                                }
                                
                                _sizesController.text = currentSizes.join(',');
                                setState(() {});
                              },
                              backgroundColor: AppColors.cardBackground,
                              selectedColor: AppColors.accent.withOpacity(0.3),
                              checkmarkColor: AppColors.accent,
                            );
                          }).toList(),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Поле для ручного ввода размеров
                        TextFormField(
                          controller: _sizesController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.productSizes,
                            prefixIcon: Icon(Icons.straighten),
                            hintText: 'S,M,L,XL,XXL',
                            helperText: 'Размеры через запятую',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.fieldRequired;
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Цвета с выбором чипсами
                        Text(
                          'Доступные цвета:',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _commonColors.map((color) {
                            final isSelected = _colorsController.text
                                .split(',')
                                .map((c) => c.trim())
                                .contains(color);
                            
                            return FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: AppColors.productColors[color] ?? Colors.grey,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(color),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                final currentColors = _colorsController.text
                                    .split(',')
                                    .map((c) => c.trim())
                                    .where((c) => c.isNotEmpty)
                                    .toList();
                                
                                if (selected) {
                                  if (!currentColors.contains(color)) {
                                    currentColors.add(color);
                                  }
                                } else {
                                  currentColors.remove(color);
                                }
                                
                                _colorsController.text = currentColors.join(',');
                                setState(() {});
                              },
                              backgroundColor: AppColors.cardBackground,
                              selectedColor: AppColors.accent.withOpacity(0.3),
                              checkmarkColor: AppColors.accent,
                            );
                          }).toList(),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Поле для ручного ввода цветов
                        TextFormField(
                          controller: _colorsController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.productColors,
                            prefixIcon: Icon(Icons.color_lens),
                            hintText: 'Қара,Ақ,Сұр',
                            helperText: 'Цвета через запятую',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.fieldRequired;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Карточка с количеством товара
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Наличие товара',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 16),
                        
                        // Количество в наличии
                        TextFormField(
                          controller: _stockController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.productStock,
                            prefixIcon: Icon(Icons.inventory),
                            helperText: 'Количество единиц товара на складе',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.fieldRequired;
                            }
                            if (int.tryParse(value) == null) {
                              return 'Жарамды сан енгізіңіз';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Кнопка сохранения
                CustomButton(
                  text: _isEdit ? AppStrings.save : AppStrings.addProduct,
                  isLoading: _isLoading,
                  onPressed: _saveProduct,
                  icon: Icons.save,
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      final name = _nameController.text;
      final description = _descriptionController.text;
      final price = double.parse(_priceController.text);
      final imageUrl = _imageUrlController.text;
      final sizes = _sizesController.text.split(',')
        .map((size) => size.trim())
        .where((size) => size.isNotEmpty)
        .toList();
      final colors = _colorsController.text.split(',')
        .map((color) => color.trim())
        .where((color) => color.isNotEmpty)
        .toList();
      final category = _categoryController.text;
      final stock = int.parse(_stockController.text);
      
      if (_isEdit) {
        // Обновление существующего товара
        final updatedProduct = widget.product!.copyWith(
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          sizes: sizes,
          colors: colors,
          category: category,
          stock: stock,
        );
        
        final success = await productProvider.updateProduct(updatedProduct);
        
        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.productUpdated),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(productProvider.error),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else {
        // Добавление нового товара
        final newProduct = Product(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          sizes: sizes,
          colors: colors,
          category: category,
          stock: stock,
        );
        
        final success = await productProvider.addProduct(newProduct);
        
        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.productAdded),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(productProvider.error),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}