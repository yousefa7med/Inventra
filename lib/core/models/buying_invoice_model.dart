import 'package:Inventra/core/models/invoice_item_model.dart';
import 'package:Inventra/core/models/supplier_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class BuyingInvoiceModel {
  @Id()
  int id = 0;

  final DateTime date;

  // Supplier relationship
  final ToOne<SupplierModel> supplier = ToOne<SupplierModel>();

  // Items relationship
  final ToMany<InvoiceItemModel> items = ToMany<InvoiceItemModel>();

  BuyingInvoiceModel({
    required this.date,
  });

  // Computed total from items
}