import 'dart:math';
import 'package:Inventra/core/utils/formatters.dart';
import 'package:Inventra/features/dashboard/data/models/chart_point.dart';
import 'package:Inventra/features/dashboard/data/models/dashboard_metric.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardChart extends StatelessWidget {
  const DashboardChart({
    super.key,
    required this.color,
    required this.selectedPeriod,
    required this.points,
    required this.isNetProfit,
  });

  final List<ChartPoint> points;
  final Color color;
  final DashboardPeriod selectedPeriod;
  final bool isNetProfit;
  @override
  Widget build(BuildContext context) {
    final maxValue = points.map((p) => p.value).reduce(max);

    final minValue = points.map((p) => p.value).reduce(min);

    final scale = _calculateScale(minValue: minValue, maxValue: maxValue);

    final spots = points.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return SizedBox(
      height: 280.h,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (points.length - 1).toDouble(),

            minY: scale.minY,
            maxY: scale.maxY,

            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: scale.interval,

              getDrawingHorizontalLine: (value) => const FlLine(
                color: AppColors.greyMedium300,
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
              checkToShowHorizontalLine: (value) => true,
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 32.h,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= points.length) {
                      return const SizedBox.shrink();
                    }
                    return _BottomTitleWidget(
                      timestamp: points[index].timestamp,
                      period: selectedPeriod,
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,

                  reservedSize: 46.w,
                  getTitlesWidget: (value, meta) {
                    return _LeftTitleWidget(value: meta.formattedValue);
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: getLineChartBarData(spots, isNetProfit),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipRoundedRadius: 12.r,
                tooltipPadding: EdgeInsets.all(12.w),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final index = spot.x.toInt();
                    if (index < 0 || index >= points.length) return null;
                    final point = points[index];
                    return LineTooltipItem(
                      '',
                      const TextStyle(),
                      children: [
                        TextSpan(
                          text:
                              '${selectedPeriod.formmatTime(point.timestamp)}\n',
                          style: AppTextStyle.medium12.copyWith(
                            color: AppColors.white70,
                          ),
                        ),
                        TextSpan(
                          text: formatCurrency(point.value),
                          style: AppTextStyle.bold16.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        if (point.count > 0)
                          TextSpan(
                            text: '\n${point.count} معاملات',
                            style: AppTextStyle.regular12.copyWith(
                              color: AppColors.white70,
                            ),
                          ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> getLineChartBarData(
    List<FlSpot> spots,
    bool isNetProfit,
  ) {
    if (!isNetProfit) {
      return [_buildBar(spots: spots, isNegative: false)];
    }

    final bars = <LineChartBarData>[];

    int segmentStart = 0;
    bool isNegative = spots.first.y < 0;

    for (int i = 1; i < spots.length; i++) {
      final currentIsNegative = spots[i].y < 0;

      if (currentIsNegative != isNegative) {
        bars.add(
          _buildBar(
            spots: spots.sublist(segmentStart, i),
            isNegative: isNegative,
          ),
        );

        segmentStart = i;
        isNegative = currentIsNegative;
      }
    }

    // Add the last segment
    bars.add(
      _buildBar(spots: spots.sublist(segmentStart), isNegative: isNegative),
    );

    return bars;
  }

  LineChartBarData _buildBar({
    required List<FlSpot> spots,
    required bool isNegative,
  }) {
    final chartColor = isNegative ? AppColors.error : color;

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
      barWidth: 3,
      isStrokeCapRound: true,

      gradient: LinearGradient(
        colors: [chartColor, chartColor.withValues(alpha: 0.3)],
      ),

      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: chartColor,
            strokeWidth: 2,
            strokeColor: AppColors.white,
          );
        },
      ),

      belowBarData: BarAreaData(
        show: true,
        applyCutOffY: true,
        cutOffY: 0,

        gradient: LinearGradient(
          begin: isNegative ? Alignment.bottomCenter : Alignment.topCenter,
          end: isNegative ? Alignment.topCenter : Alignment.bottomCenter,
          colors: [
            chartColor.withValues(alpha: 0.15),
            chartColor.withValues(alpha: 0.02),
          ],
        ),
      ),
    );
  }
}

class _BottomTitleWidget extends StatelessWidget {
  const _BottomTitleWidget({required this.timestamp, required this.period});

  final DateTime timestamp;
  final DashboardPeriod period;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Text(
        period.formmatTime(timestamp),
        style: AppTextStyle.regular12.copyWith(color: AppColors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _LeftTitleWidget extends StatelessWidget {
  const _LeftTitleWidget({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Text(
        // formatCurrency(value),
        value,
        style: AppTextStyle.regular12.copyWith(color: AppColors.grey),
        textAlign: TextAlign.end,
      ),
    );
  }
}

class _ChartScale {
  const _ChartScale({
    required this.minY,
    required this.maxY,
    required this.interval,
  });

  final double minY;
  final double maxY;
  final double interval;
}

_ChartScale _calculateScale({
  required double minValue,
  required double maxValue,
  int targetIntervals = 5,
}) {
  if (!minValue.isFinite || !maxValue.isFinite) {
    return const _ChartScale(minY: 0, maxY: 1, interval: 1);
  }

  if (minValue == maxValue) {
    if (minValue == 0) {
      return const _ChartScale(minY: 0, maxY: 1, interval: 0.2);
    }

    final absValue = minValue.abs();
    final interval = _calculateNiceInterval(absValue, targetIntervals);

    final bound = (absValue / interval).ceil() * interval;

    return _ChartScale(minY: 0, maxY: bound, interval: interval);
  }

  // عند وجود قيم سالبة:
  // نخلي الـ 0 في المنتصف تمامًا.
  if (minValue < 0) {
    final maxAbs = maxValue.abs() > minValue.abs()
        ? maxValue.abs()
        : minValue.abs();

    final interval = _calculateNiceInterval(maxAbs * 2, targetIntervals);

    final bound = (maxAbs / interval).ceil() * interval;

    return _ChartScale(minY: -bound, maxY: bound, interval: interval);
  }

  // كل القيم موجبة
  final interval = _calculateNiceInterval(maxValue, targetIntervals);

  final maxY = (maxValue / interval).ceil() * interval;

  return _ChartScale(minY: 0, maxY: maxY, interval: interval);
}

double _calculateNiceInterval(double range, int targetIntervals) {
  if (!range.isFinite || range <= 0) {
    return 1;
  }

  final rawInterval = range / targetIntervals;

  final magnitude = pow(10, (log(rawInterval) / ln10).floor()).toDouble();

  final normalized = rawInterval / magnitude;

  final niceNormalized = switch (normalized) {
    <= 1 => 1,
    <= 2 => 2,
    <= 5 => 5,
    _ => 10,
  };

  return niceNormalized * magnitude;
}
