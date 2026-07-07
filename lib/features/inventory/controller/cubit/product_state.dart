part of 'product_cubit.dart';

@immutable
sealed class ProductState {
  const ProductState();
}

final class ProductInitial extends ProductState { 
  const ProductInitial();
}

final class ProductLoading extends ProductState {
  const ProductLoading();
}

final class ProductsLoaded extends ProductState {
  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;

  const ProductsLoaded({
    required this.products,
    required this.filteredProducts,
  });
}


final class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);
}