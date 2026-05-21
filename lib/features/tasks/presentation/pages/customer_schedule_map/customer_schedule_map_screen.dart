import 'dart:async';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final ILocationService _locationService = GeolocatorLocationService();
  final PolylinePoints _polylinePoints = PolylinePoints(apiKey: kGoogleKey);
  final carouselController = CarouselSliderController();
  final _cubit = CustomerScheduleMapCubit();

  /// Active driving-route polyline drawn on the map.
  Set<Polyline> _polylines = {};

  /// True while a polyline API call is in-flight.
  bool _polylineLoading = false;

  StreamSubscription<Position>? _locationStream;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _locationStream?.cancel();
    _cubit.close();
    super.dispose();
  }

  void _getCamPosition(LatLng position) {
    _cubit.getCamPosition(CameraPosition(target: position, zoom: 14));
  }

  Future<void> _bootstrap() async {
    final position = await _locationService.getCurrentLocation(
      context: context,
    );

    await Future.wait([
      _cubit.getSchedules(DateTime.now()),
      _cubit.getCustomer(),
    ]);

    _getCamPosition(LatLng(position.latitude, position.longitude));

    await _loadAllMarkers();

    final first = _cubit.state.schedule;

    if (first != null) {
      await _drawRouteTo(
        Helpers.toDouble(first.latitude),
        Helpers.toDouble(first.longitude),
      );
    }

    // Start tracking movement AFTER the first route is drawn.
    _startLocationTracking();
  }

  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20,
    );

    _locationStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) {
            _getCamPosition(LatLng(position.latitude, position.longitude));

            // Redraw the route from the new position to the currently
            // selected customer — only if a destination is already set.
            final current = _cubit.state.schedule;
            if (current != null && mounted) {
              _drawRouteTo(
                Helpers.toDouble(current.latitude),
                Helpers.toDouble(current.longitude),
              );
            }
          },
        );
  }

  Future<void> _loadAllMarkers() async {
    if (!widget.isMore) return;

    final schedules = _cubit.state.schedules ?? [];
    final customers = _cubit.state.customers;

    for (final schedule in schedules) {
      final match = customers.where((c) => c.no == schedule.customerNo);
      if (match.isEmpty) continue;

      final customer = match.first;
      final icon = await _buildMarkerIcon(
        customer.avatar128,
        customer.name ?? '',
      );

      _cubit.getMarker(
        Marker(
          markerId: MarkerId(schedule.id),
          position: LatLng(
            Helpers.toDouble(schedule.latitude),
            Helpers.toDouble(schedule.longitude),
          ),
          icon: icon,
          infoWindow: InfoWindow(title: customer.name),
        ),
      );
    }
  }

  Future<void> _updateMarkerFor(
    SalespersonSchedule schedule,
    LatLng position,
  ) async {
    final match = _cubit.state.customers.where(
      (c) => c.no == schedule.customerNo,
    );
    if (match.isEmpty) return;

    final customer = match.first;
    final icon = await _buildMarkerIcon(
      customer.avatar128,
      customer.name ?? '',
    );

    _cubit.getMarker(
      Marker(
        markerId: MarkerId(schedule.id),
        position: position,
        icon: icon,
        infoWindow: InfoWindow(title: customer.name),
      ),
    );
  }

  Future<BitmapDescriptor> _buildMarkerIcon(String? imageUrl, String name) {
    return Helpers.createPinMarkerWithImageAndTitle(
      title: name,
      imageUrl ?? '',
      size: 150,
      borderColor: error,
      borderWidth: 4,
    );
  }

  Future<void> _drawRouteTo(double destLat, double destLng) async {
    final origin = _cubit.state.kGooglePostition;
    if (origin == null) {
      Logger.log('GPS not ready yet');
      return;
    }

    if (mounted) setState(() => _polylineLoading = true);

    try {
      final response = await _polylinePoints.getRouteBetweenCoordinatesV2(
        request: RoutesApiRequest(
          origin: PointLatLng(origin.target.latitude, origin.target.longitude),
          destination: PointLatLng(destLat, destLng),
          travelMode: TravelMode.driving,
          routingPreference: RoutingPreference.trafficAware,
          polylineQuality: PolylineQuality.highQuality,
        ),
      );

      if (!mounted) return;

      if (response.routes.isEmpty) {
        Logger.log('No routes returned');
        return;
      }

      final points = (response.routes.first.polylinePoints ?? [])
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            color: const Color(0xFF5B4FD9),
            points: points,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        };
      });

      _fitCameraToRoute(origin.target, LatLng(destLat, destLng));
    } catch (e) {
      Logger.log('Polyline error: $e');
    } finally {
      if (mounted) setState(() => _polylineLoading = false);
    }
  }

  void _fitCameraToRoute(LatLng a, LatLng b, {double padding = 80}) {
    final controller = _cubit.state.mapController;
    if (controller == null) return;

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            a.latitude < b.latitude ? a.latitude : b.latitude,
            a.longitude < b.longitude ? a.longitude : b.longitude,
          ),
          northeast: LatLng(
            a.latitude > b.latitude ? a.latitude : b.latitude,
            a.longitude > b.longitude ? a.longitude : b.longitude,
          ),
        ),
        padding,
      ),
    );
  }

  // ── carousel callback ────────────────────────────────────────────────────
  void _onCarouselPageChanged(SalespersonSchedule schedule) async {
    if (schedule.latitude == null || schedule.longitude == null) {
      Logger.log('Schedule has no coordinates');
      return;
    }

    final lat = Helpers.toDouble(schedule.latitude);
    final lng = Helpers.toDouble(schedule.longitude);

    // Update the pin for this customer.
    await _updateMarkerFor(schedule, LatLng(lat, lng));

    // Redraw route from the user's fixed GPS to this customer.
    await _drawRouteTo(lat, lng);
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

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: state.kGooglePostition!,
                mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                compassEnabled: true,
                markers: state.markers,
                polylines: _polylines,
                onMapCreated: (c) => _cubit.getController(c),
              ),

              // Route-loading badge shown at the top of the map.
              if (_polylineLoading)
                const Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(child: _RouteLoadingBadge()),
                ),
            ],
          );
        },
      ),
      bottomSheet: _ScheduleBottomSheet(
        cubit: _cubit,
        carouselController: carouselController,
        onPageChanged: _onCarouselPageChanged,
      ),
    );
  }
}

class _RouteLoadingBadge extends StatelessWidget {
  const _RouteLoadingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            greeting('Finding route…'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ScheduleBottomSheet extends StatelessWidget {
  const _ScheduleBottomSheet({
    required this.cubit,
    required this.carouselController,
    required this.onPageChanged,
  });

  final CustomerScheduleMapCubit cubit;
  final CarouselSliderController carouselController;
  final void Function(SalespersonSchedule) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerScheduleMapCubit, CustomerScheduleMapState>(
      bloc: cubit,
      builder: (context, state) {
        final schedules = state.schedules ?? [];

        return DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.18,
          maxChildSize: 0.40,
          initialChildSize: 0.35,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // Header label.
                  Padding(
                    padding: EdgeInsets.only(
                      left: scaleFontSize(16),
                      right: scaleFontSize(16),
                      bottom: scaleFontSize(8),
                    ),
                    child: TextWidget(
                      text: greeting("Customer schedule"),
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
                  ),

                  // Carousel — scrolls with the sheet.
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: ScheduleCarousel(
                        customers: state.customers,
                        carouselController: carouselController,
                        schedules: schedules,
                        onPageChanged: onPageChanged,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
