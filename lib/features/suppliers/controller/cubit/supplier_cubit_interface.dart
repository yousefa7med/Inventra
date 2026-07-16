import 'package:Inventra/core/models/supplier_model.dart';

abstract class SupplierCubitInterface {
  List<SupplierModel> get suppliers;
  List<SupplierModel> get filteredSuppliers;

  void loadSuppliers();
  void searchSuppliers(String query);
  void updateSupplier(SupplierModel supplier);
}
