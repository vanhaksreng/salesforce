import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/customer_address/customer_address_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class CustomerAddressCubit extends Cubit<CustomerAddressState>
    with MessageMixin, AppMixin {
  CustomerAddressCubit() : super(CustomerAddressState());

  final _repos = getIt<MoreRepository>();

  Future<void> getCustomerAddress({Map<String, dynamic>? param}) async {
    try {
      emit(state.copyWith(loading: true));
      final result = await _repos.getCustomerAddresses(params: param);
      result.fold(
        (l) => throw GeneralException(l.message),
        (records) => emit(state.copyWith(loading: false, cusAddresss: records)),
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
    }
  }

  Future<void> deletedCusAddress(CustomerAddress address) async {
    final List<CustomerAddress> oldCusAdd = List.from(state.cusAddresss);
    try {
      final List<CustomerAddress> newCusAdd = oldCusAdd;
      newCusAdd.removeWhere((e) => e.code == address.code);
      emit(state.copyWith(loading: true));

      final result = await _repos.deleteCustomerAddress(address);

      result.fold((l) => throw GeneralException(l.message), (records) {
        emit(state.copyWith(loading: false, cusAddresss: newCusAdd));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
    }
  }
}
