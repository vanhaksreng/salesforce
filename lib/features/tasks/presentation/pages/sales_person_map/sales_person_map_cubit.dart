import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/tasks/domain/entities/sale_person_gps_model.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/sales_person_map/sales_person_map_state.dart';
import 'package:salesforce/injection_container.dart';

class SalesPersonMapCubit extends Cubit<SalesPersonMapState> {
  SalesPersonMapCubit() : super(SalesPersonMapState(isLoading: true));
  final repos = getIt<TaskRepository>();

  Future<void> getSalePersonGps() async {
    try {
      emit(state.copyWith(isLoading: true));

      final response = await repos.getSalepersonGps();
      response.fold(
        (failure) {
          emit(state.copyWith(error: failure.message, isLoading: false));
        },
        (items) => emit(state.copyWith(isLoading: false, salePersonGps: items)),
      );
    } catch (error) {
      Helpers.showMessage(msg: error.toString(), status: MessageStatus.errors);
      emit(state.copyWith(isLoading: false));
    }
  }

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

  void selectSalePerson(SalePersonGpsModel salePerson) {
    emit(state.copyWith(salePerson: salePerson));
  }
}
