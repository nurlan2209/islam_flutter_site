import 'package:flutter/material.dart';

class AppColors {
  // Основные цвета
  static const Color primary = Color.fromARGB(255, 0, 0, 0); // Қара - Черный
  static const Color secondary = Color(0xFFFFFFFF); // Ақ - Белый
  static const Color accent = Color(0xFF0070BA); // Көк - Синий (для акцентов)
  
  // Фоновые цвета
  static const Color background = Color(0xFFF5F5F5); // Светло-серый фон
  static const Color cardBackground = Color(0xFFFFFFFF); // Белый фон для карточек

  // Цвета текста
  static const Color textPrimary = Color(0xFF212121); // Основной цвет текста
  static const Color textSecondary = Color(0xFF757575); // Вторичный цвет текста
  static const Color textLight = Color(0xFFFFFFFF); // Светлый текст
  
  // Цвета элементов интерфейса
  static const Color buttonPrimary = Color.fromARGB(255, 0, 0, 0); // Черная кнопка 
  static const Color buttonSecondary = Color(0xFF424242); // Серая кнопка
  static const Color buttonDisabled = Color(0xFFBDBDBD); // Отключенная кнопка
  
  // Цвета состояний и обратной связи
  static const Color success = Color(0xFF4CAF50); // Зеленый - успех
  static const Color error = Color(0xFFE53935); // Красный - ошибка
  static const Color warning = Color(0xFFFFB300); // Желтый - предупреждение
  static const Color info = Color(0xFF2196F3); // Синий - информация
  
  // Цвета границ
  static const Color border = Color(0xFFE0E0E0); // Светло-серый для границ
  static const Color divider = Color(0xFFEEEEEE); // Еще светлее для разделителей
  
  // Цвета теней
  static const Color shadow = Color(0x1A000000); // Тень с низкой прозрачностью
  
  // Цвета для выбора одежды
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
}