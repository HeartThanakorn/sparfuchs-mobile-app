import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';

/// Data model for category spending
class CategorySpending {
  final String category;
  final double amount;
  final Color color;

  const CategorySpending({
    required this.category,
    required this.amount,
    required this.color,
  });
}

/// Data model for monthly spending breakdown
class MonthlySpending {
  final DateTime month;
  final List<CategorySpending> categories;

  const MonthlySpending({required this.month, required this.categories});

  double get total => categories.fold(0, (sum, cat) => sum + cat.amount);
}

/// Stacked bar chart showing expenses by category
class ExpenseChart extends StatelessWidget {
  final List<MonthlySpending> data;
  final bool showLabels;

  const ExpenseChart({
    super.key,
    required this.data,
    this.showLabels = true,
  });

  /// Category color mapping based on design palette
  static const Map<String, Color> categoryColors = {
    'Groceries': Color(AppColors.primaryTeal), // #4ECDC4
    'Household': Color(AppColors.warningOrange), // #F39C12
    'Beverages': Color(0xFF3498DB), // Blue
    'Snacks': Color(0xFF9B59B6), // Purple
    'Electronics': Color(0xFFE74C3C), // Red
    'Fashion': Color(0xFFE91E63), // Pink
    'Deposit': Color(AppColors.successGreen), // #27AE60
    'Other': Color(AppColors.neutralGray), // #95A5A6
  };

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState(context);
    }

    final maxValue = _calculateMaxValue();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ausgaben nach Kategorie',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                // Legend toggle or info
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 20),
                  onPressed: () => _showLegendDialog(context),
                ),
              ],
            ),
          ),

          // Bar Chart
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxValue * 1.1, // 10% padding on top
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        const Color(AppColors.darkNavy).withValues(alpha: 0.9),
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final monthData = data[groupIndex];
                      return BarTooltipItem(
                        '${DateFormat('MMM', 'de_DE').format(monthData.month)}\n',
                        const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text:
                                NumberFormat.currency(locale: 'de_DE', symbol: '€').format(monthData.total),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: showLabels,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          '${value.toInt()}€',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(AppColors.neutralGray),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= data.length) {
                          return const SizedBox.shrink();
                        }
                        final month = data[value.toInt()].month;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MMM', 'de_DE').format(month),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(AppColors.darkNavy),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color:
                        const Color(AppColors.neutralGray).withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(),
              ),
            ),
          ),

          // Compact Legend
          const SizedBox(height: 16),
          _buildCompactLegend(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppColors.lightMint),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: const Color(AppColors.neutralGray).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Noch keine Ausgabendaten',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(AppColors.neutralGray),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxValue() {
    if (data.isEmpty) return 100;
    double maxTotal = 0;
    for (final month in data) {
      if (month.total > maxTotal) {
        maxTotal = month.total;
      }
    }
    return maxTotal > 0 ? maxTotal : 100;
  }

  List<BarChartGroupData> _buildBarGroups() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final monthData = entry.value;

      // Build stacked rods
      final stackedRods = <BarChartRodStackItem>[];
      double currentY = 0;

      for (final category in monthData.categories) {
        if (category.amount > 0) {
          stackedRods.add(BarChartRodStackItem(
            currentY,
            currentY + category.amount,
            category.color,
          ));
          currentY += category.amount;
        }
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: monthData.total,
            width: 24,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            rodStackItems: stackedRods,
          ),
        ],
      );
    }).toList();
  }

  Widget _buildCompactLegend(BuildContext context) {
    // Get unique categories from data
    final allCategories = <String>{};
    for (final month in data) {
      for (final cat in month.categories) {
        allCategories.add(cat.category);
      }
    }

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: allCategories.map((category) {
        final color = categoryColors[category] ?? const Color(AppColors.neutralGray);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              category,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(AppColors.darkNavy),
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showLegendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategorien'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: categoryColors.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: entry.value,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(entry.key),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
