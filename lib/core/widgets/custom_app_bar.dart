import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_global_keys.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/utilities/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.showDrawerButton = false,
    this.actions,
  });

  final String title;
  final bool showDrawerButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: actions,
      leading: showDrawerButton
          ? IconButton(
              icon: Icon(
                Icons.menu_rounded,
                size: 24.r,
                color: AppColors.primary,
              ),
              onPressed: () {
                AppGlobalKeys.mainScaffold.currentState?.openDrawer();
              },
            )
          : null,

      title: Row(
        children: [
          SvgPicture.asset(
            Assets.imagesSvgLogo,
            width: 32.r,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.modulate,
            ),
          ),
          const Gap(8),
          Text(title, style: AppTextStyle.bold18),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
