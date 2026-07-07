import 'dart:io';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ProductCardWithEdit extends StatelessWidget {
  const ProductCardWithEdit({
    super.key,
    required this.product,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  final ProductModel product;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = product.quantity <= 0;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlack,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75.w,
            height: 75.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.greyLight100,
            ),
            child: product.imgPath != null && product.imgPath!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(
                      File(product.imgPath!),
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.grey,
                    size: 28.r,
                  ),
          ),

          Gap(12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyle.medium16.copyWith(
                    color: AppColors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "الباركود: ${product.barcode ?? 'لا يوجد'}",
                      style: AppTextStyle.regular14.copyWith(
                        color: AppColors.grey,
                        fontSize: 11.sp,
                      ),
                    ),
                    Text(
                      isOutOfStock
                          ? "نفذت الكمية"
                          : "المتاح: ${product.quantity}",
                      style: AppTextStyle.medium14.copyWith(
                        fontSize: 11.sp,
                        color: isOutOfStock
                            ? AppColors.red
                            : (product.quantity > 5
                                  ? AppColors.black54
                                  : AppColors.warning),
                      ),
                    ),
                  ],
                ),
                const Gap(8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPriceColumn(
                      label: "قطاعي",
                      price: product.saleingPrice,
                      color: AppColors.primary,
                    ),

                    _buildPriceColumn(
                      label: "جملة",
                      price: product.wholesalePrice,
                      color: AppColors.secondary,
                    ),

                    _buildPriceColumn(
                      label: "شراء",
                      price: product.buyingPrice,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Gap(4.w),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEditTap,
                icon: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: AppColors.primary,
                    size: 16.r,
                  ),
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                tooltip: "تعديل المنتج",
              ),
              Gap(4.h),
              IconButton(
                onPressed: onDeleteTap,
                icon: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_rounded,
                    color: AppColors.error,
                    size: 16.r,
                  ),
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                tooltip: "حذف المنتج",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceColumn({
    required String label,
    required double price,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.regular14.copyWith(
            fontSize: 10.sp,
            color: AppColors.greyMedium500,
          ),
        ),
        Text(
          "${price.toStringAsFixed(1)} ج.م",
          style: AppTextStyle.bold14.copyWith(fontSize: 12.sp, color: color),
        ),
      ],
    );
  }
}
