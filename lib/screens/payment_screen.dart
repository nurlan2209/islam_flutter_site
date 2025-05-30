import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/local_order_service.dart'; // Импортируем новый сервис
import '../widgets/custom_button.dart';
import '../routes.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({
    Key? key,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _paymentMethod = 'card'; // 'card' или 'cash'
  bool _isProcessing = false;
  bool _sameAsBillingAddress = true;
  final LocalOrderService _orderService = LocalOrderService(); // Инициализируем сервис

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.payment),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Общая сумма заказа
              Card(
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        AppStrings.total,
                        style: AppTextStyles.heading3,
                      ),
                      const Spacer(),
                      Text(
                        '${widget.totalAmount} ${AppStrings.currency}',
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Выбор способа оплаты
              Text(
                AppStrings.paymentMethod,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              _buildPaymentMethodSelector(),
              
              const SizedBox(height: 24),
              
              // Форма для оплаты картой
              if (_paymentMethod == 'card') ...[
                Text(
                  AppStrings.cardPayment,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 16),
                _buildCardPaymentForm(),
              ],
              
              // Адрес доставки
              const SizedBox(height: 24),
              Text(
                AppStrings.shippingAddress,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              
              if (_paymentMethod == 'card') ...[
                CheckboxListTile(
                  title: Text(AppStrings.sameAsBillingAddress),
                  value: _sameAsBillingAddress,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    setState(() {
                      _sameAsBillingAddress = value ?? true;
                    });
                  },
                ),
                
                if (!_sameAsBillingAddress) _buildAddressField(),
              ] else ...[
                _buildAddressField(),
              ],
              
              const SizedBox(height: 32),
              
              // Кнопка оформления заказа
              CustomButton(
                text: AppStrings.placeOrder,
                isLoading: _isProcessing,
                onPressed: _processPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildMethodCard(
            title: AppStrings.cardPayment,
            icon: Icons.credit_card,
            isSelected: _paymentMethod == 'card',
            onTap: () {
              setState(() {
                _paymentMethod = 'card';
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMethodCard(
            title: AppStrings.cashOnDelivery,
            icon: Icons.money,
            isSelected: _paymentMethod == 'cash',
            onTap: () {
              setState(() {
                _paymentMethod = 'cash';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.textLight : AppColors.textPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: isSelected
                  ? AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)
                  : AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPaymentForm() {
    return Column(
      children: [
        // Номер карты
        TextFormField(
          controller: _cardNumberController,
          decoration: const InputDecoration(
            labelText: AppStrings.cardNumber,
            hintText: 'XXXX XXXX XXXX XXXX',
            prefixIcon: Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            _CardNumberFormatter(),
          ],
          validator: (value) {
            if (_paymentMethod == 'card') {
              if (value == null || value.isEmpty) {
                return AppStrings.fieldRequired;
              }
              if (value.replaceAll(' ', '').length < 16) {
                return AppStrings.invalidCardNumber;
              }
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Имя держателя карты
        TextFormField(
          controller: _cardHolderController,
          decoration: const InputDecoration(
            labelText: AppStrings.cardHolderName,
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (_paymentMethod == 'card') {
              if (value == null || value.isEmpty) {
                return AppStrings.fieldRequired;
              }
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Срок действия и CVV
        Row(
          children: [
            // Срок действия
            Expanded(
              child: TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: AppStrings.expiryDate,
                  hintText: 'MM/YY',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryDateFormatter(),
                ],
                validator: (value) {
                  if (_paymentMethod == 'card') {
                    if (value == null || value.isEmpty) {
                      return AppStrings.fieldRequired;
                    }
                    if (value.length < 5) {
                      return AppStrings.invalidExpiryDate;
                    }
                  }
                  return null;
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            // CVV
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: 'XXX',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                obscureText: true,
                validator: (value) {
                  if (_paymentMethod == 'card') {
                    if (value == null || value.isEmpty) {
                      return AppStrings.fieldRequired;
                    }
                    if (value.length < 3) {
                      return AppStrings.invalidCVV;
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      decoration: const InputDecoration(
        labelText: AppStrings.address,
        hintText: 'Қала, көше, үй, пәтер',
        prefixIcon: Icon(Icons.location_on),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.fieldRequired;
        }
        return null;
      },
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Имитация обработки платежа
      await Future.delayed(const Duration(seconds: 2));
      
      // Получаем данные пользователя и корзины
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      if (!authProvider.isLoggedIn) {
        throw Exception('Пользователь не авторизован');
      }
      
      // Получаем адрес доставки
      final address = _addressController.text.isNotEmpty
          ? _addressController.text
          : "Не указан"; // На реальном проекте можно использовать адрес из профиля
      
      // Создаем заказ
      final orderId = await _orderService.createOrderFromCart(
        userId: authProvider.user!.id,
        userName: authProvider.user!.name,
        cartItems: cartProvider.items,
        totalAmount: widget.totalAmount,
        address: address,
        paymentMethod: _paymentMethod,
      );
      
      // Очищаем корзину после успешного создания заказа
      if (orderId != null) {
        await cartProvider.clearCart(authProvider.user!.id);
        
        // Показываем сообщение об успешной оплате
        if (mounted) {
          _showSuccessDialog(orderId);
        }
      } else {
        throw Exception('Не удалось создать заказ');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.paymentSuccessful),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Тапсырысыңыз қабылданды! Жақын арада сізге қоңырау шалады.'),
            const SizedBox(height: 8),
            Text('Тапсырыс нөмірі: #${orderId.substring(0, 8)}...'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName(AppRoutes.home));
            },
            child: const Text(AppStrings.home),
          ),
        ],
      ),
    );
  }
}

// Форматтер для номера карты (XXXX XXXX XXXX XXXX)
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final text = newValue.text.replaceAll(' ', '');
    
    if (text.length > 16) {
      return oldValue;
    }
    
    // Добавляем пробелы после каждых 4 цифр
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i != text.length - 1) {
        buffer.write(' ');
      }
    }
    
    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Форматтер для срока действия карты (MM/YY)
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final text = newValue.text.replaceAll('/', '');
    
    if (text.length > 4) {
      return oldValue;
    }
    
    // Добавляем / после первых 2 цифр
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && i != text.length - 1) {
        buffer.write('/');
      }
    }
    
    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}