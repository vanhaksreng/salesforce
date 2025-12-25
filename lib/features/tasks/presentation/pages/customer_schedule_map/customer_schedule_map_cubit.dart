import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/customer_schedule_map/customer_schedule_map_state.dart';
import 'package:salesforce/injection_container.dart';

class CustomerScheduleMapCubit extends Cubit<CustomerScheduleMapState> {
  CustomerScheduleMapCubit()
    : super(const CustomerScheduleMapState(isLoading: true));

  final _repos = getIt<TaskRepository>();

  void getMarker(Marker marker) {
    final currentMarkers = Set<Marker>.from(state.markers);
    currentMarkers.add(marker);
    emit(state.copyWith(markers: currentMarkers));
  }

  void getCamPosition(CameraPosition camPos) {
    emit(state.copyWith(kGooglePostition: camPos));
  }

  void getController(GoogleMapController controller) {
    emit(state.copyWith(mapController: controller));
  }

  Future<void> getSchedules(DateTime date, {bool isLoading = true}) async {
    try {
      emit(state.copyWith(isLoading: isLoading));

      final response = await _repos.getSchedules(
        date.toDateString(),
        requestApi: false,
      );
      response.fold(
        (failure) => throw Exception(failure.message),
        (items) => emit(state.copyWith(isLoading: false, schedules: items)),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> getCustomer() async {
    try {
      final inactive = {"inactived": "No"};
      final response = await _repos.getCustomers(params: inactive);
      response.fold(
        (failure) => throw Exception(failure.message),
        (items) => emit(state.copyWith(isLoading: false, customers: items)),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
