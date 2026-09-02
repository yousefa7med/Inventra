import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/transactions/controller/cubit/transactions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class TransactionsFilter extends StatelessWidget {
  const TransactionsFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransactionsCubit>();
    final selectedType = cubit.selectedType;
    final dateRange = cubit.selectedDateRange;

    return _FilterBar(
      selectedType: selectedType?.index ?? 0,
      dateRange: dateRange,
      onTypeChanged: (index) {
        if (index == 0) {
          cubit.clearFiltersAndGetTransactions(type: true);
        } else {
          cubit.loadTransactions(type: TransactionType.values[index - 1]);
        }
      },
      onDateSelected: (range) => cubit.loadTransactions(dateRange: range),
      onDateCleared: () => cubit.clearFiltersAndGetTransactions(time: true),
    );
  }
}

class _FilterBar extends StatefulWidget {
  final int selectedType;
  final DateTimeRange? dateRange;
  final Function(int) onTypeChanged;
  final Function(DateTimeRange) onDateSelected;
  final VoidCallback onDateCleared;

  const _FilterBar({
    required this.selectedType,
    required this.dateRange,
    required this.onTypeChanged,
    required this.onDateSelected,
    required this.onDateCleared,
  });

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  late int _selectedIndex;
  late DateTime? _filterFrom;
  late DateTime? _filterTo;

  final List<String> _filterTypes = [
    "الكل",
    "فواتير البيع",
    "فواتير الشراء",
    "المصروفات",
    "المرتجعات",
    "تعديل يدوي",
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedType;
    _filterFrom = widget.dateRange?.start;
    _filterTo = widget.dateRange?.end;
  }

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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            surface: AppColors.surface,
            onSurface: AppColors.black87,
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && context.mounted) {
      setState(() {
        _filterFrom = picked.start;
        _filterTo = picked.end;
      });
      widget.onDateSelected(picked);
    }
  }

  void _clearDateFilter() {
    setState(() {
      _filterFrom = null;
      _filterTo = null;
    });
    widget.onDateCleared();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.greyMedium200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الفلاتر',
            style: AppTextStyle.semiBold14.copyWith(color: AppColors.primary),
          ),
          Gap(12.h),

          // Type filter chips
          SingleChildScrollView(
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
                      widget.onTypeChanged(index);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
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
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.darkBlue,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          Gap(12.h),

          // Date filter
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: Icon(
                    Icons.date_range_rounded,
                    size: 18.r,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    _filterFrom != null && _filterTo != null
                        ? '${DateFormat('dd/MM').format(_filterFrom!)} - ${DateFormat('dd/MM').format(_filterTo!)}'
                        : 'فلترة بالتاريخ',
                    style: AppTextStyle.medium13.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 12.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: BorderSide(
                      color: _filterFrom != null
                          ? AppColors.primary
                          : AppColors.greyMedium300,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              if (_filterFrom != null) ...[
                Gap(8.w),
                IconButton(
                  onPressed: _clearDateFilter,
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.error,
                    size: 20.r,
                  ),
                  tooltip: 'إزالة الفلتر',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
