import 'dart:io';

import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddProductImageWidget extends StatelessWidget {
  const AddProductImageWidget({super.key, required this.onTap});
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
          radius: 55.r,
          child: Icon(
            Icons.add_a_photo_outlined,
            size: 45.r,
            color: AppColors.primary,
          ),
        ),
        InkWell(
          onTap: onTap,
          child: CircleAvatar(
            radius: 16.r,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.add, size: 18.r, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.imagePath});
  final String imagePath;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(imagePath)),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
