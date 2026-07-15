import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.suffixText,
    this.prefixIcon,
    this.onChanged,
    this.hintText,
    this.focusNode,
    this.onSuffixTap,
  });
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? suffixText;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final VoidCallback? onSuffixTap;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        suffixIcon: (suffixIcon != null || onSuffixTap != null)
          ? InkWell(
              onTap: onSuffixTap,
              child: suffixIcon ?? const Icon(Icons.arrow_drop_down),
            )
          : null,
        suffixText: suffixText,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grey, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelText: label,
        labelStyle: AppTextStyle.regular14,
        hintText: hintText,
      ),
    );
  }
}
