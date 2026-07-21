sealed class BuyInvoiceState {}

class BuyInvoiceInitial extends BuyInvoiceState {}

class BuyInvoiceLoading extends BuyInvoiceState {}

// product state
class BuyInvoiceProductsLoaded extends BuyInvoiceState {}

class BuyInvoiceProductLoading extends BuyInvoiceState {}

class BuyInvoiceAddNewProduct extends BuyInvoiceState {}

class BuyInvoiceProductError extends BuyInvoiceState {
  final String message;

  BuyInvoiceProductError(this.message);
}

// invoice state
class BuyInvoiceAddProductItem extends BuyInvoiceState {}

class BuyInvoiceUpdateProductQuantity extends BuyInvoiceState {}

class BuyInvoiceRemoveProduct extends BuyInvoiceState {}

class BuyInvoiceConfirmed extends BuyInvoiceState {}

class BuyInvoiceError extends BuyInvoiceState {
  final String message;

  BuyInvoiceError(this.message);
}
