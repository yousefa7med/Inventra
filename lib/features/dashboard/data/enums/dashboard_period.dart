enum DashboardPeriod { today, week, month, year }

extension DashboardPeriodExtension on DashboardPeriod {
  String get label {
    switch (this) {
      case DashboardPeriod.today:
        return 'اليوم';
      case DashboardPeriod.week:
        return 'الأسبوع';
      case DashboardPeriod.month:
        return 'الشهر';
      case DashboardPeriod.year:
        return 'السنة';
    }
  }

  String formmatTime(DateTime timestamp) {
    switch (this) {
      case DashboardPeriod.today:
        return '${timestamp.hour.toString().padLeft(2, '0')}:00';
      case DashboardPeriod.week:
        const days = [
          'سبت',
          'أحد',
          'إثنين',
          'ثلاثاء',
          'أربعاء',
          'خميس',
          'جمعة',
        ];
        return days[(timestamp.weekday + 1) % 7];
      case DashboardPeriod.month:
        return '${timestamp.day}';
      case DashboardPeriod.year:
        const months = [
          'يناير',
          'فبراير',
          'مارس',
          'أبريل',
          'مايو',
          'يونيو',
          'يوليو',
          'أغسطس',
          'سبتمبر',
          'أكتوبر',
          'نوفمبر',
          'ديسمبر',
        ];
        return months[timestamp.month - 1];
    }
  }
}
