import 'package:Inventra/core/config/configrations.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/core/widgets/error_state_widget.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit.dart';
import 'package:Inventra/features/safe/presentation/widgets/safe_loaded_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SafeView extends StatelessWidget {
  const SafeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'الخزنة', showDrawerButton: true),
        body: RefreshIndicator(
          onRefresh: () async => context.read<SafeCubit>().init(),
          child: BlocBuilder<SafeCubit, SafeState>(
            builder: (context, state) {
              if (state is SafeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is SafeError) {
                return ErrorStateWidget(
                  message: state.message,
                  onPressed: () => context.read<SafeCubit>().init(),
                );
              }

              if (state is SafeLoaded) {
                return  SafeLoadedBody();
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            AppNavigation.pushName(
              rootNavigator: true,
              context: context,
              route: AppRoutes.addExpenseView,
            );
          },
          icon: const Icon(Icons.add),
          label: Text(
            'مصروف',
            style: AppTextStyle.medium16.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
