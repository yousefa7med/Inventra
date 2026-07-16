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
  const ProductsLoaded();
}


final class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);
}