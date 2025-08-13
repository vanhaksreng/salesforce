import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/customer_address_form/customer_address_form_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class CustomerAddressFormCubit extends Cubit<CustomerAddressFormState> with MessageMixin, AppMixin {
  CustomerAddressFormCubit() : super(const CustomerAddressFormState(isLoading: true));
  final _repos = getIt<MoreRepository>();

  Future<bool> storeNewCustomerAddress({required CustomerAddress address}) async {
    final result = await _repos.storeNewCustomerAddress(address);
    return result.fold((l) {
      showWarningMessage(l.message);
      return false;
    }, (records) => true);
  }

  Future<bool> updateCustomerAddress({required CustomerAddress address}) async {
    final result = await _repos.updateCustomerAddress(address);
    return result.fold((l) {
      showWarningMessage(l.message);
      return false;
    }, (records) => true);
  }

  Future<void> getAddress({Map<String, dynamic>? param}) async {
    try {
      final result = await _repos.getCustomerAddress(params: param);

      result.fold(
        (l) => throw GeneralException(l.message),
        (records) => emit(state.copyWith(isLoading: false, cusAddress: records)),
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
    }
  }

  Future<void> getAddressFromLatLng(LatLng latlng) async {
    try {
      emit(state.copyWith(isLoading: true));
      final result = await _repos.getAddressFrmLatLng(latlng.latitude, latlng.longitude);
      result.fold(
        (l) => throw GeneralException(l.message),
        (address) => emit(state.copyWith(isLoading: false, fullAddress: address)),
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
    }
  }
}
