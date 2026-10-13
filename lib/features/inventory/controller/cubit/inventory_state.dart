part of 'inventory_cubit.dart';

sealed class InventoryState {
  const InventoryState();
}

final class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

final class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

final class ProductInsertError extends InventoryState {
  final String message;

  const ProductInsertError(this.message);
}

final class InventoryErrorState extends InventoryState {
  final String message;

  const InventoryErrorState(this.message);
}

final class InventoryLoadingSuccessed extends InventoryState {
  const InventoryLoadingSuccessed({required this.products});
  final List<ProductModel> products;
}

final class ProductInsertedSuccessed extends InventoryState {
  const ProductInsertedSuccessed({required this.products});
  final List<ProductModel> products;
}
