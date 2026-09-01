import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/models/invoice_item_model.dart';
import 'package:Inventra/core/models/transaction_type.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/utils/formatters.dart';
import 'package:Inventra/core/utils/phone_utils.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/features/transactions/data/models/invoice_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class InvoiceDetailsView extends StatefulWidget {
  final InvoiceDetailsModel invoice;
  const InvoiceDetailsView({super.key, required this.invoice});

  @override
  State<InvoiceDetailsView> createState() => _InvoiceDetailsViewState();
}

class _InvoiceDetailsViewState extends State<InvoiceDetailsView> {
  late final Color color;
  late final bool isSelling;

  @override
  void initState() {
    if (widget.invoice.type == TransactionType.sellingInvoice) {
      color = AppColors.success;
      isSelling = true;
    } else {
      color = AppColors.primary;
      isSelling = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: (widget.invoice.type == TransactionType.sellingInvoice)
            ? AppStrings.sellInvoice
            : AppStrings.buyInvoice,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              sliver: SliverToBoxAdapter(
                child: _InvoiceHeader(
                  color: color,
                  invoice: widget.invoice,
                  isSelling: isSelling,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverToBoxAdapter(
                child: _InvoiceItemsCard(items: widget.invoice.items),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
              sliver: SliverToBoxAdapter(
                child: _InvoiceTotals(
                  items: widget.invoice.items,
                  color: color,
                  discount: widget.invoice.discount ?? 0,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _StickyTotalsBar(
        isSelling: isSelling,
        color: color,
        total: widget.invoice.total,
        itemCount: widget.invoice.items.length,
      ),
    );
  }
}

class _InvoiceHeader extends StatelessWidget {
  final Color color;
  final InvoiceDetailsModel invoice;
  final bool isSelling;

  const _InvoiceHeader({
    required this.color,
    required this.invoice,
    required this.isSelling,
  });

  @override
  Widget build(BuildContext context) {
    final entityLabel = isSelling ? AppStrings.customer : AppStrings.supplier;
    final entityIcon = isSelling
        ? Icons.person_outline_rounded
        : Icons.local_shipping_outlined;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isSelling
                      ? Icons.shopping_cart_checkout_rounded
                      : Icons.inventory_2_rounded,
                  color: Colors.white,
                  size: 22.r,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSelling
                          ? AppStrings.sellInvoice
                          : AppStrings.buyInvoice,
                      style: AppTextStyle.semiBold16.copyWith(color: color),
                    ),
                    Gap(2.h),
                    Text(
                      formatDateTime(invoice.date),
                      style: AppTextStyle.medium11,
                    ),
                  ],
                ),
              ),
              Text(
                '#${invoice.id}',
                style: AppTextStyle.semiBold16.copyWith(color: color),
              ),
            ],
          ),
          Gap(16.h),
          Divider(color: color.withValues(alpha: 0.3), height: 1, thickness: 1),
          Gap(16.h),

          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(entityIcon, size: 18.r, color: color),
                      Gap(8.w),
                      Text(
                        entityLabel,
                        style: AppTextStyle.bold16.copyWith(color: color),
                      ),
                    ],
                  ),
                  Text(
                    invoice.personName,
                    style: AppTextStyle.medium14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              const Spacer(),
              _CallButton(
                phoneNumber: invoice.personPhoneNum,
                accentColor: color,
                onPressed: () async {
                  await PhoneUtils.launchDialer(invoice.personPhoneNum);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final String phoneNumber;
  final Color accentColor;
  final VoidCallback onPressed;

  const _CallButton({
    required this.phoneNumber,
    required this.accentColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone_rounded, size: 16.r, color: accentColor),
            Gap(6.w),
            Text(
              AppStrings.call,
              style: AppTextStyle.medium12.copyWith(color: accentColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceItemsCard extends StatelessWidget {
  final List<InvoiceItemModel> items;

  const _InvoiceItemsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.greyMedium200),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTextStyle.medium16,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Gap(12.w),
                    Text(
                      '${item.quantity} × ${formatCurrency(item.unitPrice, useCurrencySymbol: true, reduceDecimalDigits: true)}',
                      style: AppTextStyle.regular14.copyWith(
                        color: AppColors.greyMedium500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  color: AppColors.greyMedium200,
                  height: 1,
                  thickness: 1,
                  indent: 16.w,
                  endIndent: 16.w,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InvoiceTotals extends StatelessWidget {
  final List<InvoiceItemModel> items;
  final Color color;
  final double discount;
  const _InvoiceTotals({
    required this.items,
    required this.color,
    this.discount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.lineTotal);
    final total = subtotal - discount;

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        children: [
          _TotalsRow(
            label: AppStrings.subtotal,
            value: formatCurrency(subtotal, reduceDecimalDigits: true),
            valueStyle: AppTextStyle.semiBold16,
          ),
          if (discount > 0) ...[
            Gap(12.h),
            _TotalsRow(
              label: AppStrings.discount,
              value: '-${formatCurrency(discount, reduceDecimalDigits: true)}',
              valueStyle: AppTextStyle.semiBold14.copyWith(
                color: AppColors.error,
              ),
              labelStyle: AppTextStyle.medium14.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
          Gap(16.h),
          const Divider(
            color: AppColors.greyMedium200,
            height: 1,
            thickness: 1,
          ),
          Gap(16.h),
          _TotalsRow(
            label: AppStrings.total,
            value: formatCurrency(
              total,
              reduceDecimalDigits: true,
              useCurrencySymbol: true,
            ),
            valueStyle: AppTextStyle.bold24.copyWith(color: color),
            labelStyle: AppTextStyle.medium16.copyWith(
              color: AppColors.greyMedium500,
            ),
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle valueStyle;
  final TextStyle? labelStyle;
  final bool isTotal;

  const _TotalsRow({
    required this.label,
    required this.value,
    required this.valueStyle,
    this.labelStyle,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              labelStyle ??
              (isTotal
                  ? AppTextStyle.medium16.copyWith(
                      color: AppColors.greyMedium500,
                    )
                  : AppTextStyle.medium14),
        ),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _StickyTotalsBar extends StatelessWidget {
  final bool isSelling;
  final double total;
  final Color color;
  final int itemCount;
  const _StickyTotalsBar({
    required this.isSelling,
    required this.color,
    required this.total,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(
            top: BorderSide(color: AppColors.greyMedium200, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowBlack.withValues(alpha: 0.05),
              blurRadius: 16.r,
              offset: Offset(0, -4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.total,
                    style: AppTextStyle.medium14.copyWith(
                      color: AppColors.greyMedium500,
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    formatCurrency(
                      total,
                      reduceDecimalDigits: true,
                      useCurrencySymbol: true,
                    ),
                    style: AppTextStyle.bold24.copyWith(color: color),
                  ),
                ],
              ),
            ),
            Gap(16.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                '$itemCount ${AppStrings.items}',
                style: AppTextStyle.medium13.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
