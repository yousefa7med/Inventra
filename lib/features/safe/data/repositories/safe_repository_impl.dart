import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/buying_invoice_model.dart';
import 'package:Inventra/core/models/expense_model.dart';
import 'package:Inventra/core/models/manual_adjustment_model.dart';
import 'package:Inventra/core/models/safe_balance_model.dart';
import 'package:Inventra/core/models/selling_invoice_model.dart';
import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/services/Transaction_change_notifier.dart';
import 'package:Inventra/features/safe/data/repositories/safe_repository.dart';
import 'package:Inventra/objectbox.g.dart';

class SafeRepositoryImpl implements SafeRepository {
  final ObjectBoxServices _objectBox;
  final TransactionChangeNotifier _transactionChangeNotifier;

  SafeRepositoryImpl(this._objectBox, this._transactionChangeNotifier);

  @override
  SafeBalanceModel getBalance() {
    final balance = _objectBox.safeBalanceBox.get(1);

    if (balance != null) return balance;
    return SafeBalanceModel(currentBalance: 0, lastUpdated: DateTime.now());
  }

  @override
  void adjustBalance({required double newAmount, String? newNote}) {
    final balance = getBalance();
    final newBalance = balance.copyWith(
      currentBalance: newAmount,
      lastUpdated: DateTime.now(),
      note: newNote,
    );
    _objectBox.safeBalanceBox.put(newBalance);

    _objectBox.store.runInTransaction(TxMode.write, () {
      final adjustmentId = _objectBox.manualAdjustmentBox.put(
        ManualAdjustmentModel(
          prevBalanceValue: balance.currentBalance,
          newBalanceValue: newBalance.currentBalance,
          date: newBalance.lastUpdated,
          note: newBalance.note,
        ),
      );
      _objectBox.transactionsEntryBox.put(
        TransactionsEntry(
          typeIndex: TransactionType.manualAdjustment.index,
          signedValue: newBalance.currentBalance,
          referenceId: adjustmentId,
          createdAt: newBalance.lastUpdated,
          description: newBalance.note,
        ),
      );
      _transactionChangeNotifier.notify(TransactionType.manualAdjustment);
    });
  }

  @override
  void addExpense(ExpenseModel expense) {
    final balance = getBalance();
    final newbalance = balance.copyWith(
      currentBalance: balance.currentBalance + expense.value,
      lastUpdated: DateTime.now(),
    );
    _objectBox.store.runInTransaction(TxMode.write, () {
      final expenseId = _objectBox.expensesBox.put(expense);

      _objectBox.safeBalanceBox.put(newbalance);
      _objectBox.transactionsEntryBox.put(
        TransactionsEntry(
          typeIndex: TransactionType.expense.index,
          signedValue: expense.value,
          referenceId: expenseId,
          createdAt: expense.date,
          description: expense.note.trim(),
        ),
      );
      _transactionChangeNotifier.notify(TransactionType.expense);
    });
  }

  @override
  List<TransactionsEntry> getTransactions({TransactionType? type}) {
    Condition<TransactionsEntry>? condition;

    if (type != null) {
      condition = TransactionsEntry_.typeIndex.equals(type.index);
    }

    final query = _objectBox.transactionsEntryBox
        .query(condition)
        .order(TransactionsEntry_.createdAt, flags: Order.descending)
        .build();

    final results = query.find();
    query.close();

    return results;
  }

  @override
  BuyingInvoiceModel getBuyingInvoice(int id) {
    return _objectBox.buyInvoicesBox.get(id)!;
  }

  @override
  SellingInvoiceModel getSellingInvoice(int id) {
    return _objectBox.sellingInvoicesBox.get(id)!;
  }

  @override
  ManualAdjustmentModel getManualAdjustment(int id) {
    return _objectBox.manualAdjustmentBox.get(id)!;
  }

  //  getReturnReciept(int id){

  // }
}
