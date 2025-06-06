// Создайте новый файл: lib/utils/image_helper.dart

import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ImageHelper {
  /// Универсальный метод для загрузки изображений
  /// Если URL начинается с http/https - загружаем из интернета
  /// Если начинается с assets/ - загружаем из локальных ресурсов
  /// Иначе пытаемся загрузить как asset
  static Widget buildProductImage(
    String imageUrl, {
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? _buildDefaultPlaceholder(width, height);
    }

    // Если URL начинается с http или https - загружаем из интернета
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? 
              _buildLoadingIndicator(width, height, loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) {
          print('Ошибка загрузки сетевого изображения: $error');
          return errorWidget ?? _buildDefaultPlaceholder(width, height);
        },
      );
    }
    
    // Иначе загружаем как локальный asset
    return Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        print('Ошибка загрузки локального изображения: $error');
        return errorWidget ?? _buildDefaultPlaceholder(width, height);
      },
    );
  }

  static Widget _buildLoadingIndicator(
    double width, 
    double height, 
    ImageChunkEvent loadingProgress
  ) {
    return Container(
      width: width,
      height: height,
      color: AppColors.lightGray,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primary,
              strokeWidth: 2,
            ),
            const SizedBox(height: 8),
            const Text(
              'Жүктелуде...',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDefaultPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: AppColors.lightGray,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: width > 100 ? 60 : 30,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            const Text(
              'СУРЕТ ЖОҚ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}