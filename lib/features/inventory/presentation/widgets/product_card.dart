import 'dart:io';
import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/helper/app_dialog.dart';
import 'package:Inventra/core/models/product_details_argument.dart';
import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/features/inventory/controller/cubit/product_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductModel product;

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
      child: Column(
        children: [
          Row(
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
                    const Gap(4),

                    Row(
                      children: [
                        Icon(
                          Icons.qr_code_scanner_outlined,
                          size: 14.r,
                          color: AppColors.grey,
                        ),
                        Gap(4.w),
                        Text(
                          (product.barcode != null &&
                                  product.barcode!.isNotEmpty)
                              ? product.barcode!
                              : "لا يوجد باركود",
                          style: AppTextStyle.regular12.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),

                    Text(
                      isOutOfStock
                          ? "نفذت الكمية"
                          : "المتاح: ${product.quantity}",
                      style: AppTextStyle.medium14.copyWith(
                        fontSize: 11.sp,
                        color: isOutOfStock
                            ? AppColors.red
                            : (product.quantity > 5
                                  ? AppColors.primary
                                  : AppColors.warning),
                      ),
                    ),
                    const Gap(8),
                  ],
                ),
              ),

              Gap(4.w),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      AppNavigation.pushName(
                        rootNavigator: true,
                        context: context,
                        route: AppRoutes.productFormView,
                        argument: ProductDetailsArguments(product: product),
                      );
                    },
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
                    onPressed: () {
                      appDialog(
                        context: context,
                        title: 'تأكيد الحذف',
                        content: 'هل أنت متأكد من حذف "${product.name}"؟',
                        msg: 'حذف',
                        action: () {
                          context.read<ProductCubit>().deleteProduct(product);
                        },
                      );
                    },
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPriceRow(
                label: "شراء",
                price: product.buyingPrice,
                color: AppColors.greyMedium500,
              ),
              _buildPriceRow(
                label: "جملة",
                price: product.wholesalePrice,
                color: AppColors.greyMedium500,
              ),

              _buildPriceRow(
                label: "بيع",
                price: product.sellingPrice,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required double price,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.regular14.copyWith(
            fontSize: 10.sp,
            color: AppColors.greyMedium500,
          ),
        ),
        const Gap(4),
        Text(
          "${price.toStringAsFixed(1)} ج.م",
          style: AppTextStyle.bold14.copyWith(fontSize: 12.sp, color: color),
        ),
      ],
    );
  }
}
