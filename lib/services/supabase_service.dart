import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  // Получить текущего пользователя
  User? get currentUser => _client.auth.currentUser;

  // Получить сессию
  Session? get currentSession => _client.auth.currentSession;

  // Проверить авторизацию
  bool get isAuthenticated => currentUser != null;

  // Сохранить рецепт в историю
  Future<void> saveRecipe({
    required String userId,
    required String recipesText,
    String? imageUrl,
  }) async {
    // Проверяем авторизацию
    if (!isAuthenticated) {
      throw Exception('Необходима авторизация для сохранения рецептов');
    }
    
    // Убеждаемся, что userId совпадает с текущим пользователем
    final currentUserId = currentUser?.id;
    if (currentUserId == null || currentUserId != userId) {
      throw Exception('Ошибка авторизации: неверный пользователь');
    }
    
    try {
      await _client.from('recipes_history').insert({
        'user_id': userId,
        'recipes_text': recipesText,
        'image_url': imageUrl,
      }).select();
    } catch (e) {
      // Более детальная обработка ошибок
      final errorString = e.toString();
      if (errorString.contains('42501') || errorString.contains('permission denied')) {
        throw Exception('Ошибка доступа. Проверьте настройки безопасности базы данных.');
      } else if (errorString.contains('23503') || errorString.contains('foreign key')) {
        throw Exception('Профиль пользователя не найден. Пожалуйста, перезайдите в систему.');
      }
      rethrow;
    }
  }

  // Получить историю рецептов
  Future<List<RecipeModel>> getRecipesHistory() async {
    // Проверяем авторизацию
    if (!isAuthenticated) {
      throw Exception('Необходима авторизация для просмотра истории рецептов');
    }
    
    final currentUserId = currentUser?.id;
    if (currentUserId == null) {
      throw Exception('Пользователь не авторизован');
    }
    
    try {
      // Явно фильтруем по user_id (RLS также должен это делать, но лучше быть явным)
      final response = await _client
          .from('recipes_history')
          .select()
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => RecipeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('42501') || errorString.contains('permission denied')) {
        throw Exception('Ошибка доступа. Проверьте настройки безопасности базы данных.');
      }
      rethrow;
    }
  }

  // Удалить рецепт
  Future<void> deleteRecipe(String recipeId) async {
    // Проверяем авторизацию
    if (!isAuthenticated) {
      throw Exception('Необходима авторизация для удаления рецептов');
    }
    
    final currentUserId = currentUser?.id;
    if (currentUserId == null) {
      throw Exception('Пользователь не авторизован');
    }
    
    try {
      // Удаляем только если рецепт принадлежит текущему пользователю
      await _client
          .from('recipes_history')
          .delete()
          .eq('id', recipeId)
          .eq('user_id', currentUserId)
          .select();
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('42501') || errorString.contains('permission denied')) {
        throw Exception('Ошибка доступа. Проверьте настройки безопасности базы данных.');
      }
      rethrow;
    }
  }

  // Вызвать Edge Function для анализа рецепта
  Future<String> analyzeRecipe({
    required String imageBase64,
    String? comments,
    bool? isVegan,
    bool? isLowCalorie,
  }) async {
    try {
      print('📤 Отправка запроса на анализ изображения...');
      print('📏 Размер изображения: ${imageBase64.length} символов');
      print('🔑 Есть сессия: ${_client.auth.currentSession != null}');
      print('📋 Вызываем функцию: analyze-recipe');
      
      final response = await _client.functions.invoke(
        'analyze-recipe',
        body: {
          'image': imageBase64,
          'comments': comments ?? '',
          'filters': {
            'vegan': isVegan ?? false,
            'lowCalorie': isLowCalorie ?? false,
          },
        },
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Превышено время ожидания ответа. Проверьте, что Edge Function развернута и работает.');
        },
      );

      print('📥 Получен ответ от функции');
      print('📊 Данные ответа: ${response.data}');

      if (response.data != null && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        
        // Проверяем наличие рецептов
        if (data['recipes'] != null) {
          print('✅ Рецепты успешно получены');
          return data['recipes'] as String;
        }
        
        // Проверяем наличие ошибки
        if (data['error'] != null) {
          final errorMessage = data['error'] as String;
          print('❌ Ошибка от API: $errorMessage');
          throw Exception(errorMessage);
        }
      }
      
      // Если ответ не в ожидаемом формате
      print('⚠️ Неожиданный формат ответа: ${response.data}');
      throw Exception('Не удалось получить рецепты. Проверьте настройки API.');
    } catch (e) {
      print('❌ Исключение при анализе: $e');
      print('❌ Тип ошибки: ${e.runtimeType}');
      
      final errorString = e.toString();
      
      // Обработка специфичных ошибок Supabase
      if (errorString.contains('Function not found') || 
          errorString.contains('404') ||
          errorString.contains('not found')) {
        throw Exception('Функция analyze-recipe не найдена.\n\nУбедитесь, что:\n1. Edge Function развернута в Supabase Dashboard\n2. Название функции точно: analyze-recipe\n3. Функция активна и доступна');
      }
      
      if (errorString.contains('Failed to fetch') ||
          errorString.contains('ClientException')) {
        throw Exception('Не удалось подключиться к Edge Function.\n\nПроверьте:\n1. Edge Function развернута в Supabase Dashboard\n2. Интернет-соединение работает\n3. Supabase проект активен\n\nОткройте Supabase Dashboard → Edge Functions и убедитесь, что функция analyze-recipe существует и развернута.');
      }
      
      if (errorString.contains('GEMINI_API_KEY')) {
        throw Exception('API ключ не настроен.\n\nДобавьте GEMINI_API_KEY в Supabase Dashboard:\n1. Edge Functions → Secrets\n2. Добавьте секрет GEMINI_API_KEY\n3. Вставьте ваш ключ от Google AI Studio');
      }
      
      if (errorString.contains('401') || errorString.contains('403')) {
        throw Exception('Неверный API ключ.\n\nПроверьте GEMINI_API_KEY в настройках Supabase:\n1. Edge Functions → Secrets\n2. Убедитесь, что ключ правильный\n3. Получите новый ключ на https://aistudio.google.com/app/apikey');
      }
      
      if (errorString.contains('429')) {
        throw Exception('Превышен лимит запросов.\n\nПодождите 1-2 минуты и попробуйте снова.\nБесплатный лимит: 60 запросов/минуту');
      }
      
      if (errorString.contains('SAFETY') || errorString.contains('заблокировано')) {
        throw Exception('Изображение было заблокировано системой безопасности.\n\nПопробуйте другое фото.');
      }
      
      if (errorString.contains('SocketException') || 
          errorString.contains('Failed host lookup') ||
          errorString.contains('NetworkException')) {
        throw Exception('Нет подключения к интернету.\n\nПроверьте соединение и попробуйте снова.');
      }
      
      if (errorString.contains('TimeoutException') || 
          errorString.contains('превышено время')) {
        throw Exception('Превышено время ожидания.\n\nПроверьте:\n1. Edge Function развернута\n2. API ключ настроен\n3. Интернет-соединение стабильно');
      }
      
      // Если это уже Exception с понятным сообщением, просто пробрасываем
      if (e is Exception) {
        rethrow;
      }
      
      // Для остальных случаев - общее сообщение с деталями
      throw Exception('Ошибка при анализе изображения.\n\nДетали: ${errorString.length > 150 ? errorString.substring(0, 150) : errorString}\n\nПроверьте логи в Supabase Dashboard → Edge Functions → Logs');
    }
  }

  // Вызвать Edge Function для чата с AI
  Future<String> chatRecipe({
    required String message,
    String? context,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'chat-recipe',
        body: {
          'message': message,
          'context': context ?? '',
        },
      );

      if (response.data != null && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['reply'] != null) {
          return data['reply'] as String;
        }
        if (data['error'] != null) {
          throw Exception(data['error'] as String);
        }
      }
      throw Exception('Не удалось получить ответ');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Ошибка при отправке сообщения: ${e.toString()}');
    }
  }
}

