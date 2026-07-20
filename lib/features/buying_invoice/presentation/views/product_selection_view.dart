import 'dart:async';
import 'dart:developer';

import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/core/widgets/search_field.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:Inventra/features/buying_invoice/presentation/widgets/product_list_with_counters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ProductSelectionView extends StatefulWidget {
  const ProductSelectionView({super.key});

  @override
  State<ProductSelectionView> createState() => _ProductSelectionViewState();
}

class _ProductSelectionViewState extends State<ProductSelectionView> {
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'اختر منتج'),
        body: CustomScrollView(
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
                      log("searching");
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
            const ProductListWithCountersSliver(),
          ],
        ),
      ),
    );
  }
}