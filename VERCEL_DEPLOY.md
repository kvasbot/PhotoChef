# Деплой PhotoChef на Vercel

## Шаги для деплоя:

1. **Установите Vercel CLI** (если еще не установлен):
```bash
npm i -g vercel
```

2. **Войдите в Vercel**:
```bash
vercel login
```

3. **Деплой проекта**:
```bash
vercel
```

При первом деплое Vercel спросит:
- Set up and deploy? → Yes
- Which scope? → Выберите ваш аккаунт
- Link to existing project? → No
- Project name? → photochef (или любое другое)
- In which directory is your code located? → ./

4. **Настройте переменные окружения в Vercel Dashboard**:

Перейдите в настройки проекта на vercel.com и добавьте:
- `VITE_SUPABASE_URL` = `https://yudejpwkbsvzpptfoboq.supabase.co`
- `VITE_SUPABASE_PUBLISHABLE_KEY` = `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl1ZGVqcHdrYnN2enBwdGZvYm9xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1ODMyNDUsImV4cCI6MjA4NDE1OTI0NX0.NocZ1Ig_SrhsNCEXhIULcba-UKoLWFehe1KZTjJstdA`

5. **Продакшн деплой**:
```bash
vercel --prod
```

## Важно:

- Flutter будет установлен автоматически при первой сборке (может занять 5-10 минут)
- Vercel работает в России
- После деплоя получите URL вида: `https://photochef.vercel.app`

## Альтернатива: деплой через GitHub

1. Запушьте код в GitHub
2. Подключите репозиторий в Vercel Dashboard
3. Vercel автоматически задеплоит при каждом push
