import 'package:Inventra/core/models/manual_adjustment_model.dart';
import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit_interface.dart';
import 'package:Inventra/features/safe/data/repositories/safe_repository.dart';
import 'package:Inventra/features/safe/data/models/invoice_details_model.dart';
import 'package:Inventra/features/safe/data/models/list_item_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'safe_state.dart';

class SafeCubit extends Cubit<SafeState> implements SafeCubitInterface {
  final SafeRepository _repository;

  SafeCubit(this._repository) : super(SafeInitial());

  double _currentBalance = 0;
  final List<ListItemModel> _listItems = [];
  TransactionType? _selectedType;

  @override
  List<ListItemModel> get listItems => _listItems;

  @override
  TransactionType? get selectedType => _selectedType;

  void init() {
    emit(SafeLoading());
    try {
      _currentBalance = _repository.getBalance().currentBalance;
      _listItems.clear();
      final transactions = _repository.getTransactions();
      _generateListItems(transactions);
      emit(SafeLoaded(safeBalance: _currentBalance, listItems: _listItems));
    } catch (e) {
      emit(SafeError("فشل في تحميل بايانات الخزنة"));
    }
  }

  @override
  void adjustBalance({required double newBalance, String? note}) {
    try {
      _repository.adjustBalance(newAmount: newBalance, newNote: note);
      _currentBalance = newBalance;
      if (state is SafeLoaded) {
        emit((state as SafeLoaded).copyWith(safeBalance: _currentBalance));
      }
    } catch (e) {
      emit(SafeError('فشل تعديل الرصيد: $e'));
    }
  }

  @override
  void loadTransactions({TransactionType? type}) async {
    _selectedType = type;

    emit(SafeLoading());
    try {
      _listItems.clear();
      final transactions = _repository.getTransactions(type: type);
      _generateListItems(transactions);

      emit(SafeLoaded(listItems: _listItems, safeBalance: _currentBalance));
    } catch (e) {
      emit(SafeError(e.toString()));
    }
  }

  void _generateListItems(List<TransactionsEntry> transactions) {
    final Map<DateTime, List<TransactionsEntry>> grouped = {};

    for (final transaction in transactions) {
      final dateOnly = DateTime(
        transaction.createdAt.year,
        transaction.createdAt.month,
        transaction.createdAt.day,
      );
      if (!grouped.containsKey(dateOnly)) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(transaction);
    }

    for (final item in grouped.entries) {
      final date = item.key;
      final dailyTransactions = item.value;
      final double total = dailyTransactions.fold(
        0.0,
        (sum, transaction) => sum + transaction.signedValue,
      );
      _listItems.add(
        HeaderItem(date: date, count: dailyTransactions.length, total: total),
      );

      for (var transaction in dailyTransactions) {
        _listItems.add(TransactionItem(transaction: transaction));
      }
    }
  }

  @override
  InvoiceDetailsModel getInvoiceDetails({
    required TransactionType type,
    required int id,
  }) {
    late final InvoiceDetailsModel invoice;

    if (type == TransactionType.buyingInvoice) {
      final entity = _repository.getBuyingInvoice(id);

      invoice = InvoiceDetailsModel.fromBuyingInvoice(invoice: entity);
    } else if (type == TransactionType.sellingInvoice) {
      final entity = _repository.getSellingInvoice(id);

      invoice = InvoiceDetailsModel.fromSellingInvoice(invoice: entity);
    } else {
      // TODO:
      // final entity = _repository.getSellingInvoice(id);

      // invoice = InvoiceDetailsModel.fromSellingInvoice(invoice: entity);
    }
    return invoice;
  }

  @override
  ManualAdjustmentModel getManualAdjustment(int id) {
    return _repository.getManualAdjustment(id);
  }
}
