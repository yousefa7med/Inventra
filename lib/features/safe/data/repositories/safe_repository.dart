import 'package:Inventra/core/models/buying_invoice_model.dart';
import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/models/manual_adjustment_model.dart';
import 'package:Inventra/core/models/safe_balance_model.dart';
import 'package:Inventra/core/models/selling_invoice_model.dart';
import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/models/transactions_entry.dart';

abstract class SafeRepository {
  SafeBalanceModel getBalance();
  void adjustBalance({required double newAmount, String? newNote});
  List<TransactionsEntry> getTransactions({TransactionType? type});

  void addExpense(ExpenseModel expense);

  BuyingInvoiceModel getBuyingInvoice(int id);

  SellingInvoiceModel getSellingInvoice(int id);
  //  getReturnReciept(int id);

  ManualAdjustmentModel getManualAdjustment(int id);
}
