import 'package:Inventra/core/models/balance_change_type.dart';

extension BalanceChangeTypeArabic on BalanceChangeType {
  String get arabicLabel => switch (this) {
    BalanceChangeType.expense => 'مصروفات',
    BalanceChangeType.buyingInvoice => 'مشتريات',
    BalanceChangeType.sellingInvoice => 'مبيعات',
    BalanceChangeType.returnReceipt => 'مرتجعات',
    BalanceChangeType.manualAdjustment => 'تعديل يدوي',
  };
}
