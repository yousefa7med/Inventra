import 'dart:async';

import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/search_field.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class SafeSearchAndFilter extends StatefulWidget {
  const SafeSearchAndFilter({
    super.key,
    this.searchFocusNode,
  });
  final FocusNode? searchFocusNode;
  @override
  State<SafeSearchAndFilter> createState() => _SafeSearchAndFilterState();
}

class _SafeSearchAndFilterState extends State<SafeSearchAndFilter> {
  final _searchController = TextEditingController();
  DateTime? _filterFrom;
  DateTime? _filterTo;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    _searchController.dispose();
    super.dispose();
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
    );

    if (picked != null) {
      setState(() {
        _filterFrom = picked.start;
        _filterTo = picked.end;
      });
      if (context.mounted) {
        context.read<SafeCubit>().setDateFilter(
          from: picked.start,
          to: picked.end,
        );
      }
    }
  }

  void _clearDateFilter() {
    setState(() {
      _filterFrom = null;
      _filterTo = null;
    });
    context.read<SafeCubit>().setDateFilter(from: null, to: null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchField(
          searchController: _searchController,
          searchFunction: (query) {
            if (timer?.isActive ?? false) {
              timer!.cancel();
            }
            timer = Timer(const Duration(milliseconds: 500), () {
              context.read<SafeCubit>().setSearchFilter(
                query.isEmpty ? null : query,
              );
            });
          },
          clearFunction: () {
            _searchController.clear();

            context.read<SafeCubit>().setSearchFilter(null);
          },
          hintText: 'بحث بالملاحظة...',
          focusNode: widget.searchFocusNode,
        ),
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
                    vertical: 12.h,
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
                icon: const Icon(Icons.close, color: AppColors.error, size: 20),
                tooltip: 'إزالة الفلتر',
              ),
            ],
          ],
        ),
      ],
    );
  }
}
