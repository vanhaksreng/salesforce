import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/download_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/customers/customers_state.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/i_location_service.dart';
import 'package:salesforce/injection_container.dart';

class CustomersCubit extends Cubit<CustomersState>
    with DownloadMixin, AppMixin, MessageMixin {
  CustomersCubit() : super(const CustomersState(isLoading: true));

  final _repos = getIt<MoreRepository>();
  final ILocationService _location = GeolocatorLocationService();

  // Future<void> getCustomers({
  //   required BuildContext context,
  //   Map<String, dynamic>? params,
  //   int page = 1,
  //   bool append = false,
  // }) async {
  //   try {
  //     emit(state.copyWith(isLoading: true));
  //     final result = await _repos.getCustomers(params: params, page: page);
  //     if (!context.mounted) return;
  //     final currentLatLng = await _location.getCurrentLocation(
  //       context: context,
  //     );
  //     result.fold((l) => throw Exception(), (records) {
  //       for (var a in records) {
  //         a.distance = _location.getDistanceBetween(
  //           a.latitude ?? 0,
  //           a.longitude ?? 0,
  //           currentLatLng.latitude,
  //           currentLatLng.longitude,
  //         );
  //       }
  //       emit(state.copyWith(isLoading: false, records: records));
  //     });
  //   } catch (error) {
  //     emit(state.copyWith(error: error.toString()));
  //   }
  // }
  Future<void> getCustomers({
    required BuildContext context,
    Map<String, dynamic>? params,
    int page = 1,
    bool append = false,
  }) async {
    try {
      if (append) {
        emit(state.copyWith(isFetching: true, isLoading: false));
      }
      final inactive = {"inactived": "No"};
      final result = await _repos.getCustomers(
        params: {...?params, ...inactive},
        page: page,
      );
      if (!context.mounted) return;

      final currentLatLng = await _location.getCurrentLocation(
        context: context,
      );

      result.fold((l) => throw Exception(), (records) {
        for (var a in records) {
          a.distance = _location.getDistanceBetween(
            a.latitude ?? 0,
            a.longitude ?? 0,
            currentLatLng.latitude,
            currentLatLng.longitude,
          );
        }

        // Append or replace
        final newRecords = append ? [...state.records, ...records] : records;

        emit(
          state.copyWith(
            isLoading: false,
            isFetching: false,
            records: newRecords,
            currentPage: page,
            lastPage: records.isEmpty ? page : page + 1, // optional
          ),
        );
      });
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  Future<void> sortCustomer({
    required BuildContext context,
    bool sortByDistance = false,
    double? maxDistance,
    Map<String, dynamic>? params,
    int page = 1,
    bool append = false, // true if you want to load next page
  }) async {
    try {
      emit(state.copyWith(isLoading: true));

      final currentLatLng = await _location.getCurrentLocation(
        context: context,
      );
      final inactive = {"inactived": "No"};
      final result = await _repos.getCustomers(
        params: {...?params, ...inactive},
        page: page,
      );

      result.fold((l) => throw Exception(), (records) {
        // calculate distances
        for (var a in records) {
          a.distance = _location.getDistanceBetween(
            a.latitude ?? 0,
            a.longitude ?? 0,
            currentLatLng.latitude,
            currentLatLng.longitude,
          );
        }

        // sort by distance if needed
        if (sortByDistance) {
          records.sort((a, b) => a.distance!.compareTo(b.distance!));
        }

        // filter by maxDistance if provided
        final filteredRecords = maxDistance != null
            ? records.where((c) => c.distance! <= maxDistance).toList()
            : records;

        // append or replace existing records
        final newRecords = append
            ? [...state.records, ...filteredRecords]
            : filteredRecords;

        // update state
        emit(
          state.copyWith(
            isLoading: false,
            records: newRecords,
            currentPage: page,
            lastPage: filteredRecords.isEmpty ? page : page + 1,
          ),
        );
      });
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  // Future<void> sortCustomer({
  //   required BuildContext context,
  //   bool sortByDistance = false,
  //   double? maxDistance,
  //   Map<String, dynamic>? params,
  //   int page = 1,
  // }) async {
  //   final currentLatLng = await _location.getCurrentLocation(context: context);
  //   final result = await _repos.getCustomers(params: params, page: page);

  //   result.fold((l) => throw Exception(), (records) {
  //     for (var a in records) {
  //       a.distance = _location.getDistanceBetween(
  //         a.latitude ?? 0,
  //         a.longitude ?? 0,
  //         currentLatLng.latitude,
  //         currentLatLng.longitude,
  //       );
  //     }

  //     if (sortByDistance) {
  //       records.sort((a, b) => a.distance!.compareTo(b.distance!));
  //     }

  //     final finalRecords = maxDistance != null
  //         ? records.where((c) => c.distance! <= maxDistance).toList()
  //         : records;

  //     emit(state.copyWith(isLoading: false, records: finalRecords));
  //   });
  // }

  Future<bool> createNewCustomer(String customerNo) async {
    final result = await _repos.storeNewCustomer(
      param: {"customer_no": customerNo},
    );
    return result.fold(
      (l) {
        isValidate(l.message);
        return false;
      },
      (customer) {
        emit(state.copyWith(customer: customer));
        return true;
      },
    );
  }

  isValidate(String code) {
    emit(state.copyWith(messageCode: code));
  }

  onClear() {
    emit(state.copyWith(isValidation: false, messageCode: ""));
  }

  Future<void> getLatLng(BuildContext context) async {
    try {
      final currentLocation = await _location.getCurrentLocation(
        context: context,
      );

      emit(
        state.copyWith(
          latLng: LatLng(currentLocation.latitude, currentLocation.longitude),
        ),
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage(error.toString());
    }
  }

  void onChangeDistance(double value) {
    emit(state.copyWith(distanceValue: value));
  }

  void isSortDistance(bool value) {
    emit(state.copyWith(isSortdistance: value));
  }
}
