import 'package:flutter/material.dart';
import 'package:sparfuchs_ai/features/recipe/data/services/recipe_service.dart';
import 'package:sparfuchs_ai/shared/theme/app_theme.dart';

/// Bottom sheet showing recipe suggestions after receipt save
class RecipeSuggestionsBottomSheet extends StatelessWidget {
  final List<Recipe> recipes;
  final VoidCallback? onDismiss;

  const RecipeSuggestionsBottomSheet({
    super.key,
    required this.recipes,
    this.onDismiss,
  });

  /// Shows the bottom sheet
  static Future<void> show(BuildContext context, List<Recipe> recipes) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RecipeSuggestionsBottomSheet(recipes: recipes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: AppTheme.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'Rezeptvorschläge',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Basierend auf deinem Einkauf',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 16),

          // Recipe cards
          if (recipes.isEmpty)
            _buildEmptyState(context)
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: recipes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _RecipeCard(
                  recipe: recipes[index],
                  onTap: () => _openRecipe(context, recipes[index]),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Dismiss button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Später anzeigen'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.no_food, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Keine Rezepte gefunden',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Kaufe mehr Lebensmittel für Rezeptvorschläge',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openRecipe(BuildContext context, Recipe recipe) {
    if (recipe.sourceUrl != null) {
      // TODO: Open recipe URL
      Navigator.pop(context);
    }
  }
}

/// Individual recipe card widget
class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const _RecipeCard({
    required this.recipe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (recipe.imageUrl != null)
              Image.network(
                recipe.imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
              )
            else
              _buildPlaceholderImage(),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe name
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Matched ingredients
                  if (recipe.matchedIngredients.isNotEmpty) ...[
                    Text(
                      'Verwendet: ${recipe.matchedIngredients.take(3).join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Badges row
                  Row(
                    children: [
                      _buildBadge(
                        context,
                        Icons.access_time,
                        '${recipe.prepTimeMinutes} Min',
                      ),
                      const SizedBox(width: 12),
                      _buildBadge(
                        context,
                        Icons.people,
                        '${recipe.servings} Portionen',
                      ),
                      const Spacer(),
                      // Match percentage
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${recipe.matchPercentage.toStringAsFixed(0)}% Match',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.primaryTeal,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 120,
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 40,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}
