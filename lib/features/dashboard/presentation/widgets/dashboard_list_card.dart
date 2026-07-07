import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DashboardListCard extends StatelessWidget {
  const DashboardListCard({
    super.key,
    required this.iconColor,
    required this.iconBackgronud,
    required this.icon,
    required this.title,
    required this.onPressed,
  });
  final Color iconColor;
  final Color iconBackgronud;
  final IconData icon;
  final String title;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          color: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: iconBackgronud,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const Gap(16),
                Text(title, style: AppTextStyle.bold16),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, color: AppColors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
