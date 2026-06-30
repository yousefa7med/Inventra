
import 'dart:io';

import 'package:Inventra/core/models/product_model.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final ProductModel product;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 65.w,
            height: 65.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey[100],
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
                    color: Colors.grey,
                    size: 28.r,
                  ),
          ),

          Gap(12.w),

          // تفاصيل المنتج
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyle.medium16.copyWith(color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Text(
                  "الباركود: ${product.barcode}",
                  style: AppTextStyle.regular14.copyWith(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const Gap(4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "الكمية: ${product.quantity}",
                      style: AppTextStyle.medium14.copyWith(
                        color: product.quantity > 5
                            ? Colors.black54
                            : Colors.red,
                      ),
                    ),
                    Text(
                      "${product.saleingPrice} ج.م",
                      style: AppTextStyle.bold14.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
