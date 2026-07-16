import 'package:objectbox/objectbox.dart';

@Entity()
class SupplierModel {
  @Id()
  int id = 0;
  final String name;
  final String? storeAdd;
  final String storeName;
  final String phoneNum;

  SupplierModel({
    required this.name,
    this.storeAdd,
    required this.storeName,
    required this.phoneNum,
  });
  SupplierModel copyWith({
    String? name,
    String? storeAdd,
    String? storeName,
    String? phoneNum,
  }) => SupplierModel(
    name: name ?? this.name,
    storeName: storeName ?? this.storeName,
    phoneNum: phoneNum ?? this.phoneNum,
    storeAdd: storeAdd ?? this.storeAdd,
  )..id = id;
}
