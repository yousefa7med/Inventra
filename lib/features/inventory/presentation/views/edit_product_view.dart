import 'dart:io';

import 'package:Inventra/core/helper/functions.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/app_button.dart';
import 'package:Inventra/core/widgets/app_text_field.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/add_image.dart';
import 'package:Inventra/features/inventory/controller/cubit/product_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class EditProductView extends StatefulWidget {
  const EditProductView({super.key, required this.product});
  final ProductModel product;
  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  XFile? image;
  late final TextEditingController barcodeController;
  late final TextEditingController nameController;
  late final TextEditingController quantatyController;
  late final TextEditingController bPriceController;
  late final TextEditingController wPriceController;
  late final TextEditingController sPriceController;
  String? imgPath;

  @override
  void initState() {
    barcodeController = TextEditingController(text: widget.product.barcode);
    nameController = TextEditingController(text: widget.product.name);
    quantatyController = TextEditingController(
      text: widget.product.quantity.toString(),
    );
    bPriceController = TextEditingController(
      text: widget.product.buyingPrice.toString(),
    );
    wPriceController = TextEditingController(
      text: widget.product.wholesalePrice.toString(),
    );
    sPriceController = TextEditingController(
      text: widget.product.saleingPrice.toString(),
    );
    imgPath = widget.product.imgPath;
    super.initState();
  }

  @override
  void dispose() {
    barcodeController.dispose();
    nameController.dispose();
    quantatyController.dispose();
    bPriceController.dispose();
    wPriceController.dispose();
    sPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'تعديل المنتج'),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Gap(24),
                  imgPath == null
                      ? AddProductImageWidget(
                          onTap: () async {
                            await pickImage();
                          },
                        )
                      : ProductImage(
                          imagePath: imgPath!,
                          onTap: () async {
                            await pickImage();
                          },
                        ),
                  const Gap(32),

                  AppTextField(
                    label: "اسم المنتج",
                    textInputAction: TextInputAction.next,
                    controller: nameController,
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return "ادخل اسم المنتج";
                      }
                      return null;
                    },
                  ),
                  const Gap(16),

                  AppTextField(
                    controller: barcodeController,
                    label: "الباركود",
                    textInputAction: TextInputAction.next,
                    suffixIcon: const Icon(
                      Icons.qr_code_scanner,
                      color: AppColors.primary,
                    ),
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return "ادخل الباركود";
                      }
                      return null;
                    },
                  ),
                  const Gap(16),

                  AppTextField(
                    controller: quantatyController,
                    label: "الكمية المتاحة",
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "ادخل الكمية المتاحة";
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) return "رقم غير صحيح";
                      return null;
                    },
                  ),
                  const Gap(20),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: bPriceController,
                          label: "سعر الشراء",
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          suffixText: 'ج.م',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "ادخل سعر الشراء";
                            }
                            final price = double.tryParse(value);
                            if (price == null || price <= 0) {
                              return "رقم غير صحيح";
                            }
                            return null;
                          },
                        ),
                      ),
                      Gap(12.w),

                      Expanded(
                        child: AppTextField(
                          controller: wPriceController,
                          label: "سعر الجملة",
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          suffixText: 'ج.م',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "ادخل سعر الجملة";
                            }
                            final price = double.tryParse(value);
                            if (price == null || price <= 0) {
                              return "رقم غير صحيح";
                            }
                            final buyingPrice =
                                double.tryParse(bPriceController.text) ?? 0;
                            if (price <= buyingPrice) {
                              return "يجب أن يكون أكبر من سعر الشراء";
                            }
                            return null;
                          },
                        ),
                      ),
                      Gap(12.w),
                      Expanded(
                        child: AppTextField(
                          controller: sPriceController,
                          label: "سعر البيع",
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          suffixText: 'ج.م',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "ادخل سعر البيع";
                            }
                            final price = double.tryParse(value);
                            if (price == null || price <= 0) {
                              return "رقم غير صحيح";
                            }
                            final buyingPrice =
                                double.tryParse(bPriceController.text) ?? 0;
                            final wholesalePrice =
                                double.tryParse(wPriceController.text) ?? 0;

                            if (price <= buyingPrice) {
                              return "يجب أن يكون أعلى من سعر الشراء";
                            }
                            if (price <= wholesalePrice) {
                              return "يجب أن يكون أعلى من سعر الجملة";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Gap(32.h),
                  AppButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (image != null) {
                          if (widget.product.imgPath != null &&
                              widget.product.imgPath!.isNotEmpty) {
                            final file = File(widget.product.imgPath!);
                            if (await file.exists()) {
                              file.delete();
                            }
                          }

                          imgPath = await saveProductImage(image!);
                        }

                        final newProduct = ProductModel(
                          name: nameController.text.trim(),
                          quantity: int.tryParse(quantatyController.text) ?? 0,
                          buyingPrice:
                              double.tryParse(bPriceController.text) ?? 0,
                          saleingPrice:
                              double.tryParse(sPriceController.text) ?? 0,
                          wholesalePrice:
                              double.tryParse(wPriceController.text) ?? 0,
                          barcode: barcodeController.text,
                          imgPath: imgPath,
                        );
                        newProduct.id = widget.product.id;

                        final cubit = ProductCubit.get(context);
                        try {
                          await cubit.updateProduct(newProduct);
                          if (!context.mounted) return;
                          showSnackBar(
                            context,
                            "تم تعديل المنتج بنجاح",
                            color: AppColors.success,
                          );
                          AppNavigation.pop(context: context);
                        } catch (e) {
                          if (!context.mounted) return;
                          showSnackBar(
                            context,
                            'فشل تعديل المنتج: $e',
                            color: AppColors.error,
                          );
                        }
                      }
                    },
                    child: Text("تعديل المنتج", style: AppTextStyle.medium16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    image = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 500,
      maxWidth: 500,
    );
    if (image != null) {
      setState(() {
        imgPath = image!.path;
      });
    }
  }

  Future<String?> saveProductImage(XFile pickedImage) async {
    final directory = await getApplicationDocumentsDirectory();

    String fileName =
        'prod_${DateTime.now().millisecondsSinceEpoch}${p.extension(pickedImage.path)}';

    String newPath = p.join(directory.path, fileName);

    File localImage = await File(pickedImage.path).copy(newPath);

    return localImage.path;
  }
}
