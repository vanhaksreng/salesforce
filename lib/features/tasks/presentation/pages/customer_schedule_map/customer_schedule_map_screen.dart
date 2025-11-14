import 'dart:async';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/env.dart';
import 'package:salesforce/features/tasks/presentation/pages/customer_schedule_map/customer_schedule_map_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/customer_schedule_map/customer_schedule_map_state.dart';
import 'package:salesforce/features/tasks/presentation/pages/customer_schedule_map/compnent/schedule_carousel.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/i_location_service.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CustomerScheduleMapScreen extends StatefulWidget {
  static const String routeName = "customerScheduleMapScreen";
  final bool isMore;

  const CustomerScheduleMapScreen({super.key, required this.isMore});

  @override
  State<CustomerScheduleMapScreen> createState() => _MapScheduleScreenState();
}

class _MapScheduleScreenState extends State<CustomerScheduleMapScreen> {
  final Set<Polyline> _polylines = {};
  final String googleAPIKey = kGoogleKey;
  final CarouselSliderController carouselController =
      CarouselSliderController();

  final ILocationService _location = GeolocatorLocationService();

  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  final _cubit = CustomerScheduleMapCubit();
  CameraPosition _phnomPenhLatlong() {
    return const CameraPosition(target: LatLng(11.5564, 104.9282), zoom: 15);
  }

  @override
  void initState() {
    super.initState();
    _cubit.getCustomer();
    onGetCurrentLocation();
    _cubit.getCamPosition(_phnomPenhLatlong());
    getMarkerSale();
  }

  @override
  void dispose() {
    _polylines.clear();
    super.dispose();
  }

  Future<void> getMarkerSale() async {
    if (!widget.isMore) return;
    await _cubit.getSchedules(DateTime.now());

    final schedules = _cubit.state.schedules ?? [];

    for (var schedule in schedules) {
      final lat = Helpers.toDouble(schedule.latitude);
      final lng = Helpers.toDouble(schedule.longitude);
      final position = LatLng(lat, lng);

      List<Customer> customers = _cubit.state.customers;
      final customer = customers.firstWhere((e) => e.no == schedule.customerNo);

      BitmapDescriptor? customIcon;

      customIcon = await _getCustomMarkerIcon(
        customer.avatar128,
        customer.name ?? "",
      );
      _cubit.getMarker(
        Marker(
          markerId: MarkerId(schedule.id),
          position: position,
          icon: customIcon,
          infoWindow: InfoWindow(title: customer.name),
        ),
      );
    }
  }

  Future<void> onGetCurrentLocation() async {
    try {
      await _cubit.getSchedules(DateTime.now());
      final schedules = _cubit.state.schedules;
      if (schedules == null || schedules.isEmpty) return;
      if (!mounted) return;
      final position = await _location.getCurrentLocation(context: context);
      if ((position.latitude == 0 && position.longitude == 0)) {
        throw GeneralException(
          greeting("Your current location is not available."),
        );
      }

      final userLat = position.latitude;
      final userLng = position.longitude;

      SalespersonSchedule? nearestSchedule;
      double shortestDistance = double.infinity;
      int nearestIndex = 0;

      for (int i = 0; i < schedules.length; i++) {
        final schedule = schedules[i];
        final lat = Helpers.toDouble(schedule.latitude);
        final lng = Helpers.toDouble(schedule.longitude);

        final distance = Helpers.calculateDistanceInMeters(
          userLat,
          userLng,
          lat,
          lng,
        );

        if (distance < shortestDistance) {
          shortestDistance = distance;
          nearestSchedule = schedule;
          nearestIndex = i;
        }
      }

      if (nearestSchedule == null) return;

      carouselController.animateToPage(
        nearestIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );

      await _getDataOnChange(
        LatLng(
          Helpers.toDouble(nearestSchedule.latitude),
          Helpers.toDouble(nearestSchedule.longitude),
        ),
        schedule: nearestSchedule,
      );
    } catch (e) {
      _cubit.getCamPosition(_phnomPenhLatlong());
    }
  }

  Future<BitmapDescriptor> _getCustomMarkerIcon(
    String? imageUrl,
    String customerName,
  ) async {
    return await Helpers.createPinMarkerWithImageAndTitle(
      title: customerName,
      imageUrl ?? "",
      size: 150,
      borderColor: error,
      borderWidth: 4,
    );
  }

  Future<void>? _getDataOnChange(
    LatLng position, {
    SalespersonSchedule? schedule,
  }) async {
    if (schedule == null) return;

    _cubit.state.mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: widget.isMore ? 15 : 15),
      ),
    );

    List<Customer> customers = _cubit.state.customers;
    final customer = customers.firstWhere((e) => e.no == schedule.customerNo);

    BitmapDescriptor? customIcon;

    customIcon = await _getCustomMarkerIcon(
      customer.avatar128,
      customer.name ?? "",
    );

    _cubit.getMarker(
      Marker(
        markerId: MarkerId(schedule.id),
        position: position,
        icon: customIcon,
        infoWindow: InfoWindow(title: customer.name),
      ),
    );
  }

  void _onChangePageCustomer(schedule) async {
    if (schedule.latitude == null || schedule.longitude == null) {
      Logger.log('Schedule location data is null');
      return;
    }
    final lat = Helpers.toDouble(schedule.latitude);
    final lng = Helpers.toDouble(schedule.longitude);

    final position = LatLng(lat, lng);

    await _getDataOnChange(position, schedule: schedule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("customer_location")),
      body: BlocBuilder<CustomerScheduleMapCubit, CustomerScheduleMapState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.kGooglePostition == null) {
            return const LoadingPageWidget();
          }
          return GoogleMap(
            polylines: _polylines,
            initialCameraPosition:
                state.kGooglePostition ?? _phnomPenhLatlong(),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            markers: state.markers,
            onMapCreated: (controller) => _cubit.getController(controller),
          );
        },
      ),
      bottomSheet:
          BlocBuilder<CustomerScheduleMapCubit, CustomerScheduleMapState>(
            bloc: _cubit,
            builder: (context, state) {
              final schedules = state.schedules ?? [];
              final customers = state.customers;

              return DraggableScrollableSheet(
                expand: false,
                minChildSize: 0.1,
                maxChildSize: 0.40,
                initialChildSize: 0.1,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                      return Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(scaleFontSize(8)),
                            width: scaleFontSize(40),
                            height: scaleFontSize(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: grey,
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  child: _buildHeader(schedules, customers),
                                ),
                                SingleChildScrollView(
                                  padding: EdgeInsets.only(
                                    top: scaleFontSize(16),
                                  ),
                                  controller: scrollController,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: scaleFontSize(16),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ScheduleCarousel(
                                              customers: state.customers,
                                              carouselController:
                                                  carouselController,
                                              schedules: schedules,
                                              onPageChanged:
                                                  _onChangePageCustomer,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
              );
            },
          ),
    );
  }

  Widget _buildHeader(
    List<SalespersonSchedule> schedules,
    List<Customer> customers,
  ) {
    List<Customer> newCustomer = [];

    for (final schedule in schedules) {
      newCustomer.addAll(
        customers.where((e) => e.no == schedule.customerNo).toList(),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(16)),
      child: TextWidget(
        text: greeting("Customer schedule"),
        fontWeight: FontWeight.w400,
        fontSize: 18,
      ),
    );
  }
}
