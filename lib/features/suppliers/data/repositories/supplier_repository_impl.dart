import 'package:Inventra/core/helper/arabic_normalizer.dart';
import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/supplier_model.dart';
import 'package:Inventra/features/suppliers/data/repositories/supplier_repository.dart';
import 'package:Inventra/objectbox.g.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final ObjectBoxServices _objectBox;

  SupplierRepositoryImpl(this._objectBox);

  @override
  List<SupplierModel> getAllSuppliers() {
    return _objectBox.suppliersBox.getAll();
  }

  @override
  List<SupplierModel> searchSuppliers(String search) {
    final searchQuery = search.trim().toLowerCase().normalizeArabic();
    if (searchQuery.isEmpty) {
      return getAllSuppliers();
    }
    final q = _objectBox.suppliersBox
        .query(SupplierModel_.name.contains(searchQuery, caseSensitive: false))
        .build();
    final results = q.find();
    q.close();
    return results;
  }

  @override
  void addSupplier(SupplierModel supplier) {
    _objectBox.suppliersBox.put(supplier);
  }

  @override
  void updateSupplier(SupplierModel supplier) {
    _objectBox.suppliersBox.put(supplier);
  }
}
