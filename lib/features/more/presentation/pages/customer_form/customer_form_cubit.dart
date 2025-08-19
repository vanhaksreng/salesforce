import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/customer_form/customer_form_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class CustomerFormCubit extends Cubit<CustomerFormState>
    with MessageMixin, AppMixin {
  CustomerFormCubit() : super(const CustomerFormState(isLoading: true));
  final _repos = getIt<MoreRepository>();

  Future<void> initLoadData(Customer? customer) async {
    emit(state.copyWith(customer: customer));
  }

  Future<void> updateCustomer(Customer customer) async {
    final result = await _repos.updateCustomer(customer);
    result.fold((l) => showErrorMessage(l.message), (record) {
      showSuccessMessage("Customer have been saved");
      emit(state.copyWith(customer: record));
    });
  }

  Future<void> getAddressFrmLatLng(LatLng latlng) async {
    try {
      final result = await _repos.getAddressFrmLatLng(
        latlng.latitude,
        latlng.longitude,
      );
      result.fold(
        (l) => throw GeneralException(l.message),
        (address) =>
            emit(state.copyWith(isLoading: false, fullAddress: address)),
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
    }
  }

  Future<void> emitLatlng(LatLng latlng) async {
    emit(state.copyWith(latlng: latlng));
  }
}
