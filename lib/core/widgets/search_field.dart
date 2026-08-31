import 'dart:async';

import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.searchFunction,
    required this.clearFunction,
    required this.hintText,
  });
  final void Function(String q) searchFunction;
  final void Function() clearFunction;
  final String? hintText;
  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final Timer? timer;
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

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      textInputAction: TextInputAction.search,
      controller: _controller,
      hintText: widget.hintText,
      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
      suffixIcon: _controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear, color: AppColors.grey),
              onPressed: () {
                _controller.clear();
                widget.clearFunction();
                setState(() {
                  prevIsEmpty = true;
                });
              },
            )
          : null,
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
