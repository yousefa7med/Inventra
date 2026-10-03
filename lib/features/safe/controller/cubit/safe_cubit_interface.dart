import 'package:Inventra/core/models/manual_adjustment_model.dart';
import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/features/safe/data/models/invoice_details_model.dart';
import 'package:Inventra/features/safe/data/models/list_item_model.dart';

abstract class SafeCubitInterface {
  // double get currentBalance;
  List<ListItemModel> get listItems;
  TransactionType? get selectedType;

  void loadTransactions({TransactionType? type});


  InvoiceDetailsModel getInvoiceDetails({
    required TransactionType type,
    required int id,
  });
  ManualAdjustmentModel getManualAdjustment(int id);
  void adjustBalance({required double newBalance, String? note});
}
