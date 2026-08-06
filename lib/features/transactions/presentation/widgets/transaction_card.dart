import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utils/formatters.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/transactions/controller/cubit/transactions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class TransactionCard extends StatelessWidget {
  final TransactionsEntry transaction;
  final Color color;
  final String title;
  final String subTitle;
  final IconData icon;

  const TransactionCard({
    super.key,
    required this.transaction,
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
        child: InkWell(
          onTap: () {
            final invoice = context.read<TransactionsCubit>().getInvoiceDetails(
              typeIndex: transaction.type,
              id: transaction.referenceId,
            );
            AppNavigation.pushName(
              rootNavigator: true,
              context: context,
              route: AppRoutes.invoiceDetailsView,
              argument: invoice,
            );
          },
          borderRadius: BorderRadius.circular(12.r),
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
                                ' ${transaction.id + 1}#',
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
                              Expanded(
                                child: Text(
                                  transaction.description ?? "",
                                  style: AppTextStyle.semiBold12.copyWith(
                                    color: color,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            formatDateTime(transaction.timestamp),
                            style: AppTextStyle.regular12.copyWith(
                              fontSize: 8.sp,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      transaction.value.toString(),
                      style: AppTextStyle.semiBold14.copyWith(
                        color: transaction.value > 0
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
      ),
    );
  }
}
