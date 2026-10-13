import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/features/customers/controller/cubit/customer_cubit.dart';
import 'package:Inventra/features/customers/presentation/widgets/customer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomersList extends StatelessWidget {
  const CustomersList({super.key, required this.customers});
  final List<CustomerModel> customers;
  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyStateWidget(
          icon: Icons.person_off_outlined,
          message: context.read<CustomerCubit>().searchQuery.isNotEmpty
              ? 'لا توجد نتائج للبحث'
              : 'لا يوجد عملاء',
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      sliver: SliverList.builder(
        itemCount: customers.length,

        itemBuilder: (context, index) {
          final customer = customers[index];
          return CustomerCard(customer: customer);
        },
      ),
    );
  }
}
