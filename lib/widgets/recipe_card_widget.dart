import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class RecipeCardWidget extends StatefulWidget {
  final String recipes;
  final String? imageUrl;
  final Session? session;

  const RecipeCardWidget({
    super.key,
    required this.recipes,
    this.imageUrl,
    this.session,
  });

  @override
  State<RecipeCardWidget> createState() => _RecipeCardWidgetState();
}

class _RecipeCardWidgetState extends State<RecipeCardWidget> {
  bool _isSaving = false;
  bool _isSaved = false;
  String _currentRecipes = '';
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  bool _isSending = false;
  final FocusNode _chatFocusNode = FocusNode();
  final FocusNode _keyboardListenerFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentRecipes = widget.recipes;
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatFocusNode.dispose();
    _keyboardListenerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    if (widget.session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Войдите, чтобы сохранить рецепт'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final supabaseService = SupabaseService();
      await supabaseService.saveRecipe(
        userId: widget.session!.user.id,
        recipesText: _currentRecipes,
        imageUrl: null, // Сохраняем рецепты без фото
      );
      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Рецепт сохранен в историю!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить рецепт'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _sendMessage(String? message) async {
    final messageToSend = message ?? _chatController.text.trim();
    if (messageToSend.isEmpty || _isSending) return;

    if (message == null) {
      _chatController.clear();
    }

    setState(() {
      _chatHistory.add({'role': 'user', 'content': messageToSend});
      _isSending = true;
    });

    try {
      final supabaseService = SupabaseService();
      final reply = await supabaseService.chatRecipe(
        message: messageToSend,
        context: _currentRecipes,
      );

      if (mounted) {
        setState(() {
          _chatHistory.add({'role': 'assistant', 'content': reply});
          // Обновляем рецепты, если ответ длинный (вероятно, это новый рецепт)
          if (reply.length > 100) {
            _currentRecipes = reply;
          }
          _isSending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при отправке сообщения'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleQuickAction(String action) {
    String message = '';
    switch (action) {
      case 'quick':
        message =
            'Покажи только самые быстрые рецепты (до 30 минут приготовления) из этого списка';
        break;
      case 'popular':
        message =
            'Покажи самые популярные и проверенные рецепты из этого списка';
        break;
      case 'ai':
        message =
            'Дай персональные рекомендации: какой рецепт лучше выбрать и почему, учитывая баланс вкуса, пользы и простоты приготовления';
        break;
    }
    _sendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Рекомендованные рецепты',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'На основе ваших продуктов',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.session != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ElevatedButton.icon(
                  icon: _isSaved
                      ? const Icon(Icons.check)
                      : const Icon(Icons.save),
                  label: Text(_isSaved ? 'Сохранено' : 'Сохранить'),
                  onPressed: _isSaving || _isSaved ? null : _saveRecipe,
                ),
              ),
          ],
        ),

        const SizedBox(height: 24),

        // Recipe Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _currentRecipes,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Quick Actions
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.access_time, size: 16),
              label: const Text('Быстрые рецепты'),
              onPressed: _isSending ? null : () => _handleQuickAction('quick'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.trending_up, size: 16),
              label: const Text('Популярные блюда'),
              onPressed:
                  _isSending ? null : () => _handleQuickAction('popular'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('AI рекомендации'),
              onPressed: _isSending ? null : () => _handleQuickAction('ai'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Chat Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Чат с AI шеф-поваром',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Chat History
                if (_chatHistory.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _chatHistory.length,
                      itemBuilder: (context, index) {
                        final message = _chatHistory[index];
                        final isUser = message['role'] == 'user';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1)
                                : Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              left: BorderSide(
                                color: isUser
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[700]!,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isUser ? 'Вы' : '🤖 AI Шеф-повар',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message['content']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                // Chat Input
                FocusScope(
                  child: KeyboardListener(
                    focusNode: _keyboardListenerFocusNode,
                    autofocus: false,
                    onKeyEvent: (KeyEvent event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.enter &&
                          !HardwareKeyboard.instance.isShiftPressed &&
                          _chatFocusNode.hasFocus &&
                          _chatController.text.trim().isNotEmpty &&
                          !_isSending) {
                        _sendMessage(null);
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            focusNode: _chatFocusNode,
                            maxLines: 4,
                            enabled: !_isSending,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintText:
                                  'Спросите что-то о рецепте, попросите изменить ингредиенты...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: _isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                          onPressed: _isSending ||
                                  _chatController.text.trim().isEmpty
                              ? null
                              : () => _sendMessage(null),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '💡 Нажмите Enter для отправки',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }
}















