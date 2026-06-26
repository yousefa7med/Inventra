import 'package:Inventra/core/helper/cache_helper.dart';
import 'package:Inventra/core/models/customer_model.dart';
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

class AddCustomerView extends StatefulWidget {
  const AddCustomerView({super.key});

  @override
  State<AddCustomerView> createState() => _AddCustomerViewState();
}

class _AddCustomerViewState extends State<AddCustomerView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  @override
  void initState() {
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    super.initState();
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
        appBar: const CustomAppBar(title: "اضافة عميل"),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
            child: Form(
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
                    label: "اسم العميل",
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "برجاء إدخال اسم العميل";
                      }
                      if (value.trim().length < 3) {
                        return "الاسم يجب أن يكون 3 أحرف على الأقل";
                      }
                      return null;
                    },
                  ),
                  Gap(16.h),
                  AppTextField(
                    prefixIcon: const Icon(
                      Icons.phone_android_outlined,
                      color: AppColors.primary,
                    ),
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    label: "رقم الهاتف",
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "برجاء إدخال رقم الهاتف";
                      }
                      final phoneRegex = RegExp(r'^[0-9+]{7,15}$');
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return "برجاء إدخال رقم هاتف صحيح";
                      }
                      return null;
                    },
                  ),
                  Gap(16.h),
                  AppTextField(
                    controller: addressController,
                    keyboardType: TextInputType.streetAddress,
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                    label: "العنوان",
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "برجاء إدخال العنوان";
                      }
                      return null;
                    },
                  ),

                  Gap(32.h),
                  AppButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final customer = CustomerModel(
                          name: nameController.text.trim(),
                          address: addressController.text.trim(),
                          phoneNum: phoneController.text.trim(),
                        );
                        addCustomer(customer);
                        AppNavigation.pop(context: context);
                      }
                    },
                    child: Text("اضافة عميل", style: AppTextStyle.medium16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void addCustomer(CustomerModel customer) {
    GetIt.instance<ObjectBoxServices>().customersBox.put(customer);
  }
}
