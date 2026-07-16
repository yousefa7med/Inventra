import 'package:Inventra/core/models/customer_model.dart';

abstract class CustomerCubitInterface {
  List<CustomerModel> get customers;
  List<CustomerModel> get filteredCustomers;

void loadCustomers();
  void searchCustomers(String query);
  void updateCustomer(CustomerModel customer);
}