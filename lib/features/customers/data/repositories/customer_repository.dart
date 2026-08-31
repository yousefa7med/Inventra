import 'package:Inventra/core/models/customer_model.dart';

abstract class CustomerRepository {
  List<CustomerModel> getAllCustomers();
  void insertCustomer(CustomerModel customer);
  List<CustomerModel> searchCustomers(String search);
}
