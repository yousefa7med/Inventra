part of 'supplier_cubit.dart';

@immutable
sealed class SupplierState {
  const SupplierState();
}

final class SupplierInitial extends SupplierState {
  const SupplierInitial();
}

final class SupplierLoading extends SupplierState {
  const SupplierLoading();
}

final class SupplierLoadingSuccessed extends SupplierState {
  const SupplierLoadingSuccessed();
}

final class SupplierLoadingError extends SupplierState {
  final String message;

  const SupplierLoadingError(this.message);
}

final class SupplierUpdated extends SupplierState {
  final String message;

  const SupplierUpdated(this.message);
}
