import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../routes.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin;

  const AuthScreen({
    Key? key,
    this.isLogin = true,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late bool _isLogin;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? AppStrings.login : AppStrings.register),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Логотип или изображение
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'QR',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Заголовок формы
              Text(
                _isLogin ? AppStrings.login : AppStrings.register,
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Форма
              if (!_isLogin) ...[
                // Имя (только для регистрации)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.name,
                    prefixIcon: Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.fieldRequired;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
              ],
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: AppStrings.email,
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return AppStrings.invalidEmail;
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Пароль
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppStrings.password,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  if (value.length < 6) {
                    return AppStrings.passwordTooShort;
                  }
                  return null;
                },
              ),
              
              if (!_isLogin) ...[
                const SizedBox(height: 16),
                
                // Подтверждение пароля (только для регистрации)
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: AppStrings.confirmPassword,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.fieldRequired;
                    }
                    if (value != _passwordController.text) {
                      return AppStrings.passwordsDontMatch;
                    }
                    return null;
                  },
                ),
              ],
              
              if (_isLogin) ...[
                const SizedBox(height: 16),
                
                // Забыли пароль (только для входа)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // В будущем можно добавить функционал восстановления пароля
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Бұл функция әзірше қолжетімсіз'),
                        ),
                      );
                    },
                    child: Text(AppStrings.forgotPassword),
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Кнопка действия (Вход/Регистрация)
              CustomButton(
                text: _isLogin ? AppStrings.signIn : AppStrings.signUp,
                isLoading: authProvider.isLoading,
                onPressed: () {
                  _submit(authProvider);
                },
              ),
              
              const SizedBox(height: 16),
              
              // Переключение между формами
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? AppStrings.dontHaveAccount : AppStrings.alreadyHaveAccount,
                    style: AppTextStyles.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin ? AppStrings.signUp : AppStrings.signIn,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text;
    final password = _passwordController.text;

    if (_isLogin) {
      // Вход в систему
      final success = await authProvider.login(email, password);
      
      if (success && mounted) {
        // Возвращаемся на предыдущий экран при успешном входе
        Navigator.pop(context);
      } else if (mounted) {
        // Показываем ошибку
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error)),
        );
      }
    } else {
      // Регистрация
      final name = _nameController.text;
      final success = await authProvider.register(name, email, password);
      
      if (success && mounted) {
        // Возвращаемся на предыдущий экран при успешной регистрации
        Navigator.pop(context);
      } else if (mounted) {
        // Показываем ошибку
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error)),
        );
      }
    }
  }
}