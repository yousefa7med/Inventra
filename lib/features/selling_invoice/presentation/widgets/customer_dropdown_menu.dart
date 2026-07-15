import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/helper/arabic_normalizer.dart';
import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/selling_invoice/controller/cubit/sell_invoice_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomerDropdownMenu extends StatefulWidget {
  const CustomerDropdownMenu({super.key});

  @override
  State<CustomerDropdownMenu> createState() => _CustomerDropdownMenuState();
}

class _CustomerDropdownMenuState extends State<CustomerDropdownMenu> {
  late final TextEditingController controller;
  late final FocusNode focusNode;
  @override
  void initState() {
    controller = TextEditingController();
    focusNode = FocusNode();
    focusNode.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!focusNode.hasFocus) {
      _selectCustomerIfMatched();
    }
  }

  void _selectCustomerIfMatched() {
    final cubit = context.read<SellInvoiceCubit>();
    final enteredText = controller.text.trim().normalizeArabic();

    if (enteredText.isEmpty) return;

    try {
      final matchedCustomer = cubit.customers.firstWhere(
        (c) =>
            c.name.trim().toLowerCase().normalizeArabic() ==
            enteredText.toLowerCase(),
      );

      // إذا وُجد تطابق، نقوم بتحديث الـ Cubit
      if (cubit.selectedCustomer != matchedCustomer) {
        cubit.selectCustomer(matchedCustomer);
      }
    } catch (_) {
      // إذا لم يجد تطابقاً كاملاً، يمكنك إما تصفير الاختيار أو ترك القيمة السابقة
      cubit.clearCustomer(); // (اختياري)
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SellInvoiceCubit>();

    return DropdownMenu<CustomerModel>(
      enableSearch: true,
      requestFocusOnTap: true,
      enableFilter: true,
      initialSelection: cubit.selectedCustomer,
      controller: controller,
      focusNode: focusNode,
      hintText: AppStrings.selectCustomer,
      textStyle: AppTextStyle.regular14,
      dropdownMenuEntries: cubit.customers
          .map(
            (c) => DropdownMenuEntry<CustomerModel>(
              value: c,
              label: c.name,
              leadingIcon: const Icon(Icons.person, color: AppColors.grey),
              trailingIcon: c.phoneNum.isNotEmpty
                  ? const Icon(Icons.phone, size: 16, color: AppColors.grey)
                  : null,
              style: ButtonStyle(
                textStyle: WidgetStatePropertyAll(AppTextStyle.regular12),
              ),
            ),
          )
          .toList(),
      onSelected: (customer) {
        if (customer != null) {
          cubit.selectCustomer(customer);
        }
      },

      searchCallback: (entries, query) => null,
      trailingIcon: const Icon(Icons.arrow_drop_down),
      expandedInsets: EdgeInsets.zero,
      menuStyle: MenuStyle(
        maximumSize: WidgetStateProperty.all(Size.fromHeight(300.h)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: WidgetStateProperty.all(4),
      ),
    );
  }
}
