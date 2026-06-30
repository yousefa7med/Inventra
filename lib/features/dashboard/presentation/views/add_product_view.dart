import 'dart:io';

import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/helper/functions.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/app_button.dart';
import 'package:Inventra/core/widgets/app_text_field.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/add_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  XFile? image;
  late final TextEditingController barcodeController;
  late final TextEditingController nameController;
  late final TextEditingController quantatyController;
  late final TextEditingController bPriceController;
  late final TextEditingController wPriceController;
  late final TextEditingController sPriceController;

  @override
  void initState() {
    barcodeController = TextEditingController();
    nameController = TextEditingController();
    quantatyController = TextEditingController();
    bPriceController = TextEditingController();
    wPriceController = TextEditingController();
    sPriceController = TextEditingController();
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
        appBar: const CustomAppBar(title: 'إضافة منتج'),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Form(
              key: _formKey,
              autovalidateMode:
                  AutovalidateMode.onUserInteraction, // تحسين الـ UX
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Gap(24),
                  image == null
                      ? AddProductImageWidget(
                          onTap: () async {
                            image = await picker.pickImage(
                              source: ImageSource.camera,
                              maxHeight: 500,
                              maxWidth: 500,
                            );
                            if (image != null) {
                              setState(() {});
                            }
                          },
                        )
                      : ProductImage(imagePath: image!.path),
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
                            // مقارنة مع سعر الشراء
                            final buyingPrice =
                                double.tryParse(bPriceController.text) ?? 0;
                            if (price <= buyingPrice) {
                              return "يجب أن يكون أكبر من سعرالشراء";
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
                              return "يجب أن يكون اعلي من سعر البيع";
                            }
                            if (price <= wholesalePrice) {
                              return "يجب أن يكون اعلي من سعر الجملة";
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
                        String? imagePath;
                        if (image != null) {
                          imagePath = await saveProductImage(image!);
                        }

                        final product = ProductModel(
                          name: nameController.text.trim(),
                          quantity: int.tryParse(quantatyController.text) ?? 0,
                          buyingPrice:
                              double.tryParse(bPriceController.text) ?? 0,
                          saleingPrice:
                              double.tryParse(sPriceController.text) ?? 0,
                          wholesalePrice:
                              double.tryParse(wPriceController.text) ?? 0,
                          barcode: barcodeController.text,
                          imgPath: imagePath,
                        );

                        addProduct(product);
                        showSnackBar(
                          context,
                          "تم اضافة المنتج بنجاح",
                          color: AppColors.success,
                        );
                        AppNavigation.pop(context: context);
                      }
                    },
                    child: Text("اضافة المنتج", style: AppTextStyle.medium16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void addProduct(ProductModel product) {
    GetIt.instance<ObjectBoxServices>().productsBox.put(product);
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
