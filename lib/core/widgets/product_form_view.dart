import 'dart:io';

import 'package:Inventra/core/helper/functions.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/utils/validators.dart';
import 'package:Inventra/core/widgets/app_button.dart';
import 'package:Inventra/core/widgets/app_text_field.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/add_image.dart';
import 'package:Inventra/features/inventory/controller/cubit/product_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ProductFormView extends StatefulWidget {
  const ProductFormView({super.key, this.product, this.isQuantitiyEditable});
  final ProductModel? product;
  final bool? isQuantitiyEditable;
  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  XFile? image;
  late final TextEditingController barcodeController;
  late final TextEditingController nameController;
  late final TextEditingController? quantatyController;
  late final TextEditingController bPriceController;
  late final TextEditingController wPriceController;
  late final TextEditingController sPriceController;
  String? imgPath;
  late final bool isEditing;

  @override
  void initState() {
    isEditing = widget.product != null;
    barcodeController = TextEditingController(text: widget.product?.barcode);
    nameController = TextEditingController(text: widget.product?.name);
    if (widget.isQuantitiyEditable ?? true) {
      quantatyController = TextEditingController(
        text: widget.product?.quantity.toString(),
      );
    } else {
      quantatyController = null;
    }

    bPriceController = TextEditingController(
      text: widget.product?.buyingPrice.toString(),
    );
    wPriceController = TextEditingController(
      text: widget.product?.wholesalePrice.toString(),
    );
    sPriceController = TextEditingController(
      text: widget.product?.saleingPrice.toString(),
    );
    imgPath = widget.product?.imgPath;
    super.initState();
  }

  @override
  void dispose() {
    barcodeController.dispose();
    nameController.dispose();
    quantatyController?.dispose();
    bPriceController.dispose();
    wPriceController.dispose();
    sPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: isEditing ? 'تعديل المنتج' : 'إضافة منتج'),
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
                    validator: Validator.validateName(),
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
                    validator: Validator.validateBarcode(),
                  ),

                  if (widget.isQuantitiyEditable ?? true) ...[
                    const Gap(16),
                    AppTextField(
                      controller: quantatyController,
                      label: "الكمية المتاحة",
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validator: Validator.validateQuantaty(),
                    ),
                  ],
                  const Gap(16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: bPriceController,
                          label: "سعر الشراء",
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          suffixText: 'ج.م',
                          validator: Validator.validateBuyingPrice(),
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
                          validator: Validator.validateWholeSalePrice(
                            bPriceController,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),

                  FractionallySizedBox(
                    child: AppTextField(
                      controller: sPriceController,
                      label: "سعر البيع",
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      suffixText: 'ج.م',
                      validator: Validator.validateSellingPrice(
                        bPriceController,
                        wPriceController,
                      ),
                    ),
                  ),

                  Gap(32.h),
                  AppButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        late final ProductModel product;
                        String? oldImagePath = widget.product?.imgPath;
                        String? workingImgPath = imgPath;

                        // حفظ الصورة الجديدة أولاً في متغير مؤقت
                        if (image != null) {
                          workingImgPath = await saveProductImage(image!);
                        }

                        if (isEditing) {
                          product = widget.product!.copyWith(
                            name: nameController.text.trim(),
                            quantity: int.tryParse(
                              quantatyController?.text ?? "0",
                            ),
                            buyingPrice: double.tryParse(bPriceController.text),
                            saleingPrice: double.tryParse(
                              sPriceController.text,
                            ),
                            wholesalePrice: double.tryParse(
                              wPriceController.text,
                            ),
                            barcode: barcodeController.text,
                            imgPath: workingImgPath,
                          );
                        } else {
                          product = ProductModel(
                            name: nameController.text.trim(),
                            quantity:
                                int.tryParse(quantatyController?.text ?? "0") ??
                                0,
                            buyingPrice:
                                double.tryParse(bPriceController.text) ?? 0,
                            saleingPrice:
                                double.tryParse(sPriceController.text) ?? 0,
                            wholesalePrice:
                                double.tryParse(wPriceController.text) ?? 0,
                            barcode: barcodeController.text,
                            imgPath: workingImgPath,
                          );
                        }

                        try {
                          // محاولة الحفظ في قاعدة البيانات
                          context.read<ProductCubit>().updateProduct(product);

                          // إذا نجحت عملية الحفظ، نقوم بحذف الصورة القديمة بأمان الآن
                          if (isEditing &&
                              image != null &&
                              oldImagePath != null) {
                            await deleteImage(oldImagePath);
                          }

                          if (!context.mounted) return;
                          showSnackBar(
                            context,
                            isEditing
                                ? "تم تعديل المنتج بنجاح"
                                : "تم إضافة المنتج بنجاح",
                            color: AppColors.success,
                          );

                          AppNavigation.pop(context: context);
                        } catch (e) {
                          if (image != null && workingImgPath != null) {
                            await deleteImage(workingImgPath);
                            imgPath = oldImagePath;
                          }

                          if (!context.mounted) return;
                          showSnackBar(
                            context,
                            isEditing
                                ? 'فشل تعديل المنتج: $e'
                                : 'فشل إضافة المنتج: $e',
                            color: AppColors.error,
                          );
                        }
                      }
                    },
                    child: Text(
                      isEditing ? "تعديل المنتج" : "إضافة المنتج",
                      style: AppTextStyle.medium16,
                    ),
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

  Future<void> deleteImage(String path) async {
    if (path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        file.delete();
      }
    }
  }
}
