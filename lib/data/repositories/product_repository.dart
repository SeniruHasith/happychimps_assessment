import 'dart:async';
import '../../core/errors/failures.dart';
import '../../core/services/mock_data_service.dart';
import '../models/product_model.dart';

class ProductRepository {
  final List<ProductModel> _cachedProducts = [];
  final int _pageSize = 10;
  bool _hasMoreData = true;

  Future<List<ProductModel>> getRecommendedProducts({
    required int page,
    int limit = 10,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      if (!_hasMoreData) {
        return [];
      }

      if (_cachedProducts.isEmpty) {
        // First load - get all dummy products
        final dummyData = MockDataService.getDummyProducts();
        _cachedProducts.addAll(
          dummyData.map((json) => ProductModel.fromJson(json)),
        );
      }

      // Calculate pagination
      final startIndex = (page - 1) * _pageSize;
      final endIndex = startIndex + _pageSize;

      if (startIndex >= _cachedProducts.length) {
        _hasMoreData = false;
        return [];
      }

      final paginatedProducts = _cachedProducts.sublist(
        startIndex,
        endIndex.clamp(0, _cachedProducts.length),
      );

      if (paginatedProducts.length < _pageSize) {
        _hasMoreData = false;
      }

      return paginatedProducts;
    } catch (e) {
      throw const NetworkFailure(message: 'Failed to fetch products');
    }
  }

  Future<List<Map<String, dynamic>>> getPromotions() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      return MockDataService.getPromotions();
    } catch (e) {
      throw const NetworkFailure(message: 'Failed to fetch promotions');
    }
  }
} 