import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_state.dart';
import 'package:Inventra/features/buying_invoice/presentation/widgets/buying_product_card_with_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class BuyingProductListWithCounters extends StatelessWidget {
  const BuyingProductListWithCounters({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyInvoiceCubit, BuyInvoiceState>(
      buildWhen: (previous, current) =>
          current is BuyInvoiceProductLoading ||
          current is BuyInvoiceProductsLoaded ||
          current is BuyInvoiceProductError,
      builder: (context, state) {
        if (state is BuyInvoiceProductLoading) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is BuyInvoiceProductError) {
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
                        context.read<BuyInvoiceCubit>().loadProducts(""),
                    child: const Text(
                      'إعادة المحاولة',
                      style: AppTextStyle.navBar,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is BuyInvoiceProductsLoaded) {
          final cubit = context.read<BuyInvoiceCubit>();
          final products = cubit.products;

          if (products.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateWidget(
                icon: Icons.production_quantity_limits_outlined,
                message: cubit.searchQuery.isNotEmpty
                    ? 'لا توجد نتائج للبحث'
                    : 'لا يوجد منتجات',
              ),
            );
          }
          return SliverPadding(
            sliver: SliverList.builder(
              itemCount: cubit.products.length,
              itemBuilder: (context, index) {
                return BuyingProductCardWithCounter(
                  product: cubit.products[index],
                );
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
