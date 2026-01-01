import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';

/// Screen showing detailed price history and merchant comparison for a product
class ProductDetailScreen extends StatefulWidget {
  final String productName;
  final String currentPrice;
  final double changePercentage;

  const ProductDetailScreen({
    super.key,
    required this.productName,
    required this.currentPrice,
    required this.changePercentage,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '€',
  );
  
  static final _dateFormat = DateFormat('dd.MM', 'en_US');

  // TODO: Replace with real data
  final List<_PricePoint> _priceHistory = [
    _PricePoint(DateTime(2024, 10, 1), 2.29),
    _PricePoint(DateTime(2024, 10, 15), 2.49),
    _PricePoint(DateTime(2024, 11, 1), 2.49),
    _PricePoint(DateTime(2024, 11, 20), 2.89),
    _PricePoint(DateTime(2024, 12, 1), 3.19),
    _PricePoint(DateTime(2024, 12, 25), 3.19),
  ];

  final List<_MerchantPrice> _merchantPrices = [
    _MerchantPrice('Aldi Süd', 3.19, false),
    _MerchantPrice('REWE', 3.49, false),
    _MerchantPrice('Kaufland', 2.99, true), // Cheapest
    _MerchantPrice('Edeka', 3.29, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preisverlauf'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            
            // Chart Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Preisentwicklung (90 Tage)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            _buildPriceChart(context),
            const SizedBox(height: 32),

            // Merchant List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Merchant Comparison',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            _buildMerchantList(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isIncrease = widget.changePercentage > 0;
    final color = isIncrease
        ? const Color(AppColors.errorRed)
        : const Color(AppColors.successGreen);
    final icon = isIncrease ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(AppColors.lightMint),
            child: Text(
              widget.productName[0],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.primaryTeal),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.productName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.currentPrice, // Already formatted
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(AppColors.darkNavy),
                    ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.changePercentage.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChart(BuildContext context) {
    final minPrice = _priceHistory
        .map((e) => e.price)
        .reduce((curr, next) => curr < next ? curr : next);
    final maxPrice = _priceHistory
        .map((e) => e.price)
        .reduce((curr, next) => curr > next ? curr : next);

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(right: 24, left: 12),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 0.5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: const Color(AppColors.neutralGray).withValues(alpha: 0.2),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1, // Logic to specific interval handled in getTitlesWidget
                  getTitlesWidget: (value, meta) {
                    // Show date for first, middle, last points
                    final index = value.toInt();
                    if (index < 0 || index >= _priceHistory.length) {
                      return const SizedBox.shrink();
                    }
                    
                    // Simple logic: show first and last, and some in between
                    if (index == 0 ||
                        index == _priceHistory.length - 1 ||
                        index % 2 == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _dateFormat.format(_priceHistory[index].date),
                          style: const TextStyle(
                            color: Color(AppColors.neutralGray),
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 0.5,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '€${value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(AppColors.neutralGray),
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (_priceHistory.length - 1).toDouble(),
            minY: (minPrice * 0.8).floorToDouble(), // Dynamic Y range
            maxY: (maxPrice * 1.1).ceilToDouble(),
            lineBarsData: [
              LineChartBarData(
                spots: _priceHistory
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.price))
                    .toList(),
                isCurved: true,
                color: const Color(AppColors.primaryTeal),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(AppColors.primaryTeal).withValues(alpha: 0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipColor: (_) => Colors.black87,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final date = _priceHistory[spot.x.toInt()].date;
                    return LineTooltipItem(
                      '${_dateFormat.format(date)}\n',
                      const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      children: [
                        TextSpan(
                          text: _currencyFormat.format(spot.y),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantList(BuildContext context) {
    // Sort so cheapest is first? Or keep logical ordering?
    // Let's sort by price ascending.
    final sortedMerchants = List<_MerchantPrice>.from(_merchantPrices)
      ..sort((a, b) => a.price.compareTo(b.price));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedMerchants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final merchant = sortedMerchants[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: merchant.isCheapest
                  ? const Color(AppColors.successGreen)
                  : const Color(AppColors.neutralGray).withValues(alpha: 0.2),
              width: merchant.isCheapest ? 1.5 : 1,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(AppColors.lightMint),
              child: Text(
                merchant.name[0],
                style: const TextStyle(
                  color: Color(AppColors.primaryTeal),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              merchant.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (merchant.isCheapest)
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.successGreen),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Bestpreis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  _currencyFormat.format(merchant.price),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: merchant.isCheapest
                        ? const Color(AppColors.successGreen)
                        : const Color(AppColors.darkNavy),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PricePoint {
  final DateTime date;
  final double price;
  _PricePoint(this.date, this.price);
}

class _MerchantPrice {
  final String name;
  final double price;
  final bool isCheapest;
  _MerchantPrice(this.name, this.price, this.isCheapest);
}
