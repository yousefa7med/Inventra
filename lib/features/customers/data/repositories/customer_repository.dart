import 'package:Inventra/core/models/customer_model.dart';

abstract class CustomerRepository {
  List<CustomerModel> getAllCustomers();
  void addCustomer(CustomerModel customer);
  void updateCustomer(CustomerModel customer);
  List<CustomerModel> searchCustomers(String search);
}