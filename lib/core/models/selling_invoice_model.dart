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

  double get profit {
    double profit = 0;
    print(items.length);
    for (var item in items) {
      // print("before {$profit}");

      // print(item.lineTotal);
      // print(item.unitCost);
      // print(item.quantity);
      profit += item.lineTotal - (item.unitCost! * item.quantity);
      print("after {$profit}");
    }

    return profit - (discount ?? 0);
  }
}
