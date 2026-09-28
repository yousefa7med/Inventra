import 'dart:async';

import 'package:Inventra/core/models/transaction_type.dart';

class TransactionChangeNotifier {
  final StreamController<TransactionType> _controller =
      StreamController<TransactionType>.broadcast();

  Stream<TransactionType> get stream => _controller.stream;

  void notify(TransactionType type) {
    _controller.add(type);
  }
}
