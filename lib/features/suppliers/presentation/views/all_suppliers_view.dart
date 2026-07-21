import 'dart:async';

import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/core/widgets/empty_state_widget.dart';
import 'package:Inventra/core/widgets/search_field.dart';
import 'package:Inventra/features/suppliers/controller/cubit/supplier_cubit.dart';
import 'package:Inventra/features/suppliers/presentation/widgets/supplier_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AllSuppliersView extends StatefulWidget {
  const AllSuppliersView({super.key});

  @override
  State<AllSuppliersView> createState() => _AllSuppliersViewState();
}

class _AllSuppliersViewState extends State<AllSuppliersView> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _searchSuppliers(String query) {
    final cubit = context.read<SupplierCubit>();
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(
      const Duration(milliseconds: 300),
      () => cubit.searchSuppliers(query),
    );
  }

  void _clearSearch() {
    final cubit = context.read<SupplierCubit>();
    _searchController.clear();
    cubit.searchQuery = '';
    cubit.loadSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SupplierCubit>();
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              title: CustomAppBar(title: 'جميع الموردين'),
              automaticallyImplyLeading: false,
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Gap(16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SearchField(
                      searchController: _searchController,
                      searchFunction: _searchSuppliers,
                      clearFunction: _clearSearch,
                      hintText: 'ابحث بالاسم...',
                    ),
                  ),
                  Gap(16.h),
                ],
              ),
            ),
            BlocBuilder<SupplierCubit, SupplierState>(
              buildWhen: (previous, current) =>
                  current is SupplierLoading ||
                  current is SupplierLoadingSuccessed ||
                  current is SupplierLoadingError ||
                  current is SupplierUpdated,
              builder: (context, state) {
                if (state is SupplierLoading) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is SupplierLoadingError) {
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
                                context.read<SupplierCubit>().loadSuppliers(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is SupplierLoadingSuccessed ||
                    state is SupplierUpdated) {
                  final suppliers = cubit.filteredSuppliers;

                  if (suppliers.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateWidget(
                        icon: Icons.person_off_outlined,
                        message: cubit.searchQuery.isNotEmpty
                            ? 'لا توجد نتائج للبحث'
                            : 'لا يوجد موردين',
                        actionText: 'إضافة مورد',
                        onAction: () => AppNavigation.pushName(
                          context: context,
                          route: AppRoutes.supplierFormView,
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

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }
}
