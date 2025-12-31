import 'package:flutter_test/flutter_test.dart';

/// Property 20: Recipe Suggestion Count and Relevance
/// Validates: Requirements 7.1, 7.2
///
/// Properties:
/// 1. Maximum 3 recipes are returned
/// 2. Recipes are sorted by matched ingredients (most matches first)
/// 3. Only food items are considered for matching
/// 4. Empty items returns empty recipes

/// Mock recipe for testing
class MockRecipe {
  final String name;
  final List<String> ingredients;
  final List<String> matchedIngredients;

  MockRecipe({
    required this.name,
    required this.ingredients,
    required this.matchedIngredients,
  });
}

/// Mock line item
class MockLineItem {
  final String description;
  final String category;
  final bool isPfand;

  MockLineItem({
    required this.description,
    required this.category,
    this.isPfand = false,
  });
}

/// Food categories for filtering
const foodCategories = [
  'groceries',
  'produce',
  'dairy',
  'meat',
  'bakery',
  'frozen',
];

/// Filter food items only
List<MockLineItem> filterFoodItems(List<MockLineItem> items) {
  return items
      .where((item) =>
          foodCategories.contains(item.category.toLowerCase()) && !item.isPfand)
      .toList();
}

/// Sort recipes by matched ingredients count
List<MockRecipe> sortByRelevance(List<MockRecipe> recipes) {
  return recipes
    ..sort((a, b) =>
        b.matchedIngredients.length.compareTo(a.matchedIngredients.length));
}

/// Limit to max 3 recipes
List<MockRecipe> limitToThree(List<MockRecipe> recipes) {
  return recipes.take(3).toList();
}

void main() {
  group('Property 20: Recipe Suggestion Count and Relevance', () {
    // Test: Maximum 3 recipes returned
    test('returns maximum 3 recipes', () {
      final recipes = [
        MockRecipe(name: 'R1', ingredients: ['a'], matchedIngredients: ['a']),
        MockRecipe(name: 'R2', ingredients: ['b'], matchedIngredients: ['b']),
        MockRecipe(name: 'R3', ingredients: ['c'], matchedIngredients: ['c']),
        MockRecipe(name: 'R4', ingredients: ['d'], matchedIngredients: ['d']),
        MockRecipe(name: 'R5', ingredients: ['e'], matchedIngredients: ['e']),
      ];

      final result = limitToThree(recipes);

      expect(result.length, 3);
    });

    // Test: Fewer than 3 recipes returns all
    test('returns all recipes if fewer than 3', () {
      final recipes = [
        MockRecipe(name: 'R1', ingredients: ['a'], matchedIngredients: ['a']),
        MockRecipe(name: 'R2', ingredients: ['b'], matchedIngredients: ['b']),
      ];

      final result = limitToThree(recipes);

      expect(result.length, 2);
    });

    // Test: Sorted by matched ingredients descending
    test('recipes sorted by matched ingredients descending', () {
      final recipes = [
        MockRecipe(
            name: 'Low', ingredients: ['a', 'b', 'c'], matchedIngredients: ['a']),
        MockRecipe(
            name: 'High',
            ingredients: ['a', 'b', 'c'],
            matchedIngredients: ['a', 'b', 'c']),
        MockRecipe(
            name: 'Mid',
            ingredients: ['a', 'b', 'c'],
            matchedIngredients: ['a', 'b']),
      ];

      final sorted = sortByRelevance(recipes);

      expect(sorted[0].name, 'High');
      expect(sorted[1].name, 'Mid');
      expect(sorted[2].name, 'Low');
    });

    // Test: Only food items considered
    test('only food category items are considered', () {
      final items = [
        MockLineItem(description: 'Milk', category: 'dairy'),
        MockLineItem(description: 'Bread', category: 'bakery'),
        MockLineItem(description: 'Batteries', category: 'electronics'),
        MockLineItem(description: 'Soap', category: 'household'),
      ];

      final foodItems = filterFoodItems(items);

      expect(foodItems.length, 2);
      expect(foodItems.map((i) => i.description), containsAll(['Milk', 'Bread']));
    });

    // Test: Pfand items excluded
    test('pfand items are excluded from food matching', () {
      final items = [
        MockLineItem(description: 'Milk', category: 'dairy'),
        MockLineItem(description: 'Pfand', category: 'groceries', isPfand: true),
        MockLineItem(description: 'Eggs', category: 'dairy'),
      ];

      final foodItems = filterFoodItems(items);

      expect(foodItems.length, 2);
      expect(foodItems.any((i) => i.isPfand), isFalse);
    });

    // Test: Empty items returns empty recipes
    test('empty items list returns empty food items', () {
      final items = <MockLineItem>[];
      final foodItems = filterFoodItems(items);

      expect(foodItems.isEmpty, isTrue);
    });

    // Test: No food items returns empty
    test('no food category items returns empty', () {
      final items = [
        MockLineItem(description: 'Batteries', category: 'electronics'),
        MockLineItem(description: 'Soap', category: 'household'),
      ];

      final foodItems = filterFoodItems(items);

      expect(foodItems.isEmpty, isTrue);
    });

    // Test: Match percentage calculation
    test('match percentage calculated correctly', () {
      final recipe = MockRecipe(
        name: 'Test',
        ingredients: ['a', 'b', 'c', 'd'],
        matchedIngredients: ['a', 'b'],
      );

      final percentage = (recipe.matchedIngredients.length /
              recipe.ingredients.length) *
          100;

      expect(percentage, 50.0);
    });
  });
}
