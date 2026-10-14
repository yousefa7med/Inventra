import 'dart:async';

import 'package:Inventra/core/models/transactions_entry.dart';

class TransactionChangeNotifier {
  final StreamController<TransactionsEntry> _controller =
      StreamController<TransactionsEntry>.broadcast();

  Stream<TransactionsEntry> get stream => _controller.stream;

  void notify(TransactionsEntry entry) {
    _controller.add(entry);
  }
}
