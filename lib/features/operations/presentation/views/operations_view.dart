import 'package:Inventra/core/utilities/app_global_keys.dart';
import 'package:Inventra/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class OperationsView extends StatelessWidget {
  const OperationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AppButton(
          onPressed: () {
            AppGlobalKeys.mainScaffold.currentState?.openDrawer();
          },
          child: const Icon(Icons.abc_outlined),
        ),
      ),
    );
  }
}
