class RecipeModel {
  final String id;
  final String userId;
  final String? imageUrl;
  final String recipesText;
  final DateTime? createdAt;

  RecipeModel({
    required this.id,
    required this.userId,
    this.imageUrl,
    required this.recipesText,
    this.createdAt,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String?,
      recipesText: json['recipes_text'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'recipes_text': recipesText,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}



























