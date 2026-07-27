import 'package:flutter/material.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/widgets/app_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final void Function() onPressed;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'حدث خطأ',
              style: AppTextStyle.bold20.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: AppTextStyle.regular14.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 200.w,
              child: AppButton(
                onPressed: onPressed,
                child: Text('إعادة المحاولة', style: AppTextStyle.bold14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
