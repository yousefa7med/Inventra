import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/models/customer_model.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/utils/phone_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.only(top: 8.h, right: 16.w, left: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person,
                    size: 28.r,
                    color: AppColors.primary,
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: AppTextStyle.bold16.copyWith(
                          color: AppColors.black87,
                        ),
                      ),
                      Gap(4.h),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14.r,
                            color: AppColors.grey,
                          ),
                          Gap(4.w),
                          Expanded(
                            child: Text(
                              (customer.address != null &&
                                      customer.address!.isNotEmpty)
                                  ? customer.address!
                                  : 'لا يوجد عنوان',
                              style: AppTextStyle.regular12.copyWith(
                                color: AppColors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => AppNavigation.pushName(
                    context: context,
                    route: AppRoutes.customerFormView,
                    argument: customer,
                  ),
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.secondary,
                    size: 24.r,
                  ),
                  tooltip: 'تعديل',
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 18.r, color: AppColors.grey),
                      Gap(8.w),
                      Expanded(
                        child: Text(
                          customer.phoneNum,
                          style: AppTextStyle.medium14.copyWith(
                            color: AppColors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(16.w),
                IconButton(
                  onPressed: () => PhoneUtils.launchDialer(customer.phoneNum),

                  icon: Icon(Icons.call, color: AppColors.primary, size: 24.r),
                  tooltip: 'اتصال',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
