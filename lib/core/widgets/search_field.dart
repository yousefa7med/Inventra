import 'dart:async';

import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/assets.dart';
import 'package:Inventra/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.searchFunction,
    required this.clearFunction,
    required this.hintText,
    this.showScanButton = false,
  });
  final void Function(String q) searchFunction;
  final void Function() clearFunction;
  final String? hintText;
  final bool showScanButton;
  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  Timer? timer;
  late final TextEditingController _controller;
  bool prevIsEmpty = true;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> _scanAndApply() async {
    final code = await AppNavigation.pushName<String>(
      context: context,
      route: AppRoutes.barcodeScannerView,
    );
    if (!mounted || code == null || code.isEmpty) return;
    timer?.cancel();
    _controller.text = code;
    widget.searchFunction(code);
    setState(() {
      prevIsEmpty = false;
    });
  }

  void _clear() {
    _controller.clear();
    widget.clearFunction();
    setState(() {
      prevIsEmpty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;
    return AppTextField(
      textInputAction: TextInputAction.search,
      controller: _controller,
      hintText: widget.hintText,
      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
      suffixIcon: hasText
          ? IconButton(
              icon: const Icon(Icons.clear, color: AppColors.grey),
              onPressed: _clear,
            )
          : (widget.showScanButton
                ? IconButton(
                    tooltip: AppStrings.scanBarcode,
                    icon: SvgPicture.asset(
                      Assets.imagesBarcodeScanner,
                      width: 24.w,
                      height: 24.h,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: _scanAndApply,
                  )
                : null),
      onChanged: (q) {
        final isEmpty = q.isEmpty;

        if (isEmpty != prevIsEmpty) {
          setState(() {
            prevIsEmpty = isEmpty;
          });
        }
        if (timer?.isActive ?? false) {
          timer!.cancel();
        }
        timer = Timer(const Duration(milliseconds: 300), () {
          widget.searchFunction(q);
        });
      },
    );
  }
}
