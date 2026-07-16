import 'package:Inventra/core/helper/arabic_normalizer.dart';
import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/features/customers/data/repositories/customer_repository.dart';
import 'package:Inventra/objectbox.g.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final ObjectBoxServices _objectBoxServices;

  CustomerRepositoryImpl(this._objectBoxServices);

  @override
  List<CustomerModel> getAllCustomers() {
    return _objectBoxServices.customersBox.getAll();
  }

  @override
  void addCustomer(CustomerModel customer) {
    _objectBoxServices.customersBox.put(customer);
  }

  @override
  void updateCustomer(CustomerModel customer) {
    _objectBoxServices.customersBox.put(customer);
  }

  @override
  List<CustomerModel> searchCustomers(String search) {
    if (search.isEmpty) return getAllCustomers();

    final searchText = search.toLowerCase().normalizeArabic();

    final query = _objectBoxServices.customersBox
        .query(CustomerModel_.name.contains(searchText, caseSensitive: false))
        .build();
    final result = query.find();
    query.close();
    return result;
  }
}
