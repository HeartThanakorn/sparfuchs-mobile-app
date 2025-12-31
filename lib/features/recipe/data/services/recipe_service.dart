import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Model for a recipe suggestion
class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> matchedIngredients;
  final int prepTimeMinutes;
  final int servings;
  final String? imageUrl;
  final String? sourceUrl;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.matchedIngredients,
    required this.prepTimeMinutes,
    required this.servings,
    this.imageUrl,
    this.sourceUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)?.cast<String>() ?? [],
      matchedIngredients:
          (json['matchedIngredients'] as List<dynamic>?)?.cast<String>() ?? [],
      prepTimeMinutes: json['prepTimeMinutes'] as int? ?? 0,
      servings: json['servings'] as int? ?? 4,
      imageUrl: json['imageUrl'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
    );
  }

  /// Match percentage for UI display
  double get matchPercentage {
    if (ingredients.isEmpty) return 0;
    return (matchedIngredients.length / ingredients.length) * 100;
  }
}

/// Service for suggesting recipes based on purchased items
class RecipeService {
  final http.Client _client;
  final String _baseUrl;

  static const _timeout = Duration(seconds: 15);
  static const _maxSuggestions = 3;

  /// Food categories to filter for recipe matching
  static const _foodCategories = [
    'groceries',
    'produce',
    'dairy',
    'meat',
    'bakery',
    'frozen',
    'beverages',
    'snacks',
  ];

  RecipeService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'https://your-vps.hostinger.com';

  /// Suggests recipes based on purchased items
  /// 
  /// Filters for food items, calls the recipe API, and returns
  /// up to 3 recipes sorted by ingredient match count (descending)
  Future<List<Recipe>> suggestRecipes(List<LineItem> items) async {
    try {
      // 1. Filter to food items only
      final foodItems = _filterFoodItems(items);
      if (foodItems.isEmpty) {
        debugPrint('RecipeService: No food items found');
        return [];
      }

      // 2. Extract ingredient names
      final ingredients = foodItems.map((i) => i.description).toList();
      debugPrint('RecipeService: Suggesting with ${ingredients.length} ingredients');

      // 3. Call recipe API
      final recipes = await _callRecipeApi(ingredients);

      // 4. Sort by matched ingredients (most matches first)
      recipes.sort((a, b) =>
          b.matchedIngredients.length.compareTo(a.matchedIngredients.length));

      // 5. Return top 3
      return recipes.take(_maxSuggestions).toList();
    } catch (e) {
      debugPrint('RecipeService.suggestRecipes error: $e');
      rethrow;
    }
  }

  /// Filters items to only food categories
  List<LineItem> _filterFoodItems(List<LineItem> items) {
    return items
        .where((item) =>
            _foodCategories.contains(item.category.toLowerCase()) &&
            !item.isPfand)
        .toList();
  }

  /// Calls the n8n recipe suggestion webhook
  Future<List<Recipe>> _callRecipeApi(List<String> ingredients) async {
    final uri = Uri.parse('$_baseUrl/webhook/suggest-recipes');

    try {
      debugPrint('RecipeService: POST to $uri');

      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'ingredients': ingredients}),
          )
          .timeout(_timeout);

      debugPrint('RecipeService: Response ${response.statusCode}');

      if (response.statusCode != 200) {
        throw RecipeServiceException(
          'API Fehler: ${response.statusCode}',
          code: 'api_error',
        );
      }

      final json = jsonDecode(response.body);

      if (json is! Map<String, dynamic>) {
        throw RecipeServiceException(
          'Ungültige API-Antwort',
          code: 'invalid_response',
        );
      }

      final recipesJson = json['recipes'] as List<dynamic>?;
      if (recipesJson == null) {
        return [];
      }

      return recipesJson
          .map((r) => Recipe.fromJson(r as Map<String, dynamic>))
          .toList();
    } on http.ClientException catch (e) {
      throw RecipeServiceException(
        'Netzwerkfehler: ${e.message}',
        code: 'network_error',
      );
    }
  }

  /// Close HTTP client
  void dispose() {
    _client.close();
  }
}

/// Exception for recipe service errors
class RecipeServiceException implements Exception {
  final String message;
  final String? code;

  RecipeServiceException(this.message, {this.code});

  @override
  String toString() => 'RecipeServiceException: $message (code: $code)';
}
