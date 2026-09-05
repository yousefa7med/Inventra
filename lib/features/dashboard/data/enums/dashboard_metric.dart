import 'dart:ui';

import 'package:Inventra/core/utilities/app_colors.dart';

enum DashboardMetric { netProfit, sales, purchases, expenses }

extension DashboardMetricExtension on DashboardMetric {
  String get label {
    switch (this) {
      case DashboardMetric.netProfit:
        return 'الارباح';
      case DashboardMetric.sales:
        return 'المبيعات';
      case DashboardMetric.purchases:
        return 'المشتريات';
      case DashboardMetric.expenses:
        return 'المصاريف';
    }
  }

  Color get metricColor {
    switch (this) {
      case DashboardMetric.sales:
        return AppColors.primary;
      case DashboardMetric.purchases:
        return AppColors.secondary;
      case DashboardMetric.expenses:
        return AppColors.error;
      case DashboardMetric.netProfit:
        return AppColors.success;
    }
  }
}