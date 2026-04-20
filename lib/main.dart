import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/not_found_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ru_RU', null);

  await Supabase.initialize(
    url: 'https://yudejpwkbsvzpptfoboq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl1ZGVqcHdrYnN2enBwdGZvYm9xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1ODMyNDUsImV4cCI6MjA4NDE1OTI0NX0.NocZ1Ig_SrhsNCEXhIULcba-UKoLWFehe1KZTjJstdA',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF97412);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        Provider(create: (_) => SupabaseService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) => MaterialApp.router(
          title: 'PhotoChef',
          debugShowCheckedModeBanner: false,
          themeMode: themeService.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              secondary: primaryColor,
              brightness: Brightness.light,
            ),
            primaryColor: primaryColor,
            scaffoldBackgroundColor: const Color(0xFFFFFFFF),
            cardColor: const Color(0xFFF5F5F5),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              centerTitle: false,
              iconTheme: IconThemeData(color: Colors.black87),
              titleTextStyle: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.dark(
              primary: primaryColor,
              secondary: primaryColor,
            ),
            primaryColor: primaryColor,
            scaffoldBackgroundColor: const Color(0xFF000000),
            cardColor: const Color(0xFF111111),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              centerTitle: false,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          routerConfig: _router,
        ),
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/404',
      builder: (context, state) => const NotFoundScreen(),
    ),
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);

