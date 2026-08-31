class KpiModel {
  final double netProfit;
  final double sales;
  final double purchases;
  final double expenses;

  KpiModel({
    required this.netProfit,
    required this.sales,
    required this.purchases,
    required this.expenses,
  });

  KpiModel copyWith({
    double? netProfit,
    double? sales,
    double? purchases,
    double? expenses,
  }) => KpiModel(
    netProfit: netProfit ?? this.netProfit,
    sales: sales ?? this.sales,
    purchases: purchases ?? this.purchases,
    expenses: expenses ?? this.expenses,
  );
}
