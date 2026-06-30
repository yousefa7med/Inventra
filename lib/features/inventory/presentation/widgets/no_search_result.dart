import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class NoSearchResult extends StatelessWidget {
  const NoSearchResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 60.r, color: Colors.grey[400]),
           Gap(12.h),
          Text(
            "لا توجد منتجات مطابقة لبحثك",
            style: AppTextStyle.medium14.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}