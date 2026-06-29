import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class InvoiceModel {
  @Id()
  int id = 0;
  final DateTime date;
  final double? discount;
 final ToOne<CustomerModel> customer=ToOne<CustomerModel>();
 final ToMany<ProductModel> products=ToMany<ProductModel>();

  InvoiceModel({required this.date,  this.discount});
}
