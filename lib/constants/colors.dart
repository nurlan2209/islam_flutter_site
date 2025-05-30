import 'package:flutter/material.dart';

class AppColors {
  // Основные цвета в стиле Adidas
  static const Color primary = Color(0xFF000000); // Чистый черный
  static const Color secondary = Color(0xFFFFFFFF); // Чистый белый
  static const Color accent = Color(0xFF000000); // Черный для акцентов
  
  // Фоновые цвета
  static const Color background = Color(0xFFFFFFFF); // Чистый белый фон как у Adidas
  static const Color cardBackground = Color(0xFFFFFFFF); // Белый фон для карточек
  static const Color lightGray = Color(0xFFF5F5F5); // Очень светло-серый для разделения
  
  // Цвета текста
  static const Color textPrimary = Color(0xFF000000); // Черный текст
  static const Color textSecondary = Color(0xFF767676); // Серый текст как у Adidas
  static const Color textLight = Color(0xFFFFFFFF); // Белый текст
  static const Color textMuted = Color(0xFF9E9E9E); // Приглушенный серый
  
  // Цвета кнопок в стиле Adidas
  static const Color buttonPrimary = Color(0xFF000000); // Черная кнопка
  static const Color buttonSecondary = Color(0xFFFFFFFF); // Белая кнопка
  static const Color buttonOutline = Color(0xFF000000); // Черная обводка
  static const Color buttonDisabled = Color(0xFFE0E0E0); // Отключенная кнопка
  
  // Цвета состояний
  static const Color success = Color(0xFF00C851); // Зеленый успех
  static const Color error = Color(0xFFFF4444); // Красный как у Adidas
  static const Color warning = Color(0xFFFFBB33); // Оранжевый предупреждение
  static const Color info = Color(0xFF33B5E5); // Синий информация
  
  // Цвета для интерактивных элементов
  static const Color border = Color(0xFFE5E5E5); // Светлые границы
  static const Color divider = Color(0xFFF0F0F0); // Разделители
  static const Color shadow = Color(0x0A000000); // Легкая тень
  static const Color overlay = Color(0x80000000); // Затемнение
  
  // Цвета для избранного (сердечко)
  static const Color favoriteActive = Color(0xFFFF4444); // Красное сердечко
  static const Color favoriteInactive = Color(0xFF767676); // Серое сердечко
  
  // Цвета скидок и цен
  static const Color discountRed = Color(0xFFFF4444); // Красный для скидок
  static const Color priceGreen = Color(0xFF00C851); // Зеленый для цен
  
  // Hover эффекты
  static const Color hoverOverlay = Color(0x0F000000); // Наведение
  static const Color pressedOverlay = Color(0x1F000000); // Нажатие
  
  // Цвета для размеров и опций
  static const Color sizeSelected = Color(0xFF000000); // Выбранный размер
  static const Color sizeDefault = Color(0xFFFFFFFF); // Обычный размер
  static const Color sizeBorder = Color(0xFFE5E5E5); // Граница размера
  
  // Градиенты для баннеров
  static const LinearGradient bannerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x80000000),
      Color(0x40000000),
    ],
  );
  
  // Цвета категорий (сохраняем старые для совместимости)
  static const Map<String, Color> productColors = {
    'Қара': Color(0xFF000000), // Черный
    'Ақ': Color(0xFFFFFFFF), // Белый
    'Сұр': Color(0xFF9E9E9E), // Серый
    'Көк': Color(0xFF2196F3), // Синий
    'Қызыл': Color(0xFFF44336), // Красный
    'Жасыл': Color(0xFF4CAF50), // Зеленый
    'Сары': Color(0xFFFFEB3B), // Желтый
    'Қоңыр': Color(0xFF795548), // Коричневый
  };
  
  // Статусы заказов
  static const Map<String, Color> orderStatusColors = {
    'pending': Color(0xFFFFBB33), // Ожидание
    'processing': Color(0xFF33B5E5), // Обработка
    'shipped': Color(0xFF9C27B0), // Отправлен
    'delivered': Color(0xFF00C851), // Доставлен
    'cancelled': Color(0xFFFF4444), // Отменен
  };
}