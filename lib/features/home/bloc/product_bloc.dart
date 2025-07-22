import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../core/errors/failures.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecommendedProducts extends ProductEvent {
  final bool refresh;

  const LoadRecommendedProducts({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {
  final List<ProductModel> oldProducts;
  final bool isFirstFetch;

  const ProductLoading(this.oldProducts, {this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldProducts, isFirstFetch];
}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final bool hasReachedMax;

  const ProductLoaded({
    required this.products,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [products, hasReachedMax];

  ProductLoaded copyWith({
    List<ProductModel>? products,
    bool? hasReachedMax,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;
  int _currentPage = 1;
  static const int _pageSize = 10;

  ProductBloc(this._productRepository) : super(ProductInitial()) {
    on<LoadRecommendedProducts>(_onLoadRecommendedProducts);
  }

  Future<void> _onLoadRecommendedProducts(
    LoadRecommendedProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (event.refresh) {
      _currentPage = 1;
      emit(const ProductLoading([], isFirstFetch: true));
    } else {
      if (state is ProductLoaded) {
        final currentState = state as ProductLoaded;
        if (currentState.hasReachedMax) return;
        emit(ProductLoading(currentState.products));
      } else {
        emit(const ProductLoading([], isFirstFetch: true));
      }
    }

    try {
      final products = await _productRepository.getRecommendedProducts(
        page: _currentPage,
        limit: _pageSize,
      );

      final isLastPage = products.length < _pageSize;
      
      if (state is ProductLoading) {
        final oldProducts = (state as ProductLoading).oldProducts;
        _currentPage++;
        
        emit(ProductLoaded(
          products: [...oldProducts, ...products],
          hasReachedMax: isLastPage,
        ));
      }
    } on Failure catch (failure) {
      emit(ProductError(failure.message));
    } catch (e) {
      emit(const ProductError('An unexpected error occurred'));
    }
  }
} 