import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/customer_detail/customer_detail_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class CustomerDetailCubit extends Cubit<CustomerDetailState> {
  CustomerDetailCubit() : super(CustomerDetailState());

  final _repos = getIt<MoreRepository>();

  Future<void> getCustomerDetails({Map<String, dynamic>? params}) async {
    try {
      emit(state.copyWith(loading: true));

      final result = await _repos.getCustomer(params: params);

      result.fold((l) => throw Exception(), (record) => emit(state.copyWith(loading: false, record: record)));
    } catch (error) {
      emit(state.copyWith(loading: false, error: error.toString()));
    }
  }

  Future<void> getCustomerAddress({Map<String, dynamic>? params}) async {
    try {
      emit(state.copyWith(loading: true));
      final result = await _repos.getCustomerAddresses(params: params);
      result.fold((l) => throw Exception, (records) => emit(state.copyWith(loading: false, recordAddresses: records)));
    } catch (error) {
      emit(state.copyWith(loading: false, error: error.toString()));
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    // try {
    //   emit(state.copyWith(loading: true));
    //   final result = await _repos.updateCustomer(customer);
    //   result.fold(
    //     (l) => throw Exception(),
    //     (record) {
    //       emit(state.copyWith(loading: false));
    //       Helpers.showMessage(msg: greeting("customer_change_successfully"));
    //     },
    //   );
    // } catch (error) {
    //   emit(state.copyWith(error: error.toString(), loading: false));
    // }
  }

  void setLocation(CameraPosition cameraPosition, Marker marker) {
    emit(state.copyWith(initialCameraPosition: cameraPosition, currentLocationMarker: marker, locationLoaded: true));
  }

  void setTabIndex(int index) {
    emit(state.copyWith(tabIndex: index));
  }

  void setLatLng(double lat, double lng) {
    emit(state.copyWith(latitude: lat, longtitude: lng));
  }
}
