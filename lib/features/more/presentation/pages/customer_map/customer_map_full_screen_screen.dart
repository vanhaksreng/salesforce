import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/presentation/pages/customer_map/customer_map_screen.dart';
import 'package:salesforce/localization/trans.dart';

class CustomerMapFullScreenScreen extends StatefulWidget {
  const CustomerMapFullScreenScreen({super.key, required this.latLng});

  static const String routeName = "cusScreenFullMap";
  final LatLng latLng;

  @override
  CustomerMapFullScreenScreenState createState() => CustomerMapFullScreenScreenState();
}

class CustomerMapFullScreenScreenState extends State<CustomerMapFullScreenScreen> {
  GoogleMapController? _mapController;
  LatLng? latLng;

  @override
  void initState() {
    getAddress();
    super.initState();
  }

  Future<void> getAddress() async {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(widget.latLng.latitude, widget.latLng.longitude), 16),
    );
  }

  _onCameraIdle(LatLng newlatLong) async {
    latLng = newlatLong;
  }

  _onSaveLatLng(LatLng? latLng) {
    Helpers.showDialogAction(
      context,
      labelAction: greeting("Comfirm"),
      subtitle: greeting("Are you sure to save?"),
      confirm: () {
        Navigator.of(context)
          ..pop()
          ..pop(latLng);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("Map")),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: CustomerMapScreen(
              latLng: LatLng(widget.latLng.latitude, widget.latLng.longitude),
              radius: 8,
              scrollGesturesEnabled: true,
              isShowPin: true,
              isGPS: true,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _mapController?.animateCamera(CameraUpdate.newLatLngZoom(widget.latLng, 13));
              },
              onCameraIdle: _onCameraIdle,
            ),
          ),
          BtnWidget(
            vertical: appSpace,
            horizontal: appSpace,
            gradient: linearGradient,
            title: greeting("save"),
            onPressed: () => _onSaveLatLng(latLng),
          ),
        ],
      ),
    );
  }
}
