import 'package:Inventra/core/models/transaction_type.dart';

extension TransactionTypeArabic on TransactionType {
  String get arabicLabel => switch (this) {
    TransactionType.expense => 'مصروفات',
    TransactionType.buyingInvoice => 'مشتريات',
    TransactionType.sellingInvoice => 'مبيعات',
    TransactionType.returnReceipt => 'مرتجعات',
    TransactionType.manualAdjustment => 'تعديل يدوي',
  };
}
