import 'package:Inventra/core/helper/functions.dart';
import 'package:Inventra/core/models/supplier_model.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/utils/validators.dart';
import 'package:Inventra/core/widgets/app_button.dart';
import 'package:Inventra/core/widgets/app_text_field.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/features/suppliers/controller/cubit/supplier_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SupplierFormView extends StatefulWidget {
  const SupplierFormView({super.key, this.supplier});
  final SupplierModel? supplier;

  @override
  State<SupplierFormView> createState() => _SupplierFormViewState();
}

class _SupplierFormViewState extends State<SupplierFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController storeNameController;
  late final TextEditingController storeAddressController;
  late final TextEditingController phoneController;
  late final bool isEditing;

  @override
  void initState() {
    super.initState();
    isEditing = widget.supplier != null;

    nameController = TextEditingController(text: widget.supplier?.name);
    storeNameController = TextEditingController(
      text: widget.supplier?.storeName,
    );
    storeAddressController = TextEditingController(
      text: widget.supplier?.storeAdd,
    );
    phoneController = TextEditingController(text: widget.supplier?.phoneNum);
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
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: isEditing ? 'تعديل المورد' : "اضافة مورد"),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                children: [
                  Gap(24.h),
                  AppTextField(
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                    ),
                    keyboardType: TextInputType.text,
                    controller: nameController,
                    label: 'اسم المورد',
                    textInputAction: TextInputAction.next,
                    validator: Validator.validateName(),
                  ),
                  Gap(16.h),
                  AppTextField(
                    controller: storeNameController,
                    keyboardType: TextInputType.text,
                    label: 'اسم المتجر / الشركة',
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(
                      Icons.storefront_outlined,
                      color: AppColors.primary,
                    ),
                    validator: Validator.validateStoreName(),
                  ),
                  Gap(16.h),
                  AppTextField(
                    controller: storeAddressController,
                    keyboardType: TextInputType.streetAddress,
                    label: 'عنوان المتجر',
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  Gap(16.h),
                  AppTextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    label: 'رقم الهاتف',
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(
                      Icons.phone_android_outlined,
                      color: AppColors.primary,
                    ),
                    validator: Validator.validatePhone(),
                  ),

                  Gap(32.h),

                  AppButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        late final SupplierModel supplier;
                        if (isEditing) {
                          supplier = widget.supplier!.copyWith(
                            name: nameController.text.trim(),
                            storeName: storeNameController.text.trim(),
                            storeAdd: storeAddressController.text.trim(),
                            phoneNum: phoneController.text.trim(),
                          );
                          showSnackBar(
                            context,
                            'تم تعديل المورد بنجاح',
                            color: AppColors.success,
                          );
                        } else {
                          supplier = SupplierModel(
                            name: nameController.text.trim(),
                            storeName: storeNameController.text.trim(),
                            storeAdd: storeAddressController.text.trim(),
                            phoneNum: phoneController.text.trim(),
                          );
                          showSnackBar(
                            context,
                            "تم اضافة المورد بنجاح",
                            color: AppColors.success,
                          );
                        }

                        context.read<SupplierCubit>().updateSupplier(supplier);

                        AppNavigation.pop(context);
                      }
                    },
                    child: Text(
                      isEditing ? 'تعديل المورد' : "اضافة مورد",
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
}
