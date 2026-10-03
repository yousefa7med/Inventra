import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:Inventra/core/widgets/error_state_widget.dart';
import 'package:Inventra/features/dashboard/controller/cubit/dashboard_cubit.dart';
import 'package:Inventra/features/dashboard/controller/cubit/dashboard_state.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_loaded_body.dart';
import 'package:Inventra/features/dashboard/presentation/widgets/dashboard_loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'لوحة التحكم', showDrawerButton: true),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) {
          return current is DashboardLoading ||
              current is DashboardError ||
              (previous is! DashboardLoaded && current is DashboardLoaded);
        },
        builder: (context, state) {
          switch (state) {
            case DashboardLoading():
              return const DashboardLoadingSkeleton();

            case DashboardLoaded():
              return const DashboardLoadedBody();

            case DashboardError():
              return ErrorStateWidget(
                message: state.message,
                onPressed: () => context.read<DashboardCubit>().refresh(),
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
