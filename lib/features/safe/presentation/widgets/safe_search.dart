import 'dart:async';

import 'package:Inventra/core/widgets/search_field.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SafeSearch extends StatefulWidget {
  const SafeSearch({super.key});
  @override
  State<SafeSearch> createState() => _SafeSearchState();
}

class _SafeSearchState extends State<SafeSearch> {
  final _searchController = TextEditingController();

  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchField(
          searchController: _searchController,
          searchFunction: (query) {
            if (timer?.isActive ?? false) {
              timer!.cancel();
            }
            timer = Timer(const Duration(milliseconds: 300), () {
              context.read<SafeCubit>().searchForExpenses(query);
            });
          },
          clearFunction: () {
            _searchController.clear();

            context.read<SafeCubit>().clearSearchFilter();
          },
          hintText: 'بحث بالملاحظة...',
        ),
      ],
    );
  }
}
