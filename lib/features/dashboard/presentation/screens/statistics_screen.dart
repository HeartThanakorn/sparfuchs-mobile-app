import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/constants/app_formatters.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/receipt/data/providers/receipt_providers.dart';
import 'package:sparfuchs_ai/features/inflation/presentation/screens/category_analysis_screen.dart';
import 'package:sparfuchs_ai/shared/theme/app_theme.dart';

/// Statistics Screen - Simplified with functional elements only
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final receiptsAsync = ref.watch(receiptsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Statistics'),
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
          final monthlyData = _calculateMonthlyData(receipts);

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                
                // Bar Chart
                _buildBarChart(monthlyData),
                
                const SizedBox(height: 24),
                
                // Total Spending Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Spending',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.darkNavy),
                        ),
                      ),
                      Text(
                        AppFormatters.currency.format(totalSpending),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.primaryTeal),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Category List
                _buildCategoryList(categoryTotals, totalSpending),
                
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBarChart(Map<String, Map<String, double>> monthlyData) {
    final months = monthlyData.keys.toList();
    
    if (months.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No data available', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(monthlyData),
          barGroups: _createBarGroups(monthlyData),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        months[value.toInt()],
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '€${value.toInt()}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 50,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  AppFormatters.currency.format(rod.toY),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(Map<String, Map<String, double>> monthlyData) {
    final months = monthlyData.keys.toList();
    final List<BarChartGroupData> groups = [];

    for (int i = 0; i < months.length; i++) {
      final categoryData = monthlyData[months[i]]!;
      final List<BarChartRodStackItem> stackItems = [];
      double currentY = 0;

      for (final entry in categoryData.entries) {
        final color = AppTheme.categoryColors[entry.key] ?? Colors.grey;
        stackItems.add(BarChartRodStackItem(
          currentY,
          currentY + entry.value,
          color,
        ));
        currentY += entry.value;
      }

      groups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: currentY,
            width: 24,
            rodStackItems: stackItems,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ));
    }

    return groups;
  }

  double _getMaxY(Map<String, Map<String, double>> monthlyData) {
    double max = 0;
    for (final categories in monthlyData.values) {
      final total = categories.values.fold(0.0, (a, b) => a + b);
      if (total > max) max = total;
    }
    return (max * 1.2).ceilToDouble(); // Add 20% headroom
  }

  Widget _buildCategoryList(Map<String, double> categoryTotals, double totalSpending) {
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedCategories.map((entry) {
        final percentage = totalSpending > 0 
            ? (entry.value / totalSpending * 100).round()
            : 0;
        final color = AppTheme.categoryColors[entry.key] ?? Colors.grey;

        return InkWell(
          onTap: () => _navigateToPieChart(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
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
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(AppColors.darkNavy),
                      ),
                    ),
                  ),
                  Text(
                    AppFormatters.currency.format(entry.value),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(AppColors.darkNavy),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Color(AppColors.neutralGray)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToPieChart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoryAnalysisScreen()),
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

  Map<String, Map<String, double>> _calculateMonthlyData(List<Receipt> receipts) {
    final Map<String, Map<String, double>> monthlyData = {};
    final dateFormat = DateFormat('MMM', 'en');

    for (final receipt in receipts) {
      DateTime? date;
      try {
        date = DateFormat('yyyy-MM-dd').parse(receipt.receiptData.transaction.date);
      } catch (_) {
        continue;
      }

      final monthKey = dateFormat.format(date);
      monthlyData.putIfAbsent(monthKey, () => {});

      for (final item in receipt.receiptData.items) {
        if (!item.isPfand) {
          final category = item.category;
          monthlyData[monthKey]![category] = 
              (monthlyData[monthKey]![category] ?? 0) + item.totalPrice;
        }
      }
    }

    // Sort by date
    final sortedKeys = monthlyData.keys.toList()..sort();
    final sorted = <String, Map<String, double>>{};
    for (final key in sortedKeys.take(6)) { // Last 6 months
      sorted[key] = monthlyData[key]!;
    }

    return sorted;
  }
}
