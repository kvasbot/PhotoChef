# PhotoChef - AI помощник повара

PhotoChef - это кроссплатформенное приложение на Flutter, которое помогает находить рецепты на основе фотографий ваших продуктов.

## Возможности

- 📸 **Умный анализ** - AI распознает продукты на фото
- 🍳 **Персональные рецепты** - Рецепты под ваши ингредиенты
- 📚 **История** - Сохраняйте любимые рецепты
- 🌓 **Темная/светлая тема** - Комфортный интерфейс
- 🔐 **Аутентификация** - Синхронизация через Supabase

## Технологии

- **Flutter 3.38+** - Кроссплатформенный фреймворк
- **Dart** - Язык программирования
- **Supabase** - Backend и аутентификация
- **Provider** - Управление состоянием
- **go_router** - Навигация

## Поддерживаемые платформы

- 🌐 Web
- 📱 Android
- 🍎 iOS
- 🪟 Windows
- 🐧 Linux
- 🍏 macOS

## Установка

### Требования

- Flutter SDK 3.0 или выше
- Dart SDK 3.0 или выше

### Запуск

```bash
# Установка зависимостей
flutter pub get

# Запуск на Web
flutter run -d chrome

# Запуск на Android
flutter run -d android

# Запуск на iOS
flutter run -d ios

# Запуск на Windows
flutter run -d windows
```

## Сборка для продакшена

```bash
# Web
flutter build web

# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios

# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## Структура проекта

```
PhotoChef/
├── lib/
│   ├── main.dart              # Точка входа
│   ├── screens/               # Экраны приложения
│   │   ├── home_screen.dart
│   │   ├── auth_screen.dart
│   │   ├── history_screen.dart
│   │   └── not_found_screen.dart
│   ├── services/              # Сервисы
│   │   ├── supabase_service.dart
│   │   ├── auth_service.dart
│   │   └── theme_service.dart
│   ├── widgets/               # Переиспользуемые виджеты
│   └── models/                # Модели данных
├── assets/                    # Ресурсы (изображения, шрифты)
├── android/                   # Android конфигурация
├── ios/                       # iOS конфигурация
├── web/                       # Web конфигурация
├── windows/                   # Windows конфигурация
├── linux/                     # Linux конфигурация
├── macos/                     # macOS конфигурация
└── pubspec.yaml              # Зависимости проекта
```

## Конфигурация

Создайте файл `.env` в корне проекта:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Разработка

### Hot Reload

Flutter поддерживает горячую перезагрузку:
- `r` - Hot reload
- `R` - Hot restart
- `q` - Выход

### DevTools

Откройте Flutter DevTools для отладки:
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

PhotoChef 2026
