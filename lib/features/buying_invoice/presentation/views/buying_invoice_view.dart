import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/helper/functions.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/app_button.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_state.dart';
import 'package:Inventra/features/buying_invoice/presentation/widgets/invoice_product_list.dart';
import 'package:Inventra/features/buying_invoice/presentation/widgets/invoice_totals_card.dart';
import 'package:Inventra/features/buying_invoice/presentation/widgets/supplier_dropdown_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuyingInvoiceView extends StatelessWidget {
  const BuyingInvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: BlocListener<BuyInvoiceCubit, BuyInvoiceState>(
        listenWhen: (prev, curr) =>
            curr is BuyInvoiceError || curr is BuyInvoiceConfirmed,
        listener: (context, state) {
          if (state is BuyInvoiceError) {
            showSnackBar(context, state.message, color: AppColors.error);
          } else if (state is BuyInvoiceConfirmed) {
            showSnackBar(
              context,
              "تم اضافة الفاتورة بنجاح",
              color: AppColors.success,
            );
          }
        },
        child: Scaffold(
          appBar: const CustomAppBar(title: AppStrings.invoiceFormTitle),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Supplier Dropdown
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: SupplierDropdownMenu(),
                  ),
                ),
                // Invoice Product List (uses slivers internally)
                const InvoiceProductList(),
                // Invoice Totals Card
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: InvoiceTotalsCard(),
                  ),
                ),
                // Confirm Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AppButton(
                      onPressed: () async {
                        if (context
                            .read<BuyInvoiceCubit>()
                            .validateBuyInvoice()) {
                          await context
                              .read<BuyInvoiceCubit>()
                              .confirmInvoice();
                          if (context.mounted) {
                            AppNavigation.pop(context: context);
                          }
                        }
                      },
                      child: const Text(
                        AppStrings.confirmInvoice,
                        style: AppTextStyle.navBar,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => AppNavigation.pushName(
              context: context,
              route: AppRoutes.productSelectionView,
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}