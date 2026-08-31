class ChartPoint {
  final DateTime timestamp;
  final double value;
  final int count;

  const ChartPoint({
    required this.timestamp,
    required this.value,
    required this.count,
  });

  ChartPoint copyWith({DateTime? timestamp, double? value, int? count}) {
    return ChartPoint(
      timestamp: timestamp ?? this.timestamp,
      value: value ?? this.value,
      count: count ?? this.count,
    );
  }
}
