import 'package:Inventra/core/models/manual_adjustment_model.dart';
import 'package:Inventra/features/transactions/data/models/invoice_details_model.dart';
import 'package:Inventra/features/transactions/data/models/list_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/features/transactions/controller/cubit/transactions_cubit_interface.dart';
import 'package:Inventra/features/transactions/controller/cubit/transactions_state.dart';
import 'package:Inventra/features/transactions/data/repositories/transactions_repository.dart';

class TransactionsCubit extends Cubit<TransactionsState>
    implements TransactionsCubitInterface {
  final TransactionsRepository _repository;

  TransactionsCubit(this._repository) : super(TransactionsInitial());

  final List<ListItemModel> _listItems = [];
  DateTimeRange<DateTime>? _selectedDateRange;
  int? _selectedType;

  @override
  List<ListItemModel> get listItems => _listItems;

  @override
  DateTimeRange<DateTime>? get selectedDateRange => _selectedDateRange;

  @override
  int? get selectedType => _selectedType;

  @override
  void loadTransactions({
    TransactionType? type,
    DateTimeRange<DateTime>? dateRange,
  }) async {
    if (type == null) {
      type = _selectedType == null
          ? null
          : TransactionType.values[_selectedType!];
    } else {
      _selectedType = type.index;
    }

    if (dateRange == null) {
      dateRange = _selectedDateRange;
    } else {
      _selectedDateRange = dateRange;
    }

    emit(TransactionsLoading());
    try {
      _listItems.clear();
      final transactions = _repository.getTransactions(
        type: type,
        dateRange: dateRange,
      );
      generateListItems(transactions);

      emit(TransactionsLoaded(listItems: _listItems));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  @override
  void generateListItems(List<TransactionsEntry> transactions) {
    final Map<DateTime, List<TransactionsEntry>> grouped = {};

    for (final transaction in transactions) {
      final dateOnly = DateTime(
        transaction.timestamp.year,
        transaction.timestamp.month,
        transaction.timestamp.day,
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
        (sum, transaction) => sum + transaction.value,
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
  void clearFiltersAndGetTransactions() async {
    _selectedType = null;
    _selectedDateRange = null;
    emit(TransactionsLoading());
    try {
      _listItems.clear();
      final transactions = _repository.getTransactions();
      generateListItems(transactions);

      emit(TransactionsLoaded(listItems: _listItems));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  @override
  void clearDateFilterAndGetTransactions() {
    _selectedDateRange = null;
    emit(TransactionsLoading());
    try {
      _listItems.clear();

      final transactions = _repository.getTransactions(
        type: _selectedType == null
            ? null
            : TransactionType.values[_selectedType!],
      );
      generateListItems(transactions);

      emit(TransactionsLoaded(listItems: _listItems));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  @override
  void clearTypeFilterAndGetTransactions() {
    _selectedType = null;
    emit(TransactionsLoading());
    try {
      _listItems.clear();

      final transactions = _repository.getTransactions(
        dateRange: _selectedDateRange,
      );
      generateListItems(transactions);

      emit(TransactionsLoaded(listItems: _listItems));
    } catch (e) {
      emit(TransactionsError(e.toString()));
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
