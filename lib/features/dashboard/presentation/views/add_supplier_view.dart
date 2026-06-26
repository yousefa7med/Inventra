import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/supplier_model.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/app_button.dart';
import 'package:Inventra/core/widgets/app_text_field.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';

class AddSupplierView extends StatefulWidget {
  const AddSupplierView({super.key});

  @override
  State<AddSupplierView> createState() => _AddSupplierViewState();
}

class _AddSupplierViewState extends State<AddSupplierView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController storeNameController;
  late final TextEditingController storeAddressController;
  late final TextEditingController phoneController;

  @override
  void initState() {
    nameController = TextEditingController();
    storeNameController = TextEditingController();
    storeAddressController = TextEditingController();
    phoneController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    storeNameController.dispose();
    storeAddressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const CustomAppBar(title: "اضافة مورد"),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
            child: Form(
              key: _formKey,
              autovalidateMode:
                  AutovalidateMode.onUserInteraction, 
              child: Column(
                children: [
                  Gap(24.h),

                  AppTextField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    label: "اسم المورد",
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "برجاء إدخال اسم المورد";
                      }
                      if (value.trim().length < 3) {
                        return "الاسم يجب أن يكون 3 أحرف على الأقل";
                      }
                      return null;
                    },
                  ),
                  Gap(16.h),

                  // 2. حقل اسم المتجر
                  AppTextField(
                    controller: storeNameController,
                    keyboardType: TextInputType.text,
                    label: "اسم المتجر / الشركة",
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(
                      Icons.storefront_outlined,
                      color: AppColors.primary,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "برجاء إدخال اسم المتجر";
                      }
                      return null;
                    },
                  ),
                  Gap(16.h),

                  // 3. حقل عنوان المتجر
                  AppTextField(
                    controller: storeAddressController,
                    keyboardType: TextInputType.streetAddress,
                    label: "عنوان المتجر",
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "برجاء إدخال عنوان المتجر";
                      }
                      return null;
                    },
                  ),
                  Gap(16.h),

                  // 4. حقل رقم الهاتف
                  AppTextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    label: "رقم الهاتف",
                    textInputAction:
                        TextInputAction.done, // آخر حقل يقفل الكيبورد
                    prefixIcon: const Icon(
                      Icons.phone_android_outlined,
                      color: AppColors.primary,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "برجاء إدخال رقم الهاتف";
                      }
                      final phoneRegex = RegExp(
                        r'^[0-9+]{7,15}$',
                      ); // فاليديشن مرن
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return "برجاء إدخال رقم هاتف صحيح";
                      }
                      return null;
                    },
                  ),

                  Gap(32.h), 
            
                  AppButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final supplier = SupplierModel(
                          name: nameController.text.trim(),
                          storeName: storeNameController.text.trim(),
                          storeAdd: storeAddressController.text.trim(),
                          phoneNum: phoneController.text.trim(),
                        );

                        addSupplier(supplier);
                        AppNavigation.pop(context: context);
                      }
                    },
                    child: Text("اضافة مورد", style: AppTextStyle.medium16),
                  ),
                  Gap(24.h), // أمان للـ Scrolling
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // دالة الحفظ المباشر في صندوق الموردين (Suppliers Box)
  void addSupplier(SupplierModel supplier) {
    GetIt.instance<ObjectBoxServices>().suppliersBox.put(supplier);
  }
}
