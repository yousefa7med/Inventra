import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionsFilter extends StatefulWidget {
  const TransactionsFilter({super.key});

  @override
  State<TransactionsFilter> createState() => _TransactionsFilterState();
}

class _TransactionsFilterState extends State<TransactionsFilter> {
  late int _selectedIndex;

  late final List<String> _filterTypes = [
    "الكل",
    ...TransactionType.values.map((type) => type.arabicLabel),
  ];
  @override
  void initState() {
    super.initState();
    final cubit = context.read<SafeCubit>();
    _selectedIndex = cubit.selectedType?.index ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // Type filter chips
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_filterTypes.length, (index) {
          final isSelected = _selectedIndex == index;

          return Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: OutlinedButton(
              onPressed: () {
                if (_selectedIndex == index) return;
                setState(() {
                  _selectedIndex = index;
                });
                if (index == 0) {
                  context.read<SafeCubit>().loadTransactions();
                } else {
                  context.read<SafeCubit>().loadTransactions(
                    type: TransactionType.values[index - 1],
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                backgroundColor: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.greyMedium300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                _filterTypes[index],
                style: AppTextStyle.medium12.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.darkBlue,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
