import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/text_styles.dart';
import '../models/cart_item.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final Function(int) onUpdateQuantity;
  final VoidCallback onRemove;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onUpdateQuantity,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение товара
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.productImageUrl ?? 'assets/images/placeholder.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: AppColors.secondary,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Информация о товаре
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName ?? '',
                    style: AppTextStyles.heading4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Размер и цвет
                  Text(
                    '${AppStrings.chooseSize}: ${item.selectedSize}',
                    style: AppTextStyles.bodySmall,
                  ),
                  
                  Text(
                    '${AppStrings.chooseColor}: ${item.selectedColor}',
                    style: AppTextStyles.bodySmall,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Цена и общая сумма
                  Row(
                    children: [
                      Text(
                        '${item.productPrice ?? 0} ${AppStrings.currency}',
                        style: AppTextStyles.price,
                      ),
                      const Spacer(),
                      Text(
                        '${AppStrings.total}: ${item.totalPrice} ${AppStrings.currency}',
                        style: AppTextStyles.bodyMedium,
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
}

// Виджет для изменения количества
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final Function(int) onChanged;

  const QuantitySelector({
    Key? key,
    required this.quantity,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Кнопка уменьшения
          IconButton(
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: quantity > 1 ? AppColors.primary : AppColors.buttonDisabled,
            iconSize: 18,
          ),
          
          // Текущее количество
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              quantity.toString(),
              style: AppTextStyles.bodyMedium,
            ),
          ),
          
          // Кнопка увеличения
          IconButton(
            onPressed: () => onChanged(quantity + 1),
            icon: const Icon(Icons.add),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: AppColors.primary,
            iconSize: 18,
          ),
        ],
      ),
    );
  }
}