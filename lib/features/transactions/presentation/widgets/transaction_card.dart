import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/models/manual_adjustment_model.dart';
import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/models/transactions_entry.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utils/formatters.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/app_button.dart';
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
            if (transaction.type == TransactionType.sellingInvoice ||
                transaction.type == TransactionType.buyingInvoice ||
                transaction.type == TransactionType.returnReceipt) {
              final invoice = context
                  .read<TransactionsCubit>()
                  .getInvoiceDetails(
                    type: transaction.type,
                    id: transaction.referenceId,
                  );
              AppNavigation.pushName(
                rootNavigator: true,
                context: context,
                route: AppRoutes.invoiceDetailsView,
                argument: invoice,
              );
            } else if (transaction.type == TransactionType.manualAdjustment) {
              final adjustment = context
                  .read<TransactionsCubit>()
                  .getManualAdjustment(transaction.referenceId);
              _showManualAdjustmentDialog(context, adjustment);
            } else if (transaction.type == TransactionType.expense) {
              _showExpenseDialog(context, transaction);
            } else {
              // TODO:
            }
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

  void _showExpenseDialog(BuildContext context, TransactionsEntry transaction) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('تفاصيل المصروف', style: AppTextStyle.bold16),
              Gap(20.h),
              // Value
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Text(
                      'المبلغ',
                      style: AppTextStyle.regular14.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    Gap(8.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatCurrency(transaction.value),
                        style: AppTextStyle.bold20.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (transaction.description != null &&
                  transaction.description!.isNotEmpty) ...[
                Gap(16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 16.w,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withAlpha(20),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملاحظة',
                        style: AppTextStyle.regular14.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      Gap(8.h),
                      Text(
                        transaction.description!,
                        style: AppTextStyle.regular16,
                      ),
                    ],
                  ),
                ),
              ],
              Gap(20.h),
              // Close button
              AppButton(
                child: Text(
                  'إغلاق',
                  style: AppTextStyle.semiBold16.copyWith(
                    color: AppColors.white,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManualAdjustmentDialog(
    BuildContext context,
    ManualAdjustmentModel adjustment,
  ) {
    final isIncrease = adjustment.newBalanceValue > adjustment.prevBalanceValue;
    final difference =
        (adjustment.newBalanceValue - adjustment.prevBalanceValue).abs();
    final arrowColor = isIncrease ? AppColors.success : AppColors.error;
    final arrowIcon = isIncrease ? Icons.arrow_upward : Icons.arrow_downward;
    final diffText = isIncrease ? '+$difference' : '-$difference';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('تعديل يدوي', style: AppTextStyle.bold16),
                Gap(20.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Previous Balance
                      Column(
                        children: [
                          Text(
                            'الرصيد السابق',
                            style: AppTextStyle.regular14.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                          Gap(4.h),
                          Text(
                            formatCurrency(adjustment.prevBalanceValue),
                            style: AppTextStyle.semiBold16,
                          ),
                        ],
                      ),
                      Gap(16.w),
                      // Arrow
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: arrowColor.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(arrowIcon, color: arrowColor, size: 28.r),
                      ),
                      Gap(16.w),
                      // New Balance
                      Column(
                        children: [
                          Text(
                            'الرصيد الجديد',
                            style: AppTextStyle.regular14.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                          Gap(4.h),
                          Text(
                            formatCurrency(adjustment.newBalanceValue),
                            style: AppTextStyle.semiBold16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Gap(16.h),
                // Difference
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: arrowColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(arrowIcon, color: arrowColor, size: 20.r),
                      Gap(8.w),
                      Text(
                        diffText,
                        style: AppTextStyle.semiBold16.copyWith(
                          color: arrowColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(20.h),
                // Note if exists
                if (adjustment.note != null && adjustment.note!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.grey.withAlpha(20),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ملاحظة',
                          style: AppTextStyle.regular12.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                        Gap(4.h),
                        Text(adjustment.note!, style: AppTextStyle.regular14),
                      ],
                    ),
                  ),
                  Gap(16.h),
                ],

                // Close button
                AppButton(
                  child: Text(
                    'إغلاق',
                    style: AppTextStyle.semiBold16.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
