import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/env.dart';
import 'package:salesforce/features/tasks/domain/entities/sale_person_gps_model.dart';
import 'package:salesforce/features/tasks/presentation/pages/sales_person_map/sales_person_map_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/sales_person_map/sales_person_map_state.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/i_location_service.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class SalesPersonMapScreen extends StatefulWidget {
  const SalesPersonMapScreen({super.key});
  static const String routeName = "salePersonMapScreen";

  @override
  SalesPersonMapScreenState createState() => SalesPersonMapScreenState();
}

class SalesPersonMapScreenState extends State<SalesPersonMapScreen> {
  final _cubit = SalesPersonMapCubit();
  final Set<Polyline> _polylines = {};
  final String googleAPIKey = kGoogleKey;
  final ILocationService _location = GeolocatorLocationService();
  CameraPosition _phnomPenhLatlong() {
    return const CameraPosition(target: LatLng(11.5564, 104.9282), zoom: 15);
  }

  int nearestIndex = 0;

  @override
  void initState() {
    super.initState();
    getMarkerSale();
    _cubit.getCamPosition(_phnomPenhLatlong());
  }

  @override
  void dispose() {
    _polylines.clear();
    super.dispose();
  }

  Future<void> getMarkerSale() async {
    await _cubit.getSalePersonGps();
    final salePersonGps = _cubit.state.salePersonGps;
    await onGetCurrentLocation(salePersonGps);
    for (var salesPerson in salePersonGps) {
      final lat = Helpers.toDouble(salesPerson.latitude);
      final lng = Helpers.toDouble(salesPerson.longitude);
      final position = LatLng(lat, lng);

      BitmapDescriptor? customIcon;

      customIcon = await _getCustomMarkerIcon(
        salesPerson.avatar,
        salesPerson.name,
      );
      _cubit.getMarker(
        Marker(
          markerId: MarkerId(salesPerson.code),
          position: position,
          icon: customIcon,
          infoWindow: InfoWindow(title: salesPerson.name),
        ),
      );
    }
  }

  Future<void> onGetCurrentLocation(
    List<SalePersonGpsModel> salePersons,
  ) async {
    try {
      final position = await _location.getCurrentLocation();
      if ((position.latitude == 0 && position.longitude == 0)) {
        throw GeneralException(
          greeting("Your current location is not available."),
        );
      }

      final userLat = position.latitude;
      final userLng = position.longitude;

      SalePersonGpsModel? nearestSalesperson;
      double shortestDistance = double.infinity;

      for (int i = 0; i < salePersons.length; i++) {
        final saleperson = salePersons[i];
        final lat = Helpers.toDouble(saleperson.latitude);
        final lng = Helpers.toDouble(saleperson.longitude);

        final distance = Helpers.calculateDistanceInMeters(
          userLat,
          userLng,
          lat,
          lng,
        );

        if (distance < shortestDistance) {
          shortestDistance = distance;
          nearestSalesperson = saleperson;
          nearestIndex = i;
        }
      }

      if (nearestSalesperson == null) return;
      onSelectedSalePerson(nearestSalesperson);
      // await _getDataOnChange(
      //   LatLng(
      //     Helpers.toDouble(nearestSalesperson.latitude),
      //     Helpers.toDouble(nearestSalesperson.longitude),
      //   ),
      //   salePersons: nearestSalesperson,
      // );
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
      borderColor: primary,
      borderWidth: 4,
    );
  }

  Future<void>? _getDataOnChange(
    LatLng position, {
    SalePersonGpsModel? salePersons,
  }) async {
    if (salePersons == null) return;

    _cubit.state.mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15),
      ),
    );

    BitmapDescriptor? customIcon;

    customIcon = await _getCustomMarkerIcon(
      salePersons.avatar,
      salePersons.name,
    );

    _cubit.getMarker(
      Marker(
        markerId: MarkerId(salePersons.code),
        position: position,
        icon: customIcon,
        infoWindow: InfoWindow(title: salePersons.name),
      ),
    );
  }

  void _onChangePageCustomer(SalePersonGpsModel saleperson) async {
    final lat = Helpers.toDouble(saleperson.latitude);
    final lng = Helpers.toDouble(saleperson.longitude);

    final position = LatLng(lat, lng);

    await _getDataOnChange(position, salePersons: saleperson);
  }

  void onSelectedSalePerson(SalePersonGpsModel salePerson) {
    _cubit.selectSalePerson(salePerson);
    _onChangePageCustomer(salePerson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("SalesPerson Map")),
      body: BlocBuilder<SalesPersonMapCubit, SalesPersonMapState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) {
            return LoadingPageWidget();
          }
          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(SalesPersonMapState state) {
    if (state.salePersonGps.isEmpty) {
      return EmptyScreen();
    }
    return Stack(
      children: [
        if (state.kGooglePostition == null) ...[
          const LoadingPageWidget(),
        ] else ...[
          GoogleMap(
            polylines: _polylines,
            initialCameraPosition:
                state.kGooglePostition ?? _phnomPenhLatlong(),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            markers: state.markers,
            onMapCreated: (controller) => _cubit.getController(controller),
          ),
        ],
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: BoxWidget(
            rounding: 0,
            isBoxShadow: false,
            color: white,

            padding: EdgeInsets.symmetric(vertical: scaleFontSize(8)),
            height: scaleFontSize(120),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: state.salePersonGps.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final salePerson = state.salePersonGps;

                bool isSelected = state.salePerson == salePerson[index];
                return GestureDetector(
                  onTap: () => onSelectedSalePerson(salePerson[index]),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: scaleFontSize(4)),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: isSelected ? primary : grey,
                          radius: scaleFontSize(25),
                          child: Padding(
                            padding: EdgeInsets.all(scaleFontSize(2)),
                            child: ImageNetWorkWidget(
                              round: scaleFontSize(55),
                              imageUrl: salePerson[index].avatar,
                              width: scaleFontSize(55),
                              height: scaleFontSize(55),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            width: scaleFontSize(60),
                            child: ChipWidget(
                              borderColor: isSelected
                                  ? primary
                                  : Colors.transparent,
                              bgColor: isSelected
                                  ? primary
                                  : Colors.transparent,
                              horizontal: scaleFontSize(1),
                              vertical: scaleFontSize(0),
                              child: TextWidget(
                                text: salePerson[index].name,
                                fontSize: 12,
                                color: isSelected ? white : textColor,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
