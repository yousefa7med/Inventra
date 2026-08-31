import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/app_text_field.dart';
import 'package:Inventra/features/safe/controller/cubit/safe_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AdjustBalanceDialog extends StatefulWidget {
  const AdjustBalanceDialog({super.key});

  @override
  State<AdjustBalanceDialog> createState() => _AdjustBalanceDialogState();
}

class _AdjustBalanceDialogState extends State<AdjustBalanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool _adjustBalance() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<SafeCubit>();
      cubit.adjustBalance(
        newBalance: double.parse(_valueController.text.trim()),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تعديل الرصيد', style: AppTextStyle.medium20),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الرصيد الجديد',
                  style: AppTextStyle.regular14.copyWith(fontSize: 15.sp),
                ),
                const Gap(8),
                AppTextField(
                  controller: _valueController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  label: 'مثال: 5000.00',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرصيد مطلوب';
                    }
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null) {
                      return 'رقم غير صالح';
                    }
                    if (parsed > 999999999.99 || parsed < 0) {
                      return 'القيمة خارج النطاق المسموح';
                    }
                    return null;
                  },
                ),
                const Gap(16),
                Text(
                  'ملاحظة (اختياري)',
                  style: AppTextStyle.regular14.copyWith(fontSize: 15.sp),
                ),
                const Gap(8),
                AppTextField(
                  controller: _noteController,
                  label: 'مثال: رصيد افتتاحي',
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              () => AppNavigation.pop(context),
          child: Text(
            'إلغاء',
            style: AppTextStyle.medium14.copyWith(color: AppColors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_adjustBalance()) {
              AppNavigation.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'تأكيد',
            style: AppTextStyle.medium14.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
