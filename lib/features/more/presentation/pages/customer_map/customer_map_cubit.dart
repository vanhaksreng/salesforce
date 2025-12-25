import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/features/more/presentation/pages/customer_map/customer_map_state.dart';

class CustomerMapCubit extends Cubit<CustomerMapState> {
  CustomerMapCubit() : super(const CustomerMapState(isLoading: true));

  Future<void> emitPosition(LatLng? latlong) async {
    emit(state.copyWith(currentLatLng: latlong));
  }
}
