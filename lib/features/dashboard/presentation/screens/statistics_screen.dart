import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/core/services/local_database_service.dart';
import 'package:sparfuchs_ai/features/inflation/presentation/screens/category_analysis_screen.dart';

/// Statistics Screen with charts and category breakdown
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  int _selectedPeriodIndex = 2; // 0=Days, 1=Weeks, 2=Months
  final List<String> _periods = ['Days', 'Weeks', 'Months'];

  static final _currencyFormat = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  // Category colors
  static const _categoryColors = {
    'Groceries': Color(0xFF8B5CF6),     // Purple
    'Household': Color(0xFFEC4899),     // Pink
    'Beverages': Color(0xFF06B6D4),     // Cyan
    'Housing & living': Color(0xFF10B981), // Green
    'Electronics': Color(0xFF3B82F6),   // Blue
    'Fashion': Color(0xFFF59E0B),       // Amber
    'Mobility': Color(0xFF6366F1),      // Indigo
    'Snacks': Color(0xFFEF4444),        // Red
    'Other': Color(0xFF6B7280),         // Gray
  };

  @override
  Widget build(BuildContext context) {
    final receipts = _loadReceiptsFromHive();
    final categoryTotals = _calculateCategoryTotals(receipts);
    final totalSpending = categoryTotals.values.fold(0.0, (a, b) => a + b);
    final monthlyData = _calculateMonthlyData(receipts);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('All Categories'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(AppColors.darkNavy),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Period Tabs
            _buildPeriodTabs(),
            
            const SizedBox(height: 16),
            
            // Bar Chart
            _buildBarChart(monthlyData),
            
            const SizedBox(height: 24),
            
            // Date & Total Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd.MM.yyyy', 'de_DE').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(AppColors.darkNavy),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _currencyFormat.format(totalSpending),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.darkNavy),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.info_outline, size: 18, color: Colors.grey.shade400),
                    ],
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
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_periods.length, (index) {
          final isSelected = index == _selectedPeriodIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedPeriodIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(AppColors.darkNavy) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _periods[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          );
        }),
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
                    '${value.toInt()}',
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
        final color = _categoryColors[entry.key] ?? Colors.grey;
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
        final color = _categoryColors[entry.key] ?? Colors.grey;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
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
              ],
            ),
            title: Text(
              entry.key,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(AppColors.darkNavy),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currencyFormat.format(entry.value),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(AppColors.darkNavy),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: () => _onCategoryTap(entry.key),
          ),
        );
      }).toList(),
    );
  }

  List<Receipt> _loadReceiptsFromHive() {
    try {
      final box = LocalDatabaseService.receiptsBox;
      final receipts = <Receipt>[];
      
      for (final key in box.keys) {
        try {
          final rawData = box.get(key);
          if (rawData != null) {
            final data = _deepCopyMap(rawData as Map);
            data['receiptId'] = key.toString();
            receipts.add(Receipt.fromJson(data));
          }
        } catch (e) {
          debugPrint('Error parsing receipt $key: $e');
        }
      }
      
      return receipts;
    } catch (e) {
      debugPrint('Error loading receipts: $e');
      return [];
    }
  }

  Map<String, dynamic> _deepCopyMap(Map original) {
    final result = <String, dynamic>{};
    for (final entry in original.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is Map) {
        result[key] = _deepCopyMap(value);
      } else if (value is List) {
        result[key] = _deepCopyList(value);
      } else {
        result[key] = value;
      }
    }
    return result;
  }

  List<dynamic> _deepCopyList(List original) {
    return original.map((item) {
      if (item is Map) {
        return _deepCopyMap(item);
      } else if (item is List) {
        return _deepCopyList(item);
      } else {
        return item;
      }
    }).toList();
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

  void _onCategoryTap(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoryAnalysisScreen()),
    );
  }
}
