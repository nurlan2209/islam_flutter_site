import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Базовый шрифт - чистый и современный
  static const String fontFamily = 'Helvetica Neue';
  
  // Огромные заголовки как в баннерах 
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48.0,
    fontWeight: FontWeight.w900, // Очень жирный
    color: AppColors.textPrimary,
    height: 1.1,
    letterSpacing: -1.0,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36.0,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  // Заголовки секций как у Adidas
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.5,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.25,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle heading4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  // Основной текст
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  // Подписи как у Adidas
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
    letterSpacing: 0.5,
  );
  
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.6,
    letterSpacing: 1.5,
  );
  
  // Кнопки в стиле Adidas
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 1.0,
    height: 1.0,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 0.75,
    height: 1.0,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 0.5,
    height: 1.0,
  );
  
  // Цены как у Adidas - жирные и заметные
  static const TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle priceMain = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle priceLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle priceSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  // Старые цены с зачеркиванием
  static const TextStyle priceOld = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    decoration: TextDecoration.lineThrough,
    height: 1.2,
  );
  
  // Скидки красным цветом
  static const TextStyle discount = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.discountRed,
    height: 1.2,
  );
  
  // Названия товаров
  static const TextStyle productTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle productSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );
  
  // Категории
  static const TextStyle categoryLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.0,
    letterSpacing: 0.5,
  );
  
  // Формы ввода
  static const TextStyle inputLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle inputText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle inputHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );
  
  static const TextStyle inputError = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    height: 1.3,
  );
  
  // Ссылки
  static const TextStyle link = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    decoration: TextDecoration.underline,
    height: 1.3,
  );
  
  // Навигация как у Adidas
  static const TextStyle navigation = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.0,
  );
  
  // Статусы заказов
  static const TextStyle status = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.5,
  );
  
  // Белые варианты для темного фона
  static TextStyle get displayLargeWhite => displayLarge.copyWith(color: AppColors.textLight);
  static TextStyle get displayMediumWhite => displayMedium.copyWith(color: AppColors.textLight);
  static TextStyle get heading1White => heading1.copyWith(color: AppColors.textLight);
  static TextStyle get heading2White => heading2.copyWith(color: AppColors.textLight);
  static TextStyle get bodyLargeWhite => bodyLarge.copyWith(color: AppColors.textLight);
  static TextStyle get bodyMediumWhite => bodyMedium.copyWith(color: AppColors.textLight);
  
  // Вторичные варианты
  static TextStyle get heading1Secondary => heading1.copyWith(color: AppColors.textSecondary);
  static TextStyle get bodyLargeSecondary => bodyLarge.copyWith(color: AppColors.textSecondary);
}