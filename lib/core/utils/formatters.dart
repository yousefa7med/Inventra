import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'ar',
    symbol: 'ج.م ',
    decimalDigits: 2,
  );
  return formatter.format(amount);
}

String formatDateTime(DateTime dateTime) {
  final formatter = DateFormat('yyyy/MM/dd hh:mm a', 'ar');
  return formatter.format(dateTime);
}
