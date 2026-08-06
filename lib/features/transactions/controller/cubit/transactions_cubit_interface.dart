import 'package:Inventra/core/models/manual_adjustment_model.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/features/transactions/data/models/invoice_details_model.dart';
import 'package:Inventra/features/transactions/data/models/list_item_model.dart';
import 'package:flutter/material.dart';
import 'package:Inventra/core/models/transaction_type.dart';

abstract class TransactionsCubitInterface {
  // State getters
  List<ListItemModel> get listItems;
  int? get selectedType;
  DateTimeRange? get selectedDateRange;

  // Filter actions
  void loadTransactions({TransactionType? type, DateTimeRange? dateRange});

  void clearFiltersAndGetTransactions();
  void clearTypeFilterAndGetTransactions();
  void clearDateFilterAndGetTransactions();
  InvoiceDetailsModel getInvoiceDetails({
    required TransactionType type,
    required int id,
  });
  void generateListItems(List<TransactionsEntry> transactions);
  ManualAdjustmentModel getManualAdjustment(int id);
}
