import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final length = amount.toString().split('.').last.length;
  late final int decimalDigits;
  late final String symbol;

  if (length > 2) {
    decimalDigits = 2;
  } else {
    decimalDigits = length;
  }
  if (amount > 1000000) {
    amount = amount / 1000000;
    symbol = "م ج.م ";
  } else if (amount > 1000) {
    amount = amount / 1000;
    symbol = "الف ج.م ";
  } else {
    symbol = 'ج.م ';
  }

  final formatter = NumberFormat.currency(
    locale: 'ar',
    symbol: '',
    decimalDigits: decimalDigits,
  );
  return formatter.format(amount);
}

String formatDateTime(DateTime dateTime) {
  final formatter = DateFormat('yyyy/MM/dd hh:mm a', 'ar');
  return formatter.format(dateTime);
}
