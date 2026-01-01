import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/constants/app_formatters.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/receipt/data/providers/receipt_providers.dart';
import 'package:sparfuchs_ai/shared/theme/app_theme.dart';

/// Category Analysis Screen showing spending breakdown by category
class CategoryAnalysisScreen extends ConsumerStatefulWidget {
  const CategoryAnalysisScreen({super.key});

  @override
  ConsumerState<CategoryAnalysisScreen> createState() => _CategoryAnalysisScreenState();
}

class _CategoryAnalysisScreenState extends ConsumerState<CategoryAnalysisScreen> {
  @override
  Widget build(BuildContext context) {
    final receiptsAsync = ref.watch(receiptsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Category Analysis'),
        centerTitle: true,
        backgroundColor: const Color(AppColors.primaryTeal),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: receiptsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (receipts) {
          final categoryTotals = _calculateCategoryTotals(receipts);
          final totalSpending = categoryTotals.values.fold(0.0, (a, b) => a + b);

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                
                // Pie Chart
                _buildPieChart(categoryTotals, totalSpending),
                
                const SizedBox(height: 32),
                
                // Category Legend with percentages
                _buildCategoryLegend(categoryTotals, totalSpending),
                
                const SizedBox(height: 24),
                
                // Detailed Category Cards
                _buildCategoryCards(categoryTotals, totalSpending),
                
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> categoryTotals, double total) {
    if (categoryTotals.isEmpty || total == 0) {
      return Container(
        height: 250,
        child: const Center(
          child: Text('No spending data available'),
        ),
      );
    }

    final sections = categoryTotals.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final color = AppTheme.categoryColors[entry.key] ?? Colors.grey;
      
      return PieChartSectionData(
        value: entry.value,
        color: color,
        radius: 80,
        title: percentage >= 5 ? '${percentage.round()}%' : '',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 60,
              sectionsSpace: 2,
            ),
          ),
          // Center total
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(AppColors.neutralGray),
                ),
              ),
              Text(
                AppFormatters.currency.format(total),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.darkNavy),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLegend(Map<String, double> categoryTotals, double total) {
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: sortedCategories.map((entry) {
          final color = AppTheme.categoryColors[entry.key] ?? Colors.grey;
          final percentage = total > 0 ? (entry.value / total * 100).round() : 0;
          
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$percentage% ${entry.key}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(AppColors.darkNavy),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryCards(Map<String, double> categoryTotals, double total) {
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.darkNavy),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...sortedCategories.map((entry) {
          final color = AppTheme.categoryColors[entry.key] ?? Colors.grey;
          final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(AppColors.darkNavy),
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}% of total spending',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          AppFormatters.currency.format(entry.value),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.darkNavy),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }



  Map<String, double> _calculateCategoryTotals(List<Receipt> receipts) {
    final Map<String, double> totals = {};
    
    for (final receipt in receipts) {
      for (final item in receipt.receiptData.items) {
        if (!item.isPfand) {
          final category = item.category;
          totals[category] = (totals[category] ?? 0) + item.totalPrice;
        }
      }
    }
    
    return totals;
  }
}
