import 'package:Inventra/core/models/invoice_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class CustomerModel {
  @Id()
  int id = 0;

  final String name;
  final String? address;
  final String phoneNum;

  final ToMany<InvoiceModel> invoices=ToMany<InvoiceModel>();
  

  CustomerModel({
    required this.name,
    required this.address,
    required this.phoneNum,
  });
}
