import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/utils/validators.dart';
import 'package:Inventra/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

Future<ProductModel?> changeProductPriceDialog(
  BuildContext context,
  ProductModel product,
) async {
  return await showDialog<ProductModel>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => ChangeProductPriceDialog(product: product),
  );
}

class ChangeProductPriceDialog extends StatefulWidget {
  const ChangeProductPriceDialog({super.key, required this.product});
  final ProductModel product;
  @override
  State<ChangeProductPriceDialog> createState() =>
      _ChangeProductPriceDialogState();
}

class _ChangeProductPriceDialogState extends State<ChangeProductPriceDialog> {
  late final TextEditingController buyingPriceController;
  late final TextEditingController wholesalePriceController;
  late final TextEditingController sellingPriceController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    buyingPriceController = TextEditingController(
      text: widget.product.buyingPrice.toString(),
    );
    sellingPriceController = TextEditingController(
      text: widget.product.sellingPrice.toString(),
    );
    wholesalePriceController = TextEditingController(
      text: widget.product.wholesalePrice.toString(),
    );

    super.initState();
  }

  @override
  void dispose() {
    buyingPriceController.dispose();
    sellingPriceController.dispose();
    wholesalePriceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("هل تريد تعديل السعر", style: AppTextStyle.bold16),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.product.name,
                style: AppTextStyle.bold14,
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              AppTextField(
                label: AppStrings.buyingPrice,
                controller: buyingPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                suffixText: AppStrings.egp,
                validator: Validator.validateBuyingPrice(),
              ),
              const Gap(12),
              AppTextField(
                label: AppStrings.wholesalePrice,
                controller: wholesalePriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                suffixText: AppStrings.egp,
                validator: Validator.validateWholeSalePrice(
                  buyingPriceController,
                ),
              ),
              const Gap(12),
              AppTextField(
                label: AppStrings.sellingPrice,
                controller: sellingPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                suffixText: AppStrings.egp,
                validator: Validator.validateSellingPrice(
                  buyingPriceController,
                  wholesalePriceController,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => AppNavigation.pop(context),
          child: Text(
            AppStrings.cancel,
            style: AppTextStyle.regular14.copyWith(color: AppColors.error),
          ),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final buyingPrice = double.tryParse(buyingPriceController.text);
              final wholesalePrice = double.tryParse(
                wholesalePriceController.text,
              );
              final sellingPrice = double.tryParse(sellingPriceController.text);
              if (buyingPrice != widget.product.buyingPrice ||
                  wholesalePrice != widget.product.wholesalePrice ||
                  sellingPrice != widget.product.sellingPrice) {
                final newProduct = widget.product.copyWith(
                  buyingPrice: buyingPrice,
                  sellingPrice: sellingPrice,
                  wholesalePrice: wholesalePrice,
                );
                AppNavigation.pop(context, newProduct);
              } else {
                AppNavigation.pop(context);
              }
            }
          },
          child: Text(
            AppStrings.addToInvoice,
            style: AppTextStyle.regular14.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
