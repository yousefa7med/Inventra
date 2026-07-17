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

final class ProductsLoadingSuccessed extends ProductState {
  const ProductsLoadingSuccessed();
}

final class ProductInserted extends ProductState {
  const ProductInserted();
}

final class ProductErrorState extends ProductState {
  final String message;

  const ProductErrorState(this.message);
}
