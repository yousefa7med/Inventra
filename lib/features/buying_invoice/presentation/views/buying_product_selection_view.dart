import 'package:Inventra/core/config/arguments/product_details_argument.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/navigations/navigations.dart';

import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/core/widgets/search_field.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:Inventra/features/buying_invoice/presentation/widgets/buying_product_list_with_counters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class BuyingProductSelectionView extends StatelessWidget {
  const BuyingProductSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: AppStrings.addProductToInvoice),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),

              sliver: SliverToBoxAdapter(
                child: SearchField(
                  searchFunction: context.read<BuyInvoiceCubit>().loadProducts,
                  clearFunction: () {
                    context.read<BuyInvoiceCubit>().loadProducts('');
                  },
                  hintText: "ابحث باسم المنتج أو الباركود...",
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Gap(16)),
            const BuyingProductListWithCounters(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          FocusManager.instance.primaryFocus?.unfocus();

          final product = await AppNavigation.pushName<ProductModel>(
            context: context,
            route: AppRoutes.productFormView,
            argument: ProductDetailsArguments(isQuantitiyEditable: false),
          );
          if (product != null) {
            context.read<BuyInvoiceCubit>().insertProduct(product);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addProduct, style: AppTextStyle.navBar),
      ),
    );
  }
}
