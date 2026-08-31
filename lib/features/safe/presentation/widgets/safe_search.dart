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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchField(
          searchFunction: context.read<SafeCubit>().searchForExpenses,

          clearFunction: context.read<SafeCubit>().clearSearchFilter,

          hintText: 'بحث بالملاحظة...',
        ),
      ],
    );
  }
}
