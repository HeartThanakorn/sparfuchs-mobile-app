import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparfuchs_ai/features/inflation/data/repositories/product_repository.dart';

/// Provider for ProductRepository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

/// Stream of tracked products
final trackedProductsStreamProvider = StreamProvider<List<TrackedProduct>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.watchTrackedProducts();
});

/// Future provider for trending products
final trendingProductsFutureProvider = FutureProvider<List<TrackedProduct>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getTrendingProducts();
});
