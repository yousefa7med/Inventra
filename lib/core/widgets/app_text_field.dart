import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
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
  final VoidCallback? onSuffixTap;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode focusNode;

  @override
  void initState() {
    focusNode = FocusNode();

    if (widget.controller != null) {
      focusNode.addListener(_onfocusListener);
    }

    super.initState();
  }

  @override
  void dispose() {
    focusNode.removeListener(_onfocusListener);
    focusNode.dispose();

    super.dispose();
  }

  void _onfocusListener() {
    if (focusNode.hasFocus) {
      widget.controller!.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.controller!.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      controller: widget.controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        suffixIcon: (widget.suffixIcon != null || widget.onSuffixTap != null)
            ? InkWell(
                onTap: widget.onSuffixTap,
                child: widget.suffixIcon ?? const Icon(Icons.arrow_drop_down),
              )
            : null,
        suffixText: widget.suffixText,
        prefixIcon: widget.prefixIcon,
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
        labelText: widget.label,
        labelStyle: AppTextStyle.regular14,
        hintText: widget.hintText,
        hintStyle: AppTextStyle.regular14,
      ),
    );
  }
}
