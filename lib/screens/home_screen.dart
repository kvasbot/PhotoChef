import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/recipe_card_widget.dart';
import '../widgets/about_modal.dart';
import '../widgets/contact_modal.dart';
import '../widgets/background_particles.dart';
import '../widgets/theme_toggle_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _recipes;
  String? _imageUrl;

  void _handleImageAnalyzed(String recipes, String imageUrl) {
    setState(() {
      _recipes = recipes;
      _imageUrl = imageUrl;
    });
  }

  void _handleReset() {
    setState(() {
      _recipes = null;
      _imageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isAuthenticated = authService.isAuthenticated;

    return Scaffold(
      body: Stack(
        children: [
          // Фоновые частицы
          const BackgroundParticles(),
          
          // Основной контент
          CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      color: Colors.black.withOpacity(0.35),
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.restaurant_menu, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'PhotoChef',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Кнопка переключения темы (белая)
                  const ThemeToggleButton(),
                  if (isAuthenticated) ...[
                    IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: () => context.go('/history'),
                      tooltip: 'История',
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await authService.signOut();
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Вы вышли из аккаунта')),
                          );
                        }
                      },
                      tooltip: 'Выйти',
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text('Войти'),
                        onPressed: () => context.go('/auth'),
                      ),
                    ),
                ],
              ),

              // Hero Section
              if (_recipes == null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI-помощник повара',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Найди рецепт для своих\nпродуктов',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Сфотографируй свой холодильник, и наш AI предложит идеальные рецепты из того, что у тебя есть',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[400],
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _recipes == null
                      ? Column(
                          children: [
                            ImageUploadWidget(
                              onImageAnalyzed: _handleImageAnalyzed,
                              session: authService.session,
                            ),
                            const SizedBox(height: 48),
                            // Features
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 600 || constraints.maxWidth == double.infinity) {
                                  // На маленьких экранах - вертикально
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildFeature(
                                        context,
                                        Icons.restaurant_menu,
                                        'Умный анализ',
                                        'AI распознает продукты на фото',
                                      ),
                                      const SizedBox(height: 16),
                                      _buildFeature(
                                        context,
                                        Icons.auto_awesome,
                                        'Персональные рецепты',
                                        'Рецепты под твои ингредиенты',
                                      ),
                                      const SizedBox(height: 16),
                                      _buildFeature(
                                        context,
                                        Icons.history,
                                        'История',
                                        'Сохраняй любимые рецепты',
                                      ),
                                    ],
                                  );
                                } else {
                                  // На больших экранах - горизонтально
                                  return ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: constraints.maxWidth.isFinite 
                                          ? constraints.maxWidth 
                                          : double.infinity,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _buildFeature(
                                            context,
                                            Icons.restaurant_menu,
                                            'Умный анализ',
                                            'AI распознает продукты на фото',
                                            expandWidth: false,
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildFeature(
                                            context,
                                            Icons.auto_awesome,
                                            'Персональные рецепты',
                                            'Рецепты под твои ингредиенты',
                                            expandWidth: false,
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildFeature(
                                            context,
                                            Icons.history,
                                            'История',
                                            'Сохраняй любимые рецепты',
                                            expandWidth: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            RecipeCardWidget(
                              recipes: _recipes!,
                              imageUrl: _imageUrl,
                              session: authService.session,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.restaurant_menu),
                              label: const Text('Найти новые рецепты'),
                              onPressed: _handleReset,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Footer
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 48),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.2),
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[800]!,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PhotoChef 2026',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AboutModal(
                                  onClose: () => Navigator.of(context).pop(),
                                ),
                              );
                            },
                            child: const Text('О проекте'),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => ContactModal(
                                  onClose: () => Navigator.of(context).pop(),
                                ),
                              );
                            },
                            child: const Text('Контакты'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(
    BuildContext context,
    IconData icon,
    String title,
    String description, {
    bool expandWidth = true,
  }) {
    return Container(
      width: expandWidth ? double.infinity : null,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

