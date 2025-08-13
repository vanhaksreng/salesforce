part of 'add_schedule_cubit.dart';

class AddScheduleState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<CustomerAddress>? customerAddresses;
  final List<Customer> customers;
  final List<SalespersonSchedule>? schedules;

  final bool isFetching;
  final bool isLoadingCreate;
  final int currentPage;
  final int lastPage;
  final List<Map<String, dynamic>> selectedCustomers;

  const AddScheduleState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.customerAddresses,
    this.customers = const [],
    this.isFetching = false,
    this.isLoadingCreate = false,
    this.currentPage = 1,
    this.lastPage = 1,
    this.selectedCustomers = const [],
    this.schedules,
  });

  AddScheduleState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<CustomerAddress>? customerAddresses,
    List<Customer>? customers,
    List<SalespersonSchedule>? schedules,
    List<Map<String, dynamic>>? selectedCustomers,
    List<AppSyncLog>? appSyncLogs,
    bool? isFetching,
    int? currentPage,
    int? lastPage,
    bool? isLoadingCreate,
  }) {
    return AddScheduleState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      customerAddresses: customerAddresses ?? this.customerAddresses,
      customers: customers ?? this.customers,
      isFetching: isFetching ?? this.isFetching,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingCreate: isLoadingCreate ?? this.isLoadingCreate,
      selectedCustomers: selectedCustomers ?? this.selectedCustomers,
      schedules: schedules ?? this.schedules,
    );
  }
}
