import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isFullWidth;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final bool showArrow;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isFullWidth = true,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 56,
    this.showArrow = false,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: widget.height,
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.98 : 1.0),
          child: _buildButton(),
        ),
      ),
    );
  }

  Widget _buildButton() {
    switch (widget.type) {
      case ButtonType.primary:
        return _buildPrimaryButton();
      case ButtonType.secondary:
        return _buildSecondaryButton();
      case ButtonType.outline:
        return _buildOutlineButton();
      case ButtonType.text:
        return _buildTextButton();
    }
  }

  Widget _buildPrimaryButton() {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isHovering 
            ? AppColors.primary.withOpacity(0.9)
            : AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Прямоугольные кнопки как у Adidas
        ),
        padding: EdgeInsets.zero,
      ),
      child: Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.onPressed == null 
              ? AppColors.buttonDisabled
              : (_isHovering 
                  ? AppColors.primary.withOpacity(0.9)
                  : AppColors.primary),
        ),
        child: _buildButtonContent(AppColors.textLight),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isHovering 
            ? AppColors.lightGray
            : AppColors.secondary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.border, width: 1),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.onPressed == null 
              ? AppColors.buttonDisabled
              : (_isHovering 
                  ? AppColors.lightGray
                  : AppColors.secondary),
          border: Border.all(
            color: widget.onPressed == null 
                ? AppColors.border
                : AppColors.primary,
            width: 1,
          ),
        ),
        child: _buildButtonContent(AppColors.textPrimary),
      ),
    );
  }

  Widget _buildOutlineButton() {
    return OutlinedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: _isHovering 
            ? AppColors.primary
            : Colors.transparent,
        foregroundColor: _isHovering 
            ? AppColors.textLight
            : AppColors.primary,
        side: BorderSide(
          color: widget.onPressed == null 
              ? AppColors.buttonDisabled
              : AppColors.primary,
          width: 2,
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        padding: EdgeInsets.zero,
      ),
      child: Container(
        width: double.infinity,
        height: widget.height,
        child: _buildButtonContent(
          _isHovering ? AppColors.textLight : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTextButton() {
    return TextButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: TextButton.styleFrom(
        backgroundColor: _isHovering 
            ? AppColors.hoverOverlay
            : Colors.transparent,
        foregroundColor: AppColors.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        padding: EdgeInsets.zero,
      ),
      child: Container(
        width: double.infinity,
        height: widget.height,
        child: _buildButtonContent(AppColors.primary),
      ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
      );
    }

    final List<Widget> children = [];
    
    // Иконка слева
    if (widget.icon != null) {
      children.add(
        Icon(
          widget.icon,
          size: 20,
          color: textColor,
        ),
      );
      children.add(const SizedBox(width: 12));
    }

    // Текст
    children.add(
      Text(
        widget.text.toUpperCase(),
        style: AppTextStyles.buttonMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );

    // Стрелочка справа (как у Adidas)
    if (widget.showArrow || widget.type == ButtonType.primary) {
      children.add(const SizedBox(width: 12));
      children.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..translate(_isHovering ? 4.0 : 0.0, 0.0),
          child: Icon(
            Icons.arrow_forward,
            size: 20,
            color: textColor,
          ),
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

// Специальная кнопка для избранного в стиле Adidas
class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onPressed;
  final double size;

  const FavoriteButton({
    Key? key,
    required this.isFavorite,
    required this.onPressed,
    this.size = 40,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () {
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
          widget.onPressed();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _isHovering 
                ? AppColors.cardBackground.withOpacity(0.95)
                : AppColors.cardBackground.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: _isHovering ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: widget.isFavorite 
                      ? AppColors.favoriteActive 
                      : AppColors.favoriteInactive,
                  size: widget.size * 0.5,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Кнопка "Добавить в корзину" в стиле Adidas
class AddToCartButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isInStock;

  const AddToCartButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.isInStock = true,
  }) : super(key: key);

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: widget.isInStock
              ? (_isHovering ? AppColors.primary.withOpacity(0.9) : AppColors.primary)
              : AppColors.buttonDisabled,
          shape: BoxShape.circle,
          boxShadow: widget.isInStock && _isHovering
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isInStock && !widget.isLoading ? widget.onPressed : null,
            customBorder: const CircleBorder(),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textLight,
                        ),
                      ),
                    )
                  : Icon(
                      widget.isInStock ? Icons.add : Icons.block,
                      color: AppColors.textLight,
                      size: 24,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}