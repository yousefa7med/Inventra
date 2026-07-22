import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/features/selling_invoice/controller/cubit/sell_invoice_cubit.dart';
import 'package:Inventra/features/selling_invoice/controller/cubit/sell_invoice_state.dart';
import 'package:Inventra/features/selling_invoice/presentation/widgets/selling_product_card_with_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SellingProductListWithCounters extends StatelessWidget {
  const SellingProductListWithCounters({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellInvoiceCubit, SellInvoiceState>(
      buildWhen: (previous, current) =>
          current is SellInvoiceProductLoading ||
          current is SellInvoiceProductSuccessed ||
          current is SellInvoiceProductError,
      builder: (context, state) {
        if (state is SellInvoiceProductLoading) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is SellInvoiceProductError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: AppTextStyle.medium16.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  Gap(16.h),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<SellInvoiceCubit>().loadProducts(""),
                    child: const Text(
                      'إعادة المحاولة',
                      style: AppTextStyle.navBar,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is SellInvoiceProductSuccessed) {
          final cubit = context.read<SellInvoiceCubit>();
          final products = cubit.products;

          if (products.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateWidget(
                icon: Icons.production_quantity_limits_outlined,
                message: cubit.searchQuery.isNotEmpty
                    ? 'لا توجد نتائج للبحث'
                    : 'لا يوجد منتجات',
                actionText: AppStrings.addProduct,
                onAction: () {
                  AppNavigation.pushName(
                    context: context,
                    route: AppRoutes.productFormView,
                  );
                },
              ),
            );
          }
          return SliverPadding(
            sliver: SliverList.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return SellingProductCardWithCounter(product: products[index]);
              },
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
