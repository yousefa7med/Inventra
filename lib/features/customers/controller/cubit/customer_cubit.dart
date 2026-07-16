import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/features/customers/controller/cubit/customer_cubit_interface.dart';
import 'package:Inventra/features/customers/data/repositories/customer_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState>
    implements CustomerCubitInterface {
  final CustomerRepository _repository;

  CustomerCubit(this._repository) : super(const CustomerInitial());

  @override
  List<CustomerModel> get customers => _allCustomers;

  @override
  List<CustomerModel> get filteredCustomers => _filteredCustomers;

  List<CustomerModel> _allCustomers = [];
  List<CustomerModel> _filteredCustomers = [];
  String searchQuery = "";
  @override
  void loadCustomers() async {
    emit(const CustomerLoading());
    try {
      _allCustomers = _repository.getAllCustomers();
      _filteredCustomers = List.from(_allCustomers);
      emit(const CustomerLoadingSuccessed());
    } catch (e) {
      emit(CustomerLoadingError(e.toString()));
    }
  }

  @override
  void searchCustomers(String query) {
    searchQuery = query;
    emit(const CustomerLoading());

    try {
      _filteredCustomers = _repository.searchCustomers(query);
      emit(const CustomerLoadingSuccessed());
    } catch (e) {
      emit(CustomerLoadingError(e.toString()));
    }
  }

  @override
  void updateCustomer(CustomerModel customer) async {
    try {
      _repository.updateCustomer(customer);

      final index = _allCustomers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _allCustomers[index] = customer;
      } else {
        _allCustomers.add(customer);
      }

      final filteredIndex = _filteredCustomers.indexWhere(
        (c) => c.id == customer.id,
      );
      if (filteredIndex != -1) {
        _filteredCustomers[filteredIndex] = customer;
      } else {
        _filteredCustomers.add(customer);
      }

      // ignore: prefer_const_constructors
      emit(CustomerUpdated("تم تعديل بيانات العميل بنجاح"));
    } catch (e) {
      emit(CustomerLoadingError(e.toString()));
    }
  }
}
