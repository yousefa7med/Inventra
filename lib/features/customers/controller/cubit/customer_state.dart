part of 'customer_cubit.dart';

sealed class CustomerState {
  const CustomerState();
}

final class CustomerInitial extends CustomerState {
  const CustomerInitial();
}

final class CustomerLoading extends CustomerState {
  const CustomerLoading();
}

final class CustomerLoadingError extends CustomerState {
  final String message;

  const CustomerLoadingError(this.message);
}

final class CustomerLoadingSuccessed extends CustomerState {
  const CustomerLoadingSuccessed({required this.customers});
  final List<CustomerModel> customers;
}

final class CustomerInserted extends CustomerState {
  const CustomerInserted({required this.customers});
  final List<CustomerModel> customers;
}
