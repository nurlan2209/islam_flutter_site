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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Верхняя часть: изображение и основная информация
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение товара
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: item.productImageUrl != null && item.productImageUrl!.isNotEmpty
                    ? Image.asset(
                        item.productImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.textSecondary,
                              size: 32,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textSecondary,
                          size: 32,
                        ),
                      ),
              ),
              
              const SizedBox(width: 16),
              
              // Информация о товаре
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Название товара
                    Text(
                      item.productName ?? 'Неизвестный товар',
                      style: AppTextStyles.productTitle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Размер и цвет
                    Text(
                      'РАЗМЕР: ${item.selectedSize}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'ЦВЕТ: ${item.selectedColor}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Кнопка удаления
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onRemove,
                color: AppColors.textSecondary,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Нижняя часть: количество и цена
          Row(
            children: [
              // Селектор количества
              _buildQuantitySelector(),
              
              const Spacer(),
              
              // Цены
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Цена за единицу
                  Text(
                    '${item.productPrice?.toInt() ?? 0} ${AppStrings.currency}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Общая цена
                  Text(
                    '${item.totalPrice.toInt()} ${AppStrings.currency}',
                    style: AppTextStyles.price.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Кнопка уменьшения
          InkWell(
            onTap: item.quantity > 1
                ? () => onUpdateQuantity(item.quantity - 1)
                : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.quantity > 1 ? AppColors.cardBackground : AppColors.lightGray,
                border: Border(
                  right: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Icon(
                Icons.remove,
                size: 16,
                color: item.quantity > 1 ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          
          // Количество
          Container(
            width: 48,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
            ),
            child: Center(
              child: Text(
                item.quantity.toString(),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          // Кнопка увеличения
          InkWell(
            onTap: () => onUpdateQuantity(item.quantity + 1),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  left: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: const Icon(
                Icons.add,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}