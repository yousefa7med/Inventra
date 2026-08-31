import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/core/widgets/error_state_widget.dart';
import 'package:Inventra/core/widgets/search_field.dart';
import 'package:Inventra/features/customers/controller/cubit/customer_cubit.dart';
import 'package:Inventra/features/customers/presentation/widgets/customer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AllCustomersView extends StatelessWidget {
  const AllCustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              title: CustomAppBar(title: 'جميع العملاء'),
              automaticallyImplyLeading: false,
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Gap(16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SearchField(
                      searchFunction: context
                          .read<CustomerCubit>()
                          .searchCustomers,
                      clearFunction: context
                          .read<CustomerCubit>()
                          .loadCustomers,
                      hintText: 'ابحث بالاسم...',
                    ),
                  ),
                  Gap(16.h),
                ],
              ),
            ),
            BlocBuilder<CustomerCubit, CustomerState>(
              buildWhen: (previous, current) =>
                  current is CustomerLoading ||
                  current is CustomerLoadingSuccessed ||
                  current is CustomerLoadingError ||
                  current is CustomerUpdated,

              builder: (context, state) {
                final cubit = context.read<CustomerCubit>();

                if (state is CustomerLoading) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is CustomerLoadingError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorStateWidget(
                      message: state.message,
                      onPressed: () {
                        cubit.loadCustomers();
                      },
                    ),
                  );
                }

                if (state is CustomerLoadingSuccessed ||
                    state is CustomerUpdated) {
                  final customers = cubit.filteredCustomers;

                  if (customers.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateWidget(
                        icon: Icons.person_off_outlined,
                        message: cubit.searchQuery.isNotEmpty
                            ? 'لا توجد نتائج للبحث'
                            : 'لا يوجد عملاء',
                        actionText: 'إضافة عميل',
                        onAction: () => AppNavigation.pushName(
                          context: context,
                          route: AppRoutes.customerFormView,
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    sliver: SliverList.builder(
                      itemCount: customers.length,

                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return CustomerCard(customer: customer);
                      },
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }
}
