import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class DashboardLoadingSkeleton extends StatelessWidget {
  const DashboardLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Shimmer.fromColors(
        baseColor: AppColors.greyMedium300,
        highlightColor: AppColors.greyMedium200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonCard(height: 100.h),

            SizedBox(height: 12.h),
            // Metric KPIs
            GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 2,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _SkeletonCard(height: 100.h),
                _SkeletonCard(height: 100.h),
                _SkeletonCard(height: 100.h),
                _SkeletonCard(height: 100.h),
              ],
            ),
            SizedBox(height: 12.h),
            // Period Selector
            _SkeletonCard(height: 44.h, width: double.infinity),
            SizedBox(height: 12.h),
            // Chart
            _SkeletonCard(height: 280.h, width: double.infinity),
            SizedBox(height: 24.h),
            // Primary Action
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}
