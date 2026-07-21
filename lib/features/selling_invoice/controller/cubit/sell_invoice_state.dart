sealed class SellInvoiceState {
  const SellInvoiceState();
}

class SellInvoiceInitial extends SellInvoiceState {
  const SellInvoiceInitial();
}

class SellInvoiceLoading extends SellInvoiceState {
  const SellInvoiceLoading();
}

class SellInvoiceDiscountChanged extends SellInvoiceState {
  const SellInvoiceDiscountChanged();
}

class SellInvoiceConfirmed extends SellInvoiceState {
  const SellInvoiceConfirmed();
}

class SellInvoiceError extends SellInvoiceState {
  final String message;

  const SellInvoiceError(this.message);
}

class SellInvoiceAddProductItem extends SellInvoiceState {
  const SellInvoiceAddProductItem();
}

class SellInvoiceUpdateProductQuantity extends SellInvoiceState {
  const SellInvoiceUpdateProductQuantity();
}

class SellInvoiceRemoveProduct extends SellInvoiceState {
  const SellInvoiceRemoveProduct();
}
//============================ products states

class SellInvoiceProductLoading extends SellInvoiceState {
  const SellInvoiceProductLoading();
}

class SellInvoiceProductSuccessed extends SellInvoiceState {
  const SellInvoiceProductSuccessed();
}

class SellInvoiceProductError extends SellInvoiceState {
  final String message;

  const SellInvoiceProductError(this.message);
}
