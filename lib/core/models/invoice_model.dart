import 'package:Inventra/core/models/customer_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class InvoiceModel {
  @Id()
  int id = 0;
  final DateTime date;
  final double discount;
 late ToOne<CustomerModel> customer;

  InvoiceModel({required this.date, required this.discount});
}
