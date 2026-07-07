import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.searchController,
    required this.searchFunction,
    required this.clearFunction,
  });
  final TextEditingController searchController;
  final void Function(String q) searchFunction;
  final void Function() clearFunction;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  bool prevIsEmpty = true;
  @override
  Widget build(BuildContext context) {
    return AppTextField(
      textInputAction: TextInputAction.search,
      controller: widget.searchController,
      label: "ابحث باسم المنتج أو الباركود...",
      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
      suffixIcon: widget.searchController.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear, color: AppColors.grey),
              onPressed: () {
                widget.clearFunction();
                setState(() {
                  prevIsEmpty = true;
                });
              },
            )
          : null,
      onChanged: (q) {
        if ((prevIsEmpty && q.isNotEmpty) || (!prevIsEmpty && q.isEmpty)) {
          setState(() {
            prevIsEmpty = q.isEmpty;
          });
        } else {
          prevIsEmpty = q.isEmpty;
        }
        widget.searchFunction(q);
      },
    );
  }
}
