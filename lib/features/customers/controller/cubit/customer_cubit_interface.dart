import 'package:Inventra/core/models/customer_model.dart';

abstract class CustomerCubitInterface {

void loadCustomers();
  void searchCustomers(String query);
  bool insertCustomer(CustomerModel customer);
}