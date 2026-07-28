import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/transactions/controller/cubit/transactions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class TransactionsFilter extends StatefulWidget {
  const TransactionsFilter({super.key});

  @override
  State<TransactionsFilter> createState() => _TransactionsFilterState();
}

class _TransactionsFilterState extends State<TransactionsFilter> {
  DateTime? _filterFrom;
  DateTime? _filterTo;

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _filterFrom != null && _filterTo != null
          ? DateTimeRange(start: _filterFrom!, end: _filterTo!)
          : null,
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        _filterFrom = picked.start;
        _filterTo = picked.end;
      });
      if (context.mounted) {
        context.read<TransactionsCubit>().loadTransactions(dateRange: picked);
      }
    }
  }

  void _clearDateFilter() {
    setState(() {
      _filterFrom = null;
      _filterTo = null;
    });
    context.read<TransactionsCubit>().clearDateFilterAndGetTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const FilterChips(),
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    _filterFrom != null && _filterTo != null
                        ? '${DateFormat('dd/MM').format(_filterFrom!)} - ${DateFormat('dd/MM').format(_filterTo!)}'
                        : 'فلترة بالتاريخ',
                    style: AppTextStyle.regular14,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 12.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: BorderSide(
                      color: _filterFrom != null
                          ? AppColors.primary
                          : AppColors.greyMedium400,
                    ),
                  ),
                ),
              ),
              if (_filterFrom != null) ...[
                const Gap(8),
                IconButton(
                  onPressed: _clearDateFilter,
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.error,
                    size: 20,
                  ),
                  tooltip: 'إزالة الفلتر',
                ),
              ],
            ],
          ),
          const Gap(8),
        ],
      ),
    );
  }
}

class FilterChips extends StatefulWidget {
  const FilterChips({super.key});

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  final List<String> _filterTypes = [
    "الكل",
    "فواتير البيع",
    "فواتير الشراء",
    "المصروفات",
    "المرتجعات",
    "تعديل يدوي",
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
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
                setState(() {
                  _selectedIndex = index;
                });
                if (_selectedIndex == 0) {
                  context
                      .read<TransactionsCubit>()
                      .clearTypeFilterAndGetTransactions();
                } else {
                  context.read<TransactionsCubit>().loadTransactions(
                    type: TransactionType.values[_selectedIndex - 1],
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                backgroundColor: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.greyMedium400,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                _filterTypes[index],
                style: AppTextStyle.regular12.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.darkBlue,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
