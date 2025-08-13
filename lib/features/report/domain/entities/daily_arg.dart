class DailyArg {
  final String fromDate;
  final String endDate;
  final String? salePersonCode;

  DailyArg({
    required this.fromDate,
    required this.endDate,
    this.salePersonCode = "",
  });
}
