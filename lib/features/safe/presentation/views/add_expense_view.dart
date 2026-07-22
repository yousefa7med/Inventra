import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Inventra/core/helper/functions.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utils/result.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/app_button.dart';
import 'package:Inventra/core/widgets/app_text_field.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final cubit = context.read<SafeCubit>();
    final result = await cubit.addExpense(
      value: double.parse(_valueController.text),
      note: _noteController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result is Success<void>) {
        if (mounted) AppNavigation.pop(context);
      } else if (result is Failure<void>) {
        if (mounted) {
          showSnackBar(context, result.message, color: AppColors.error);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'إضافة مصروف'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('القيمة', style: AppTextStyle.regular18),
              const SizedBox(height: 8),
              AppTextField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                label: 'مثال: 150.50',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'القيمة مطلوبة';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'قيمة المصروف يجب أن تكون موجبة';
                  }
                  if (parsed > 999999999.99) {
                    return 'القيمة كبيرة جداً';
                  }
                  if (parsed > context.read<SafeCubit>().currentBalance) {
                    return 'القيمة اكبر من المبلغ في الخزنة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text('الملاحظة', style: AppTextStyle.regular18),
              const SizedBox(height: 8),
              AppTextField(
                textInputAction: TextInputAction.done,

                controller: _noteController,
                label: 'مثال: مصاريف نقل',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الملاحظة مطلوبة';
                  }
                  return null;
                },
              ),
              const Spacer(),
              AppButton(
                onPressed: _isLoading ? () {} : _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
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
    );
  }
}
