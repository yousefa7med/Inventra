import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_cubit.dart';
import 'package:Inventra/features/buying_invoice/controller/cubit/buy_invoice_state.dart';
import 'package:Inventra/features/buying_invoice/presentation/widgets/invoice_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvoiceProductList extends StatelessWidget {
  const InvoiceProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyInvoiceCubit, dynamic>(
      buildWhen: (prev, curr) =>
          curr is BuyInvoiceAddProduct ||
          curr is BuyInvoiceUpdateProductQuantity ||
          curr is BuyInvoiceRemoveProduct,
      builder: (context, state) {
        final cubit = context.read<BuyInvoiceCubit>();
        if (cubit.items.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('لا توجد منتجات في الفاتورة')),
            ),
          );
        }
        return SliverList.separated(
          itemCount: cubit.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return InvoiceItemTile(
              item: cubit.items[index],
              itemIndex: index,
            );
          },
        );
      },
    );
  }
}