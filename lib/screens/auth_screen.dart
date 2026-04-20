import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../widgets/background_particles.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  final primaryColor = const Color(0xFFF97412); // RGB(249,116,18)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1); // Регистрация по умолчанию
    _tabController.addListener(() {
      // Очищаем поля при переключении вкладок
      if (!_tabController.indexIsChanging) {
        _emailController.clear();
        _passwordController.clear();
        _nameController.clear();
        _formKey.currentState?.reset();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        context.go('/');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вход выполнен успешно!')),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Ошибка при входе';
        final errorString = e.toString().toLowerCase();
        
        if (errorString.contains('invalid login credentials') ||
            errorString.contains('invalid credentials')) {
          errorMessage = 'Неверный email или пароль';
        } else if (errorString.contains('email not confirmed') ||
                   errorString.contains('email not verified')) {
          errorMessage = 'Email не подтвержден. Проверьте почту';
        } else if (errorString.contains('user not found')) {
          errorMessage = 'Пользователь не найден';
        } else if (errorString.contains('network') || errorString.contains('connection')) {
          errorMessage = 'Ошибка подключения. Проверьте интернет';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signUp(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );
      
      // Проверяем, что пользователь действительно авторизован
      if (mounted) {
        // Даем немного времени для обновления состояния
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (authService.isAuthenticated && authService.session != null) {
          context.go('/');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Регистрация успешна! Вход выполнен')),
          );
        } else {
          // Если авторизация не прошла, возможно требуется подтверждение email
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Регистрация успешна! Проверьте почту для подтверждения или войдите в аккаунт'),
              duration: Duration(seconds: 5),
            ),
          );
          // Переключаемся на вкладку входа
          _tabController.animateTo(0);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Ошибка при регистрации';
        final errorString = e.toString().toLowerCase();
        
        if (errorString.contains('already registered') || 
            errorString.contains('user already registered')) {
          errorMessage = 'Этот email уже зарегистрирован';
        } else if (errorString.contains('email') && errorString.contains('confirm')) {
          errorMessage = 'Проверьте почту для подтверждения аккаунта';
        } else if (errorString.contains('invalid email')) {
          errorMessage = 'Неверный формат email';
        } else if (errorString.contains('password')) {
          errorMessage = 'Пароль слишком слабый. Минимум 6 символов';
        } else if (errorString.contains('network') || errorString.contains('connection')) {
          errorMessage = 'Ошибка подключения. Проверьте интернет';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Фоновые частицы (как на главной странице)
          const BackgroundParticles(),
          
          // Градиентный фон
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.2, -0.8),
                radius: 1.5,
                colors: [
                  primaryColor.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Основной контент
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.grey[800]!.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Кнопка выхода (назад)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.grey[400],
                                      ),
                                      onPressed: () => context.go('/'),
                                      tooltip: 'Закрыть',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Logo
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: primaryColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.restaurant_menu,
                                    size: 36,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // App Name
                                const Text(
                                  'PhotoChef',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // Tagline
                                Text(
                                  'Войдите, чтобы сохранять рецепты',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // Tabs
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey[800]!.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: TabBar(
                                    controller: _tabController,
                                    indicator: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: primaryColor.withOpacity(0.35),
                                        width: 1,
                                      ),
                                    ),
                                    labelColor: primaryColor,
                                    unselectedLabelColor: Colors.grey[400],
                                    labelStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    unselectedLabelStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    dividerColor: Colors.transparent,
                                    tabs: const [
                                      Tab(text: 'Вход'),
                                      Tab(text: 'Регистрация'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                
                                // Forms
                                SizedBox(
                                  height: 400,
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      _buildSignInForm(),
                                      _buildSignUpForm(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'your@email.com',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[800]!.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[800]!.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.6), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите email';
                }
                if (!value.contains('@')) {
                  return 'Неверный формат email';
                }
                return null;
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Password Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Пароль',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[800]!.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[800]!.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.6), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите пароль';
                }
                if (value.length < 6) {
                  return 'Пароль должен содержать минимум 6 символов';
                }
                return null;
              },
            ),
          ],
        ),
        const SizedBox(height: 28),
        // Sign In Button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : const Text(
                  'Войти',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Имя',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ваше имя',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.person_outline, color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[800]!.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[800]!.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.6), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите имя';
                }
                if (value.length < 2) {
                  return 'Имя должно содержать минимум 2 символа';
                }
                return null;
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Email Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'your@email.com',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[800]!.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[800]!.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.6), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите email';
                }
                if (!value.contains('@')) {
                  return 'Неверный формат email';
                }
                return null;
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Password Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Пароль',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[800]!.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[800]!.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.6), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите пароль';
                }
                if (value.length < 6) {
                  return 'Пароль должен содержать минимум 6 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 4),
            Text(
              'Минимум 6 символов',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        // Sign Up Button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSignUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : const Text(
                  'Создать аккаунт',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}
