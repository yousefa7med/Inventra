import 'package:Inventra/core/models/buying_invoice_model.dart';
import 'package:Inventra/core/models/invoice_item_model.dart';
import 'package:Inventra/core/models/selling_invoice_model.dart';
import 'package:Inventra/core/models/transaction_type.dart';

class InvoiceDetailsModel {
  final TransactionType type;
  final int id;
  final DateTime date;

  final String personName;
  final String personPhoneNum;
  final List<InvoiceItemModel> items;
  final double? discount;

  double get subTotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);
  double get total => subTotal - (discount ?? 0);

  InvoiceDetailsModel({
    required this.type,
    required this.date,
    required this.personName,
    required this.personPhoneNum,
    required this.items,
    this.discount,
    required this.id,
  });

  factory InvoiceDetailsModel.fromSellingInvoice({
    required SellingInvoiceModel invoice,
  }) => InvoiceDetailsModel(
    type: TransactionType.sellingInvoice,
    date: invoice.date,
    personName: invoice.customer.target!.name,
    personPhoneNum: invoice.customer.target!.phoneNum,
    items: invoice.items.toList(),
    discount: invoice.discount,
    id: invoice.id,
  );
  factory InvoiceDetailsModel.fromBuyingInvoice({
    required BuyingInvoiceModel invoice,
  }) => InvoiceDetailsModel(
    type: TransactionType.buyingInvoice,
    date: invoice.date,
    personName: invoice.supplier.target!.name,
    personPhoneNum: invoice.supplier.target!.phoneNum,
    items: invoice.items.toList(),
    id: invoice.id,
    //!  edit this
    discount: 0,
  );
}
