import 'package:intl/intl.dart';

String formatCurrency(
  double amount, {
  bool useCurrencySymbol = false,
  bool reduceDecimalDigits = false,
}) {
  String? symbol;

  if (useCurrencySymbol) {
    final absoluteAmount = amount.abs();

    if (absoluteAmount >= 1000000) {
      amount /= 1000000;
      symbol = 'مليون ج.م';
    } else if (absoluteAmount >= 1000) {
      amount /= 1000;
      symbol = 'الف ج.م';
    } else {
      symbol = 'ج.م';
    }
  }

  int? decimalDigits;

  if (reduceDecimalDigits) {
    final roundedAmount = double.parse(amount.toStringAsFixed(2));

    if (roundedAmount == roundedAmount.truncateToDouble()) {
      decimalDigits = 0;
    } else if ((roundedAmount * 10) % 1 == 0) {
      decimalDigits = 1;
    } else {
      decimalDigits = 2;
    }
  }

  final formatter = NumberFormat.currency(
    locale: 'ar',
    symbol: symbol,
    decimalDigits: decimalDigits,
  );

  return formatter.format(amount);
}

String formatDateTime(DateTime dateTime) {
  final formatter = DateFormat('yyyy/MM/dd hh:mm a', 'ar');
  return formatter.format(dateTime);
}
