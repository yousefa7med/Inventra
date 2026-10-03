enum TransactionType {
  sellingInvoice,
  buyingInvoice,
  expense,
  returnReceipt,
  manualAdjustment,
}
extension TransactionTypeArabic on TransactionType {
  String get arabicLabel => switch (this) {
    TransactionType.expense => 'مصروفات',
    TransactionType.buyingInvoice => 'مشتريات',
    TransactionType.sellingInvoice => 'مبيعات',
    TransactionType.returnReceipt => 'مرتجعات',
    TransactionType.manualAdjustment => 'تعديل يدوي',
  };
}