import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/core/widgets/error_state_widget.dart';
import 'package:Inventra/core/widgets/search_field.dart';
import 'package:Inventra/features/suppliers/controller/cubit/supplier_cubit.dart';
import 'package:Inventra/features/suppliers/presentation/widgets/supplier_list.dart';
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
                      searchFunction: context
                          .read<SupplierCubit>()
                          .searchSuppliers,

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
                  current is SupplierInserted,
              builder: (context, state) {
                switch (state) {
                  case SupplierLoading():
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  case SupplierLoadingError():
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: ErrorStateWidget(
                        message: state.message,
                        onPressed: () =>
                            context.read<SupplierCubit>().loadSuppliers(),
                      ),
                    );
                  case SupplierLoadingSuccessed():
                    return SupplierList(suppliers: state.suppliers);
                  case SupplierInserted():
                    return SupplierList(suppliers: state.suppliers);
                  default:
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            AppNavigation.pushName(
              context: context,
              route: AppRoutes.supplierFormView,
            );
          },
          icon: const Icon(Icons.add),
          label: Text(
            'إضافة مورد',
            style: AppTextStyle.medium16.copyWith(color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
