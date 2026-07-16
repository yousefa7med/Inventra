import 'package:Inventra/core/models/selling_invoice_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class CustomerModel {
  @Id()
  int id = 0;

  final String name;
  final String? address;
  final String phoneNum;
  final ToMany<SellingInvoiceModel> invoices = ToMany<SellingInvoiceModel>();

  CustomerModel copyWith({String? name, String? address, String? phoneNum}) {
    final newCustomer = CustomerModel(
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNum: phoneNum ?? this.phoneNum,
    );
    newCustomer.id = id;
    newCustomer.invoices.addAll(invoices);
    return newCustomer;
  }

  CustomerModel({
    required this.name,
    required this.address,
    required this.phoneNum,
  });
}
