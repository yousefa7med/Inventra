abstract class SellInvoiceState {
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
//============================ products states

class SellInvoiceProductLoading extends SellInvoiceState {
  const SellInvoiceProductLoading();
}

class SellInvoiceProductSuccessed extends SellInvoiceState {
  const SellInvoiceProductSuccessed();
}

class SellInvoiceAddProduct extends SellInvoiceState {
  const SellInvoiceAddProduct();
}

class SellInvoiceRemoveProduct extends SellInvoiceState {
  const SellInvoiceRemoveProduct();
}

class SellInvoiceUpdateProductQuantity extends SellInvoiceState {
  const SellInvoiceUpdateProductQuantity();
}
