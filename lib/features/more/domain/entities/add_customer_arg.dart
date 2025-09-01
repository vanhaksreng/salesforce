class AddCustomerArg {
  AddCustomerArg({required this.documentType, this.onRefresh});
  final String documentType;
  final Function(bool isRefresh)? onRefresh;
}
