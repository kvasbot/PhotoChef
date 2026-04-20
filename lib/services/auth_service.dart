import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _user;
  Session? _session;

  User? get user => _user;
  Session? get session => _session;
  bool get isAuthenticated => _user != null;

  AuthService() {
    _init();
  }

  void _init() {
    _user = _supabaseService.currentUser;
    _session = _supabaseService.currentSession;
    
    // Слушатель изменений авторизации
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      _session = data.session;
      notifyListeners();
    });
  }

  // Вход
  Future<void> signIn(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      
      _user = response.user;
      _session = response.session;
      
      // Логирование для отладки
      if (kDebugMode) {
        print('🔐 Вход: user=${_user?.id}, session=${_session != null}');
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка входа: $e');
      }
      rethrow;
    }
  }

  // Регистрация
  Future<void> signUp(String email, String password, String fullName) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
        },
      );
      
      _user = response.user;
      _session = response.session;
      
      // Если сессия null (требуется подтверждение email), 
      // попробуем получить текущую сессию
      if (_session == null && _user != null) {
        _session = _supabaseService.currentSession;
      }
      
      // Логирование для отладки
      if (kDebugMode) {
        print('🔐 Регистрация: user=${_user?.id}, session=${_session != null}');
      }
      
      notifyListeners();
      
      // Если все еще нет сессии, выбрасываем ошибку
      if (_session == null) {
        throw Exception('Требуется подтверждение email. Проверьте почту для подтверждения аккаунта или отключите подтверждение email в настройках Supabase.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка регистрации: $e');
      }
      rethrow;
    }
  }

  // Выход
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    _user = null;
    _session = null;
    notifyListeners();
  }
}














