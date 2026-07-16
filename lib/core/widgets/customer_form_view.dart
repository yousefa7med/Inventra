import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/helper/functions.dart';
import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/utils/validators.dart';
import 'package:Inventra/core/widgets/app_button.dart';
import 'package:Inventra/core/widgets/app_text_field.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';

class CustomerFormView extends StatefulWidget {
  const CustomerFormView({super.key, this.customer});
  final CustomerModel? customer;

  @override
  State<CustomerFormView> createState() => _CustomerFormViewState();
}

class _CustomerFormViewState extends State<CustomerFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final bool isEditing;

  @override
  void initState() {
    super.initState();
    isEditing = widget.customer != null;
    nameController = TextEditingController(text: widget.customer?.name);
    phoneController = TextEditingController(text: widget.customer?.phoneNum);
    addressController = TextEditingController(
      text: widget.customer?.address ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: isEditing ? 'تعديل العميل' : "اضافة عميل"),
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
                    label: 'اسم العميل',
                    textInputAction: TextInputAction.next,
                    validator: Validator.validateName(),
                  ),
                  Gap(16.h),
                  AppTextField(
                    prefixIcon: const Icon(
                      Icons.phone_android_outlined,
                      color: AppColors.primary,
                    ),
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    label: 'رقم الهاتف',
                    textInputAction: TextInputAction.next,
                    validator: Validator.validatePhone(),
                  ),
                  Gap(16.h),
                  AppTextField(
                    controller: addressController,
                    keyboardType: TextInputType.streetAddress,
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                    label: "العنوان (اختياري)",
                    textInputAction: TextInputAction.done,
                  ),

                  Gap(32.h),
                  AppButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        late final CustomerModel customer;
                        if (!isEditing) {
                          customer = CustomerModel(
                            name: nameController.text.trim(),
                            address: addressController.text.trim(),
                            phoneNum: phoneController.text.trim(),
                          );
                        } else {
                          customer = widget.customer!.copyWith(
                            name: nameController.text.trim(),
                            address: addressController.text.trim(),
                            phoneNum: phoneController.text.trim(),
                          );
                        }
                        updateCustomer(customer);
                        if (!isEditing) {
                          showSnackBar(
                            context,
                            "تم اضافة العميل بنجاح",
                            color: AppColors.success,
                          );
                        } else {
                          showSnackBar(
                            context,
                            'تم تعديل العميل بنجاح',
                            color: AppColors.success,
                          );
                        }

                        AppNavigation.pop(context: context);
                      }
                    },
                    child: Text(
                      !isEditing ? "اضافة عميل" : 'تعديل العميل',
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

  void updateCustomer(CustomerModel customer) {
    GetIt.instance<ObjectBoxServices>().customersBox.put(customer);
  }
}
