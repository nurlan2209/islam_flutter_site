import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Заголовки
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle heading4 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  // Основной текст
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  // Подписи и маленький текст
  static const TextStyle caption = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );
  
  // Кнопки
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
    letterSpacing: 1.0,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
    letterSpacing: 0.75,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );
  
  // Цены и акценты
  static const TextStyle price = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
  
  static const TextStyle discountPrice = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.error,
  );
  
  static const TextStyle oldPrice = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    decoration: TextDecoration.lineThrough,
  );
  
  // Формы
  static const TextStyle inputLabel = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle inputText = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle inputHint = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle inputError = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
  );
  
  // Ссылки
  static const TextStyle link = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.accent,
    decoration: TextDecoration.underline,
  );
  
  // Модифицированные стили
  static TextStyle get headingWhite => heading1.copyWith(color: AppColors.textLight);
  static TextStyle get bodyWhite => bodyLarge.copyWith(color: AppColors.textLight);
  static TextStyle get captionWhite => caption.copyWith(color: AppColors.textLight);
}