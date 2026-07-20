sealed class BuyInvoiceState {}

class BuyInvoiceInitial extends BuyInvoiceState {}

class BuyInvoiceLoading extends BuyInvoiceState {}

class BuyInvoiceSuppliersLoaded extends BuyInvoiceState {}

class BuyInvoiceProductsLoaded extends BuyInvoiceState {}

class BuyInvoiceProductLoading extends BuyInvoiceState {}

class BuyInvoiceAddProduct extends BuyInvoiceState {}

class BuyInvoiceUpdateProductQuantity extends BuyInvoiceState {}

class BuyInvoiceRemoveProduct extends BuyInvoiceState {}

class BuyInvoiceConfirmed extends BuyInvoiceState {}

class BuyInvoiceError extends BuyInvoiceState {
  final String message;

  BuyInvoiceError(this.message);
}