import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class ImageUploadWidget extends StatefulWidget {
  final Function(String recipes, String imageUrl) onImageAnalyzed;
  final Session? session;

  const ImageUploadWidget({
    super.key,
    required this.onImageAnalyzed,
    this.session,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  XFile? _previewImageFile;
  Uint8List? _previewImageBytes; // Для веб-платформы
  String? _imageDataUrl; // Сохраняем base64 данные изображения
  bool _isAnalyzing = false;
  final TextEditingController _commentsController = TextEditingController();
  bool _isVegan = false;
  bool _isLowCalorie = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      // Проверка размера файла (10MB)
      final bytes = await image.readAsBytes();
      if (bytes.length > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Размер файла не должен превышать 10MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Конвертация в base64
      final base64Image = base64Encode(bytes);
      final imageDataUrl = 'data:image/jpeg;base64,$base64Image';

      // Создание preview и сохранение данных
      setState(() {
        _previewImageFile = image;
        _previewImageBytes = bytes; // Сохраняем байты для веб
        _imageDataUrl = imageDataUrl; // Сохраняем base64 данные
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageDataUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, сначала загрузите изображение'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final supabaseService = SupabaseService();
      final recipes = await supabaseService.analyzeRecipe(
        imageBase64: _imageDataUrl!,
        comments: _commentsController.text.isEmpty
            ? null
            : _commentsController.text,
        isVegan: _isVegan,
        isLowCalorie: _isLowCalorie,
      );

      if (mounted) {
        widget.onImageAnalyzed(recipes, _imageDataUrl!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Рецепты успешно сгенерированы!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Очищаем форму после успешной отправки
        setState(() {
          _previewImageFile = null;
          _previewImageBytes = null;
          _imageDataUrl = null;
          _commentsController.clear();
          _isVegan = false;
          _isLowCalorie = false;
        });
      }
    } catch (e) {
      // Извлекаем понятное сообщение об ошибке
      String errorMessage = 'Не удалось проанализировать изображение';
      bool isServerOverloaded = false;

      if (e is Exception) {
        final errorString = e.toString();

        // Проверяем на ошибку перегрузки сервера (503)
        if (errorString.contains('503') ||
            errorString.contains('high demand') ||
            errorString.contains('UNAVAILABLE')) {
          errorMessage = 'Сервер AI перегружен. Попробуйте через минуту';
          isServerOverloaded = true;
        }
        // Убираем префикс "Exception: " если есть
        else if (errorString.startsWith('Exception: ')) {
          errorMessage = errorString.substring(11);
        } else if (errorString.startsWith('Exception:')) {
          errorMessage = errorString.substring(10).trim();
        } else {
          errorMessage = errorString;
        }
      } else {
        errorMessage = e.toString();
      }

      // Логируем ошибку для отладки
      print('❌ Ошибка анализа изображения: $errorMessage');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(fontSize: 14),
            ),
            backgroundColor: isServerOverloaded ? Colors.orange : Colors.red,
            duration: Duration(seconds: isServerOverloaded ? 7 : 5),
            action: SnackBarAction(
              label: isServerOverloaded ? 'Повторить' : 'OK',
              textColor: Colors.white,
              onPressed: isServerOverloaded ? _analyzeImage : () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
      return Column(
      children: [
        // Preview изображения
        if (_previewImageFile != null)
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb && _previewImageBytes != null
                      ? Image.memory(
                          _previewImageBytes!,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.contain,
                        )
                      : Image.file(
                          File(_previewImageFile!.path),
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                ),
                if (_isAnalyzing)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Анализируем ваши продукты...'),
                        ],
                      ),
                    ),
                  ),
                if (!_isAnalyzing)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(8),
                      ),
                      onPressed: () {
                        setState(() {
                          _previewImageFile = null;
                          _previewImageBytes = null;
                          _imageDataUrl = null;
                          _commentsController.clear();
                          _isVegan = false;
                          _isLowCalorie = false;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),

        // Форма с комментариями, кнопкой отправки и фильтрами (показывается только когда есть превью)
        if (_previewImageFile != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Дополнительные пожелания',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentsController,
                    maxLines: 4,
                    enabled: !_isAnalyzing,
                    decoration: InputDecoration(
                      hintText:
                          'Например: без молочных продуктов, быстрое приготовление, острые блюда...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Кнопка отправки
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(_isAnalyzing ? 'Анализируем...' : 'Отправить'),
                      onPressed: _isAnalyzing || _imageDataUrl == null
                          ? null
                          : _analyzeImage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Предпочтения',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilterChip(
                          label: const Text('🌱 Для веганов'),
                          selected: _isVegan,
                          onSelected: _isAnalyzing
                              ? null
                              : (value) => setState(() => _isVegan = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilterChip(
                          label: const Text('🔥 Низкокалорийное'),
                          selected: _isLowCalorie,
                          onSelected: _isAnalyzing
                              ? null
                              : (value) =>
                                  setState(() => _isLowCalorie = value),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 24),

        // Кнопки загрузки (показываются только когда нет превью)
        if (_previewImageFile == null)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text('Загрузить фото'),
                  onPressed: _isAnalyzing
                      ? null
                      : () => _pickImage(ImageSource.gallery),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Сделать фото'),
                  onPressed: _isAnalyzing
                      ? null
                      : () => _pickImage(ImageSource.camera),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),

        if (widget.session == null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '💡 Войдите, чтобы сохранять рецепты в историю',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),
        Text(
          'Загрузите фото вашего холодильника или продуктов, и мы предложим вам подходящие рецепты',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

