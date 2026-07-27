import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/core/models/invoice_item_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class SellingInvoiceModel {
  @Id()
  int id = 0;

  final DateTime date;
  final double? discount;

  final ToMany<InvoiceItemModel> items = ToMany<InvoiceItemModel>();
  final ToOne<CustomerModel> customer = ToOne<CustomerModel>();

  SellingInvoiceModel({required this.date, this.discount});
}
