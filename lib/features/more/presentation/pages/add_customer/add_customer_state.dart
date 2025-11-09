import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class AddCustomerState {
  final bool isLoading;
  final String? error;
  final bool isLoadingMore;
  final List<CustomerAddress>? customerAddresses;
  final List<Customer> customers;
  final List<PosSalesHeader> posSaleHeader;
  final Customer? customer;
  final int currentPage;
  final int lastPage;

  const AddCustomerState({
    this.isLoading = false,
    this.error,
    this.isLoadingMore = false,
    this.customerAddresses,
    this.currentPage = 1,
    this.lastPage = 1,
    this.customers = const [],
    this.posSaleHeader = const [],
    this.customer,
  });

  AddCustomerState copyWith({
    bool? isLoading,
    String? error,
    bool? isLoadingMore,
    List<CustomerAddress>? customerAddresses,
    List<Customer>? customers,
    List<PosSalesHeader>? posSaleHeader,
    int? currentPage,
    int? lastPage,
    Customer? customer,
  }) {
    return AddCustomerState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      customerAddresses: customerAddresses ?? this.customerAddresses,
      customers: customers ?? this.customers,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      customer: customer ?? this.customer,
      posSaleHeader: posSaleHeader ?? this.posSaleHeader,
    );
  }
}
