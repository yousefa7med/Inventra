import 'package:Inventra/core/helper/arabic_normalizer.dart';
import 'package:Inventra/core/models/supplier_model.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SupplierDropdownMenu extends StatefulWidget {
  const SupplierDropdownMenu({super.key});

  @override
  State<SupplierDropdownMenu> createState() => _SupplierDropdownMenuState();
}

class _SupplierDropdownMenuState extends State<SupplierDropdownMenu> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();
    focusNode.addListener(_onFocusChange);
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
      _selectSupplierIfMatched();
    }
  }

  void _selectSupplierIfMatched() {
    final cubit = context.read<BuyInvoiceCubit>();
    final enteredText = controller.text.trim().toLowerCase().normalizeArabic();

    if (enteredText.isEmpty) return;

    try {
      final matchedSupplier = cubit.suppliers.firstWhere(
        (s) =>
            s.name.trim().toLowerCase().normalizeArabic() ==
            enteredText,
      );

      if (cubit.selectedSupplier != matchedSupplier) {
        cubit.selectSupplier(matchedSupplier);
      }
    } catch (_) {
      cubit.clearSupplier();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BuyInvoiceCubit>();

    return DropdownMenu<SupplierModel>(
      enableSearch: true,
      requestFocusOnTap: true,
      enableFilter: true,
      initialSelection: cubit.selectedSupplier,
      controller: controller,
      focusNode: focusNode,
      hintText: 'اختر المورد',
      textStyle: AppTextStyle.regular14,
      dropdownMenuEntries: cubit.suppliers
          .map(
            (s) => DropdownMenuEntry<SupplierModel>(
              value: s,
              label: s.name,
              leadingIcon: const Icon(Icons.local_shipping_outlined, color: AppColors.grey),
              trailingIcon: s.phoneNum.isNotEmpty
                  ? const Icon(Icons.phone, size: 16, color: AppColors.grey)
                  : null,
              style: ButtonStyle(
                textStyle: WidgetStatePropertyAll(AppTextStyle.regular12),
              ),
            ),
          )
          .toList(),
      onSelected: (supplier) {
        if (supplier != null) {
          cubit.selectSupplier(supplier);
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