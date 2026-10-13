import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/models/supplier_model.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/features/suppliers/controller/cubit/supplier_cubit.dart';
import 'package:Inventra/features/suppliers/presentation/widgets/supplier_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SupplierList extends StatelessWidget {
  const SupplierList({super.key, required this.suppliers});
  final List<SupplierModel> suppliers;

  @override
  Widget build(BuildContext context) {
    if (suppliers.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyStateWidget(
          icon: Icons.person_off_outlined,
          message: context.read<SupplierCubit>().searchQuery.isNotEmpty
              ? 'لا توجد نتائج للبحث'
              : 'لا يوجد موردين',
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      sliver: SliverList.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return SupplierCard(
            supplier: supplier,
            onEditTap: () => AppNavigation.pushName(
              context: context,
              route: AppRoutes.supplierFormView,
              argument: supplier,
            ),
          );
        },
      ),
    );
  }
}
