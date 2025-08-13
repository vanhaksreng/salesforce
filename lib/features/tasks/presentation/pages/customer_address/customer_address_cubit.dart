import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/download_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/customer_address/customer_address_state.dart';
import 'package:salesforce/injection_container.dart';

class CustomerAddressCubit extends Cubit<CustomerAddressState> with MessageMixin, DownloadMixin, AppMixin {
  CustomerAddressCubit() : super(const CustomerAddressState(isLoading: true));

  final _repo = getIt<TaskRepository>();

  Future<void> getCustomerAddress(String customerNo) async {
    try {
      emit(state.copyWith(isLoading: true));
      await _repo.getCustomerAddresses(params: {'customer_no': customerNo}).then((response) {
        response.fold(
          (l) => throw GeneralException(l.message),
          (r) => emit(state.copyWith(records: r, isLoading: false)),
        );
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (e) {
      showErrorMessage(e.toString());
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
