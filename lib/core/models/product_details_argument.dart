import 'package:Inventra/core/models/product_model.dart';

class ProductDetailsArguments {
  final ProductModel? product;
  final bool? isQuantitiyEditable;

  ProductDetailsArguments({ this.product,  this.isQuantitiyEditable});


}