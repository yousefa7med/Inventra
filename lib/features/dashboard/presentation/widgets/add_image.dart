
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddImage extends StatelessWidget {
  const AddImage({super.key});

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
        CircleAvatar(
          radius: 16.r,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.add, size: 18.r, color: Colors.white),
        ),
      ],
    );
  }
}
