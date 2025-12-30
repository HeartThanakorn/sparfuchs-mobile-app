import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';

/// Screen for tracking product price changes/inflation
class InflationTrackerScreen extends ConsumerStatefulWidget {
  const InflationTrackerScreen({super.key});

  @override
  ConsumerState<InflationTrackerScreen> createState() =>
      _InflationTrackerScreenState();
}

class _InflationTrackerScreenState
    extends ConsumerState<InflationTrackerScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // TODO: Replace with actual data from repository
  final List<_MockProductTrend> _trendingProducts = [
    _MockProductTrend(
      name: 'Kerrygold Butter',
      currentPrice: 3.19,
      previousPrice: 2.29,
      changePercentage: 39.3,
      store: 'REWE',
    ),
    _MockProductTrend(
      name: 'Barilla Pasta',
      currentPrice: 1.89,
      previousPrice: 1.39,
      changePercentage: 35.9,
      store: 'Edeka',
    ),
    _MockProductTrend(
      name: 'Bio Milch 3.8%',
      currentPrice: 1.45,
      previousPrice: 1.15,
      changePercentage: 26.1,
      store: 'Aldi',
    ),
  ];

  final List<_MockProductTrend> _trackedProducts = [
    _MockProductTrend(
      name: 'Coca Cola 1.5L',
      currentPrice: 1.79,
      previousPrice: 1.79,
      changePercentage: 0.0,
      store: 'Lidl',
    ),
    _MockProductTrend(
      name: 'Nutella 450g',
      currentPrice: 2.99,
      previousPrice: 3.29,
      changePercentage: -9.1,
      store: 'REWE',
    ),
     _MockProductTrend(
      name: 'H-Milch 1.5%',
      currentPrice: 0.99,
      previousPrice: 0.95,
      changePercentage: 4.2,
      store: 'Aldi',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inflations-Tracker'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Produkt suchen...',
                leading: const Icon(Icons.search, color: Color(AppColors.neutralGray)),
                elevation: WidgetStateProperty.all(1),
                backgroundColor: WidgetStateProperty.all(Colors.white),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16),
                ),
                onSubmitted: (query) {
                  // TODO: Implement search
                },
              ),
            ),
          ),

          // Trending Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, color: Color(AppColors.errorRed)),
                  const SizedBox(width: 8),
                  Text(
                    'Starker Preisanstieg (>10%)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Trending List (Horizontal)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _trendingProducts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _TrendingProductCard(product: _trendingProducts[index]);
                },
              ),
            ),
          ),

          // Tracked Products Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Deine Produkte',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),

          // Tracked Products List (Vertical)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _TrackedProductTile(product: _trackedProducts[index]);
              },
              childCount: _trackedProducts.length,
            ),
          ),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

/// Mock model for UI development
class _MockProductTrend {
  final String name;
  final double currentPrice;
  final double previousPrice;
  final double changePercentage;
  final String store;

  _MockProductTrend({
    required this.name,
    required this.currentPrice,
    required this.previousPrice,
    required this.changePercentage,
    required this.store,
  });
}

/// Card for highly trending items
class _TrendingProductCard extends StatelessWidget {
  final _MockProductTrend product;

  const _TrendingProductCard({required this.product});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(AppColors.errorRed).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Percentage Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(AppColors.errorRed).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_upward,
                  size: 12,
                  color: Color(AppColors.errorRed),
                ),
                const SizedBox(width: 4),
                Text(
                  '+${product.changePercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(AppColors.errorRed),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Product Name
          Text(
            product.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Price
          Text(
            _currencyFormat.format(product.currentPrice),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(AppColors.darkNavy),
                ),
          ),
          const SizedBox(height: 2),
          // Store
          Text(
            product.store,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(AppColors.neutralGray),
                ),
          ),
        ],
      ),
    );
  }
}

/// Tile for standard tracked products list
class _TrackedProductTile extends StatelessWidget {
  final _MockProductTrend product;

  const _TrackedProductTile({required this.product});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
  );

  Color get _trendColor {
    if (product.changePercentage > 0) return const Color(AppColors.errorRed);
    if (product.changePercentage < 0) return const Color(AppColors.successGreen);
    return const Color(AppColors.neutralGray);
  }

  IconData get _trendIcon {
    if (product.changePercentage > 0) return Icons.arrow_upward;
    if (product.changePercentage < 0) return Icons.arrow_downward;
    return Icons.remove;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(AppColors.neutralGray).withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(AppColors.lightMint),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              product.name[0].toUpperCase(),
              style: const TextStyle(
                color: Color(AppColors.primaryTeal),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(product.store),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _currencyFormat.format(product.currentPrice),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _trendIcon,
                  size: 14,
                  color: _trendColor,
                ),
                const SizedBox(width: 4),
                Text(
                  product.changePercentage == 0
                      ? 'Stabil'
                      : '${product.changePercentage.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: _trendColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to detail view
        },
      ),
    );
  }
}
