import 'package:Inventra/core/models/product_details_argument.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'dart:async';

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

class BuyingProductSelectionView extends StatefulWidget {
  const BuyingProductSelectionView({super.key});

  @override
  State<BuyingProductSelectionView> createState() =>
      _BuyingProductSelectionViewState();
}

class _BuyingProductSelectionViewState
    extends State<BuyingProductSelectionView> {
  final controller = TextEditingController();
  Timer? timer;

  @override
  void dispose() {
    controller.dispose();
    timer?.cancel();
    super.dispose();
  }

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
                  searchController: controller,
                  searchFunction: (String value) {
                    if (timer?.isActive ?? false) {
                      timer!.cancel();
                    }
                    timer = Timer(const Duration(milliseconds: 300), () {
                      context.read<BuyInvoiceCubit>().loadProducts(value);
                    });
                  },
                  clearFunction: () {
                    controller.clear();
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
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();

          AppNavigation.pushName(
            context: context,
            route: AppRoutes.productFormView,
            argument: ProductDetailsArguments(isQuantitiyEditable: false),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addProduct, style: AppTextStyle.navBar),
      ),
    );
  }
}
