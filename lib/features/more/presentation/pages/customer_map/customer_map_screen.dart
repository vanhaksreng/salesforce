import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/customer_map/customer_map_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/customer_map/customer_map_state.dart';

class CustomerMapScreen extends StatefulWidget {
  const CustomerMapScreen({
    Key? key,
    this.onCameraIdle,
    this.onMapCreated,
    required this.latLng,
    this.scrollGesturesEnabled = false,
    this.isShowPin = false,
    this.radius = 8,
    this.isGPS = false,
  }) : super(key: key);
  final ValueChanged<LatLng>? onCameraIdle;
  final Function(GoogleMapController)? onMapCreated;
  final LatLng latLng;
  final bool scrollGesturesEnabled;
  final bool isShowPin;
  final bool isGPS;
  final double radius;

  @override
  CustomerMapScreenState createState() => CustomerMapScreenState();
}

class CustomerMapScreenState extends State<CustomerMapScreen> {
  final _cubit = CustomerMapCubit();

  late final CameraPosition initialCameraPosition = CameraPosition(target: widget.latLng, zoom: 14);

  late final Set<Marker> markers = {Marker(markerId: const MarkerId('selected'), position: widget.latLng)};

  late LatLng currentLatLng = widget.latLng;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerMapCubit, CustomerMapState>(
      bloc: _cubit,
      builder: (context, state) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: GoogleMap(
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                }.toSet(),
                scrollGesturesEnabled: widget.scrollGesturesEnabled,
                initialCameraPosition: initialCameraPosition,
                myLocationEnabled: widget.isGPS,
                compassEnabled: false,
                myLocationButtonEnabled: widget.isGPS,
                zoomControlsEnabled: true,
                // markers: markers,
                onCameraMove: (position) async => await _cubit.emitPosition(position.target),
                onCameraIdle: () {
                  widget.onCameraIdle?.call(state.currentLatLng ?? currentLatLng);
                },
                onMapCreated: widget.onMapCreated,
              ),
            ),
            if (widget.isShowPin)
              Positioned.fill(
                bottom: 25.scale,
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(kpinImage, height: 30.scale),
                ),
              ),
          ],
        );
      },
    );
  }
}
