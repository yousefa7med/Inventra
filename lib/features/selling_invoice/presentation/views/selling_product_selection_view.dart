import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/core/widgets/search_field.dart';
import 'package:Inventra/features/selling_invoice/controller/cubit/sell_invoice_cubit.dart';
import 'package:Inventra/features/selling_invoice/presentation/widgets/selling_product_list_with_counters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class SellingProductSelectionView extends StatefulWidget {
  const SellingProductSelectionView({super.key});

  @override
  State<SellingProductSelectionView> createState() =>
      _SellingProductSelectionViewState();
}

class _SellingProductSelectionViewState
    extends State<SellingProductSelectionView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: const CustomAppBar(title: AppStrings.addProductToInvoice),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),

              sliver: SliverToBoxAdapter(
                child: SearchField(
                  searchFunction: context.read<SellInvoiceCubit>().loadProducts,
                  clearFunction: () {
                    context.read<SellInvoiceCubit>().loadProducts('');
                  },
                  hintText: "ابحث باسم المنتج أو الباركود...",
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Gap(16)),
            const SellingProductListWithCounters(),
          ],
        ),
      ),
    );
  }
}
