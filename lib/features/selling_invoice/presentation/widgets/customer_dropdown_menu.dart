import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/features/selling_invoice/controller/cubit/sell_invoice_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomerDropdownMenu extends StatelessWidget {
  const CustomerDropdownMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SellInvoiceCubit>();
    final selectedCustomer = cubit.selectedCustomer;

    return DropdownMenu<CustomerModel>(
      enableSearch: true,
      requestFocusOnTap: true,
      enableFilter: true,
      initialSelection: selectedCustomer,
      controller: TextEditingController(text: selectedCustomer?.name ?? ''),
      hintText: AppStrings.selectCustomer,
      dropdownMenuEntries: cubit.customers
          .map(
            (c) => DropdownMenuEntry<CustomerModel>(
              value: c,
              label: c.name,
              leadingIcon: const Icon(Icons.person, color: AppColors.grey),
              trailingIcon: c.phoneNum.isNotEmpty
                  ? const Icon(Icons.phone, size: 16, color: AppColors.grey)
                  : null,
            ),
          )
          .toList(),
      onSelected: (customer) {
        if (customer != null) {
          cubit.selectCustomer(customer);
        }
      },

      searchCallback: (entries, query) => null,
      trailingIcon: selectedCustomer != null
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                cubit.clearCustomer();
              },
            )
          : const Icon(Icons.arrow_drop_down),
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
