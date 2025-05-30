import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../constants/text_styles.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

class UsersList extends StatefulWidget {
  const UsersList({Key? key}) : super(key: key);

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  List<User> _users = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final authService = AuthService();
      final users = await authService.getAllUsers();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Қайта жүктеу'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Text('Пайдаланушылар тізімі бос'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserItem(user);
      },
    );
  }

  Widget _buildUserItem(User user) {
    final isAdmin = user.role == 'admin';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isAdmin ? AppColors.primary : AppColors.secondary,
          child: Icon(
            Icons.person,
            color: isAdmin ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
        title: Text(
          user.name,
          style: AppTextStyles.bodyLarge,
        ),
        subtitle: Text(
          user.email,
          style: AppTextStyles.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Статус (Админ/Пользователь)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isAdmin ? AppColors.primary : AppColors.secondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isAdmin ? 'Админ' : 'Қолданушы',
                style: TextStyle(
                  color: isAdmin ? AppColors.textLight : AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Кнопка опций
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'delete') {
                  _showDeleteConfirmation(user);
                } else if (value == 'make_admin') {
                  _makeAdmin(user);
                } else if (value == 'remove_admin') {
                  _removeAdmin(user);
                }
              },
              itemBuilder: (context) => [
                if (!isAdmin)
                  const PopupMenuItem<String>(
                    value: 'make_admin',
                    child: Text('Әкімші жасау'),
                  ),
                if (isAdmin)
                  const PopupMenuItem<String>(
                    value: 'remove_admin',
                    child: Text('Әкімші құқығын алып тастау'),
                  ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Пайдаланушыны жою'),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // В будущем можно добавить детальный просмотр пользователя
        },
      ),
    );
  }

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пайдаланушыны жою'),
        content: Text('${user.name} пайдаланушысын жоюды растаңыз?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(User user) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authService = AuthService();
      final success = await authService.deleteUser(user.id);

      if (success) {
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пайдаланушы жойылды')),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Пайдаланушыны жою кезінде қате пайда болды';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _makeAdmin(User user) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authService = AuthService();
      final updatedUser = user.copyWith(role: 'admin');
      final success = await authService.updateUser(updatedUser);

      if (success) {
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пайдаланушы әкімші құқықтарын алды')),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Пайдаланушы рөлін өзгерту кезінде қате пайда болды';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _removeAdmin(User user) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authService = AuthService();
      final updatedUser = user.copyWith(role: 'user');
      final success = await authService.updateUser(updatedUser);

      if (success) {
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пайдаланушыдан әкімші құқықтары алынды')),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Пайдаланушы рөлін өзгерту кезінде қате пайда болды';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
}