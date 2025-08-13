import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/constants/app_setting.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkin_out/checkin_state.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/i_location_service.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

class CheckinCubit extends Cubit<CheckinState> with MessageMixin, AppMixin {
  CheckinCubit() : super(const CheckinState(isLoading: false));
  final _repos = getIt<TaskRepository>();

  final ILocationService _location = GeolocatorLocationService();

  Future<bool> processCheckIn({required SalespersonSchedule schedule, required CheckInArg args}) async {
    try {
      final response = await _repos.checkIn(schedule: schedule, args: args);
      response.fold(
        (l) {
          throw GeneralException(l.toString());
        },
        (result) {
          emit(state.copyWith(schedule: result));
        },
      );

      return true;
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
      return false;
    } catch (error) {
      showErrorMessage(error.toString());
      return false;
    }
  }

  Future<bool> processCheckout({required SalespersonSchedule schedule, required CheckInArg args}) async {
    try {
      final response = await _repos.checkout(schedule: schedule, args: args);
      response.fold(
        (l) {
          throw GeneralException(l.toString());
        },
        (result) {
          emit(state.copyWith(schedule: result));
        },
      );

      return true;
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
      return false;
    } catch (error) {
      showErrorMessage(error.toString());
      return false;
    }
  }

  Future<void> getLatLng() async {
    try {
      final getLatLng = await _location.getCurrentLocation();
      emit(state.copyWith(latLng: LatLng(getLatLng.latitude, getLatLng.longitude)));
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
    }
  }

  Future<void> validateWithPhoto() async {
    final kcheckInWithPhoto = await getSetting(kCheckInVisitWithPhoto);
    final kcheckOutWithPhoto = await getSetting(kCheckOutWithPhoto);

    emit(state.copyWith(checkInWithPhoto: kcheckInWithPhoto, checkOutWithPhoto: kcheckOutWithPhoto));
  }
}
