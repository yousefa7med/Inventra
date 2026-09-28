import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/dashboard/data/enums/dashboard_period.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardPeriodSelector extends StatefulWidget {
  final DashboardPeriod selectedPeriod;
  final ValueChanged<DashboardPeriod> onPeriodChanged;
  const DashboardPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  State<DashboardPeriodSelector> createState() =>
      _DashboardPeriodSelectorState();
}

class _DashboardPeriodSelectorState extends State<DashboardPeriodSelector> {
  final periods = DashboardPeriod.values;
  late int _selectedIndex;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedPeriod.index;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(periods.length, (index) {
        final isSelected = _selectedIndex == index;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == periods.last.index ? 0.w : 8.w,
            ),
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onPeriodChanged(periods[index]);
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
                periods[index].label,
                style: AppTextStyle.medium12.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.darkBlue,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
