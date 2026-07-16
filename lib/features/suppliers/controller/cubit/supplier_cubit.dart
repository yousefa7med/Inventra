import 'package:Inventra/core/models/supplier_model.dart';
import 'package:Inventra/features/suppliers/controller/cubit/supplier_cubit_interface.dart';
import 'package:Inventra/features/suppliers/data/repositories/supplier_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'supplier_state.dart';

class SupplierCubit extends Cubit<SupplierState>
    implements SupplierCubitInterface {
  SupplierCubit({required this._repository}) : super(const SupplierInitial());
  final SupplierRepository _repository;

  List<SupplierModel> _suppliers = [];
  List<SupplierModel> _filteredSuppliers = [];

  String searchQuery = "";

  @override
  List<SupplierModel> get suppliers => _suppliers;

  @override
  List<SupplierModel> get filteredSuppliers => _filteredSuppliers;
  @override
  void loadSuppliers() {
    emit(const SupplierLoading());
    try {
      _suppliers = _repository.getAllSuppliers();
      _filteredSuppliers = List.from(_suppliers);
      emit(const SupplierLoadingSuccessed());
    } catch (e) {
      emit(SupplierLoadingError(e.toString()));
    }
  }

  @override
  void searchSuppliers(String query) {
    searchQuery = query;
    emit(const SupplierLoading());

    _filteredSuppliers = _repository.searchSuppliers(query);
    emit(const SupplierLoadingSuccessed());
  }

  @override
  void updateSupplier(SupplierModel supplier) {
    try {
      _repository.updateSupplier(supplier);

      // Update local lists
      final index = _suppliers.indexWhere((c) => c.id == supplier.id);
      if (index != -1) {
        _suppliers[index] = supplier;
      } else {
        _suppliers.add(supplier);
      }

      final filteredIndex = _filteredSuppliers.indexWhere(
        (c) => c.id == supplier.id,
      );
      if (filteredIndex != -1) {
        _filteredSuppliers[filteredIndex] = supplier;
      } else {
        _filteredSuppliers.add(supplier);
      }

      // ignore: prefer_const_constructors
      emit(SupplierUpdated("تم تعديل بيانات العميل بنجاح"));
    } catch (e) {
      emit(SupplierLoadingError(e.toString()));
    }
  }
}
