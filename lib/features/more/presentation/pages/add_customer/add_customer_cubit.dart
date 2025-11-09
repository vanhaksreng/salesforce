import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/download_mixin.dart';
import 'package:salesforce/features/more/presentation/pages/add_customer/add_customer_state.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class AddCustomerCubit extends Cubit<AddCustomerState>
    with DownloadMixin, AppMixin {
  AddCustomerCubit() : super(AddCustomerState(isLoading: true));
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

  Future<void> loadCustomers({
    required int page,
    bool isLoading = true,
    Map<String, dynamic>? param,
  }) async {
    try {
      final oldCustomers = List<Customer>.from(state.customers);
      emit(state.copyWith(isLoading: isLoading, isLoadingMore: !isLoading));
      final response = await repos.getCustomers(page: page, params: param);
      response.fold(
        (failure) => throw Exception(failure.message),
        (items) => emit(
          state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            customers: page == 1 ? items : oldCustomers + items,
          ),
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, isLoadingMore: false));
    }
  }

  Future<void> getSalePosSaleHeader({Map<String, dynamic>? param}) async {
    try {
      final response = await repos.getPosSaleHeaders(params: param);
      response.fold(
        (failure) => throw Exception(failure.message),
        (items) => emit(state.copyWith(isLoading: false, posSaleHeader: items)),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
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

  void selectCustomer(Customer cus) {
    emit(state.copyWith(customer: cus));
  }
}
