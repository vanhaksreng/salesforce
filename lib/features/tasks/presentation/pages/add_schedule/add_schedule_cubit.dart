import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/data/models/extension/customer_extension.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/download_mixin.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

part 'add_schedule_state.dart';

class AddScheduleCubit extends Cubit<AddScheduleState>
    with DownloadMixin, AppMixin {
  AddScheduleCubit() : super(const AddScheduleState(isLoading: true));

  final repos = getIt<TaskRepository>();

  Future<void> loadCustomersAddress({required String cusNO}) async {
    try {
      emit(state.copyWith(isLoading: true));

      final response = await repos.getCustomerAddresses(
        params: {'customer_no': cusNO},
      );

      response.fold(
        (failure) => throw Exception(failure.message),
        (items) =>
            emit(state.copyWith(isLoading: false, customerAddresses: items)),
      );
    } catch (error) {
      error.toString();
    }
  }

  // Future<void> loadCustomers({required int page, bool isLoading = true, Map<String, dynamic>? param}) async {
  //   try {
  //     final oldCustomers = List<Customer>.from(state.customers);
  //     emit(state.copyWith(isLoading: isLoading, isLoadingMore: !isLoading));
  //     final response = await repos.getCustomers(page: page, params: param);
  //     response.fold(
  //       (failure) => throw Exception(failure.message),
  //       (items) => emit(
  //         state.copyWith(isLoading: false, isLoadingMore: false, customers: page == 1 ? items : oldCustomers + items),
  //       ),
  //     );
  //   } catch (error) {
  //     emit(state.copyWith(isLoading: false, isLoadingMore: false));
  //   }
  // }

  Future<void> loadCustomers({
    required BuildContext context,
    Map<String, dynamic>? params,
    int page = 1,
    bool append = false,
  }) async {
    try {
      if (append) {
        emit(state.copyWith(isFetching: true, isLoading: false));
      }

      final result = await repos.getCustomers(params: params, page: page);
      if (!context.mounted) return;
      result.fold((l) => throw Exception(), (records) {
        // Append or replace
        final newRecords = append ? [...state.customers, ...records] : records;

        emit(
          state.copyWith(
            isLoading: false,
            isFetching: false,
            customers: newRecords,
            currentPage: page,
            lastPage: records.isEmpty ? page : page + 1,
          ),
        );
      });
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<bool> createSchedule() async {
    try {
      final response = await repos.createSchedules({
        "schedules": state.selectedCustomers,
      });

      return response.fold(
        (error) {
          throw Exception(error.toString());
        },
        (success) {
          return true;
        },
      );
    } catch (error) {
      return false;
    }
  }

  void removeSelectedCustomers(String customerNo) {
    final updatedList = [...state.selectedCustomers];
    updatedList.removeWhere((c) => c["customer_no"] == customerNo);
    emit(state.copyWith(selectedCustomers: updatedList));
  }

  void addSelectedCustomers(String customerNo, CustomerAddress? address) {
    final updatedList = [...state.selectedCustomers];

    updatedList.add({"customer_no": customerNo, "address_id": address?.id});

    if (address != null) {
      final index = state.customers.indexWhere((c) => c.no == customerNo);

      if (index != -1) {
        final updatedCustomer = state.customers[index].copyWith(
          address: address.address,
          phoneNo: address.phoneNo,
        );

        final updatedCustomers = [...state.customers];
        updatedCustomers[index] = updatedCustomer;

        emit(
          state.copyWith(
            selectedCustomers: updatedList,
            customers: updatedCustomers,
          ),
        );

        return;
      }
    }

    emit(state.copyWith(selectedCustomers: updatedList));
  }

  Future<void> searchCustomer({String? query}) async {
    try {
      emit(state.copyWith(isLoading: true));
      final response = await repos.getCustomers(page: 1);
      response.fold((l) => emit(throw Exception(l.toString())), (items) {
        emit(state.copyWith(isLoading: false, customers: items));
      });
    } catch (error) {
      error.toString();
    }
  }

  Future<void> getSalePersonSchedule() async {
    try {
      final response = await repos.getSchedules(DateTime.now().toDateString());
      response.fold(
        (failure) => throw Exception(failure.message),
        (items) => emit(state.copyWith(isLoading: false, schedules: items)),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
