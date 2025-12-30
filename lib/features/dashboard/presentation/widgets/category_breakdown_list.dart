import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';

/// Data model for category spending breakdown
class CategoryBreakdown {
  final String category;
  final double amount;
  final double percentage;
  final Color color;
  final IconData icon;

  const CategoryBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}

/// List showing category spending breakdown with percentages
class CategoryBreakdownList extends StatelessWidget {
  final List<CategoryBreakdown> categories;
  final void Function(String category)? onCategoryTap;

  const CategoryBreakdownList({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  /// German currency formatter
  static final _currencyFormat = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  /// Category icon mapping
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return Icons.shopping_basket;
      case 'beverages':
        return Icons.local_drink;
      case 'snacks':
        return Icons.cookie;
      case 'household':
        return Icons.home;
      case 'electronics':
        return Icons.devices;
      case 'fashion':
        return Icons.checkroom;
      case 'deposit':
        return Icons.recycling;
      default:
        return Icons.category;
    }
  }

  /// Category color mapping
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return const Color(AppColors.primaryTeal);
      case 'beverages':
        return const Color(0xFF3498DB);
      case 'snacks':
        return const Color(0xFF9B59B6);
      case 'household':
        return const Color(AppColors.warningOrange);
      case 'electronics':
        return const Color(0xFFE74C3C);
      case 'fashion':
        return const Color(0xFFE91E63);
      case 'deposit':
        return const Color(AppColors.successGreen);
      default:
        return const Color(AppColors.neutralGray);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return _buildEmptyState(context);
    }

    // Sort by percentage descending
    final sortedCategories = List<CategoryBreakdown>.from(categories)
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Kategorien',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        // Category list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: sortedCategories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final category = sortedCategories[index];
            return _CategoryTile(
              category: category,
              formattedAmount: _currencyFormat.format(category.amount),
              onTap: onCategoryTap != null
                  ? () => onCategoryTap!(category.category)
                  : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Keine Kategoriedaten verfügbar',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(AppColors.neutralGray),
              ),
        ),
      ),
    );
  }
}

/// Individual category tile
class _CategoryTile extends StatelessWidget {
  final CategoryBreakdown category;
  final String formattedAmount;
  final VoidCallback? onTap;

  const _CategoryTile({
    required this.category,
    required this.formattedAmount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: category.color.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // Percentage Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${category.percentage.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: category.color,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Category Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category.icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),

              // Category Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.category,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    // Progress bar
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: category.percentage / 100,
                        minHeight: 4,
                        backgroundColor: category.color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(category.color),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedAmount,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(AppColors.darkNavy),
                        ),
                  ),
                  if (onTap != null)
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Color(AppColors.neutralGray),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
