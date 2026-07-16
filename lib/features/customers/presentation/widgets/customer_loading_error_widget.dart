import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomerLoadingErrorWidget extends StatelessWidget {
  const CustomerLoadingErrorWidget({
    super.key,
    required this.message,
    required this.onPressed,
  });
  final String message;
  final void Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: AppTextStyle.medium16.copyWith(color: AppColors.error),
          ),
          Gap(16.h),
          ElevatedButton(
            onPressed: onPressed,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
