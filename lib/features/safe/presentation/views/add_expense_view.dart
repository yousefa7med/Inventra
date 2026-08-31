import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utils/validators.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/app_button.dart';
import 'package:Inventra/core/widgets/app_text_field.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit.dart';
import 'package:gap/gap.dart';

class AddExpenseView extends StatelessWidget {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AddExpenseViewBody();
  }
}

class _AddExpenseViewBody extends StatefulWidget {
  const _AddExpenseViewBody();

  @override
  State<_AddExpenseViewBody> createState() => _AddExpenseViewBodyState();
}

class _AddExpenseViewBodyState extends State<_AddExpenseViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<SafeCubit>();
    cubit.addExpense(
      value: double.parse(_valueController.text),
      note: _noteController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'إضافة مصروف'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('القيمة', style: AppTextStyle.regular18),
                const Gap(8),
                AppTextField(
                  controller: _valueController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  label: 'مثال: 150.50',
                  validator: Validator.validateExpense(
                    (context.read<SafeCubit>().state as SafeLoaded).safeBalance,
                  ),
                ),
                const Gap(12),
                Text('الملاحظة', style: AppTextStyle.regular18),
                const Gap(8),
                AppTextField(
                  textInputAction: TextInputAction.done,

                  controller: _noteController,
                  label: 'مثال: مصاريف نقل',
                  validator: (value) =>
                      Validator.requiredField(value, "الملاحظة"),
                ),
                const Gap(12),
                AppButton(
                  onPressed: () {
                    _saveExpense();
                    AppNavigation.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                 
                      Text(
                        'حفظ',
                        style: AppTextStyle.medium20.copyWith(
                          color: Colors.white,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
