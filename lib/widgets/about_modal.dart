import 'package:flutter/material.dart';

class AboutModal extends StatelessWidget {
  final VoidCallback onClose;

  const AboutModal({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'О проекте PhotoChef',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'PhotoChef - это инновационное приложение, которое использует искусственный интеллект для анализа фотографий продуктов и предложения персонализированных рецептов.',
              style: TextStyle(height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Наша миссия:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Помочь людям готовить вкусную и здоровую пищу из того, что есть под рукой, сокращая пищевые отходы и экономя время на планирование меню.',
              style: TextStyle(height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Возможности:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BulletPoint('Анализ фотографий продуктов с помощью AI'),
                _BulletPoint('Персональные рекомендации рецептов'),
                _BulletPoint('Фильтры для веганских и низкокалорийных блюд'),
                _BulletPoint('Чат с AI шеф-поваром для корректировки рецептов'),
                _BulletPoint('Сохранение любимых рецептов в истории'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Создано с использованием современных технологий AI для лучшего кулинарного опыта.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onClose,
                child: const Text('Закрыть'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}



























