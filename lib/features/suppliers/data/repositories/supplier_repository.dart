import 'package:Inventra/core/models/supplier_model.dart';

abstract class SupplierRepository {
  List<SupplierModel> getAllSuppliers();
  List<SupplierModel> searchSuppliers(String query);
  void addSupplier(SupplierModel supplier);
  void updateSupplier(SupplierModel supplier);
}