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
}
