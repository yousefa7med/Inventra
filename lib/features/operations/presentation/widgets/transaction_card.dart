import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gap/gap.dart';

class TransactionCard extends StatelessWidget {
  final TransactionsEntry invoice;
  final VoidCallback onTap;
  final Color color;
  final String title;
  final String subTitle;
  final IconData icon;

  const TransactionCard({
    super.key,
    required this.onTap,
    required this.invoice,
    required this.color,
    required this.title,
    required this.subTitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 45.r,
                    height: 45.r,
                    decoration: BoxDecoration(
                      color: color.withAlpha(40),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(icon, color: color, size: 24.r),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: AppTextStyle.medium14,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              ' ${invoice.id + 1}#',
                              style: AppTextStyle.regular12.copyWith(
                                color: AppColors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Text(
                              subTitle,
                              style: AppTextStyle.semiBold12.copyWith(
                                color: Colors.black45,
                              ),
                            ),
                            Text(
                              invoice.userName ?? "",
                              style: AppTextStyle.semiBold12.copyWith(
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          formatDateTime(invoice.timestamp),
                          style: AppTextStyle.regular12.copyWith(
                            fontSize: 8.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatCurrency(invoice.amount),
                    style: AppTextStyle.semiBold14.copyWith(
                      color: invoice.amount > 0
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
