import 'package:dio/dio.dart';
import '../../core/api/dio_client.dart';
import '../../core/errors/failures.dart';
import '../models/product_model.dart';

class ProductRepository {
  final DioClient _dioClient;

  ProductRepository(this._dioClient);

  Future<List<ProductModel>> getRecommendedProducts({
    required int page,
    int limit = 10,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/v2/products/recommended',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> data = response.data['data'];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerFailure(
        message: e.response?.data['message'] ?? 'Failed to fetch products',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw const NetworkFailure(message: 'Failed to fetch products');
    }
  }
} 