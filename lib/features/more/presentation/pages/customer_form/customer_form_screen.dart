import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/components/build_header.dart';
import 'package:salesforce/features/more/presentation/pages/customer_form/customer_form_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/customer_form/customer_form_state.dart';
import 'package:salesforce/features/more/presentation/pages/customer_map/customer_map_full_screen_screen.dart';
import 'package:salesforce/features/more/presentation/pages/customer_map/customer_map_screen.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/i_location_service.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CustomerformScreen extends StatefulWidget {
  const CustomerformScreen({super.key, required this.customer, required this.onCustomerChanged});

  final Customer customer;

  final void Function(Customer customer) onCustomerChanged;

  static const routeName = "customerFormScreen";

  @override
  CustomerInfoScreenState createState() => CustomerInfoScreenState();
}

class CustomerInfoScreenState extends State<CustomerformScreen> with MessageMixin, AutomaticKeepAliveClientMixin {
  final _cubit = CustomerFormCubit();
  final ILocationService _location = GeolocatorLocationService();

  ActionState? action;

  final _nameTextEditController = TextEditingController();
  final _phoneTextEditController = TextEditingController();
  final _emailTextEditController = TextEditingController();
  final _addressTextEditController = TextEditingController();
  final _latTextEditController = TextEditingController();
  final _longTextEditController = TextEditingController();
  final _cusIdTextEditController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  void _initLoad() async {
    await _cubit.initLoadData(widget.customer);

    final customer = _cubit.state.customer;
    if (customer == null) {
      return;
    }

    _nameTextEditController.text = customer.name ?? "";
    _phoneTextEditController.text = customer.phoneNo ?? "";
    _emailTextEditController.text = customer.email ?? "";
    _addressTextEditController.text = customer.address ?? "";
    _latTextEditController.text = Helpers.toStrings(customer.latitude ?? 0.0);
    _longTextEditController.text = Helpers.toStrings(customer.longitude ?? 0.0);
    _cusIdTextEditController.text = customer.no;
  }

  void _onUpdateHandler() async {
    if (!await _cubit.isConnectedToNetwork()) {
      showWarningMessage(errorInternetMessage);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_nameTextEditController.text.isEmpty) {
      showWarningMessage("Full Name is require");
      return;
    }

    if (_phoneTextEditController.text.isEmpty) {
      showWarningMessage("Phone Number is require");
      return;
    }

    if (!mounted) return;

    final l = LoadingOverlay.of(context);
    l.show();

    try {
      await _cubit.updateCustomer(
        Customer(
          _cusIdTextEditController.text,
          name: _nameTextEditController.text,
          email: _emailTextEditController.text,
          phoneNo: _phoneTextEditController.text,
          address: _addressTextEditController.text,
          latitude: Helpers.toDouble(_latTextEditController.text),
          longitude: Helpers.toDouble(_longTextEditController.text),
          status: kStatusOpen,
        ),
      );

      l.hide();

      widget.onCustomerChanged.call(_cubit.state.customer!);
    } catch (e) {
      l.hide();
    }
  }

  void _getLatLng(LatLng? latLng) async {
    if (latLng != null) {
      _latTextEditController.text = Helpers.toStrings(latLng.latitude);

      _longTextEditController.text = Helpers.toStrings(latLng.longitude);

      if (widget.customer.latitude != latLng.latitude || widget.customer.longitude == latLng.longitude) {
        await _cubit.getAddressFrmLatLng(latLng);
        if (_cubit.state.fullAddress.isNotEmpty) {
          _addressTextEditController.text = _cubit.state.fullAddress;
        }
      }
    }
  }

  Future<void> getCurrentAddress() async {
    final locationData = await _location.getCurrentLocation();

    _onUpdateMapController(LatLng(locationData.latitude, locationData.longitude));
  }

  Future<void> _onUpdateMapController(LatLng data) async {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(data.latitude, data.longitude), 14));
    await _onCameraIdle(LatLng(data.latitude, data.longitude));
  }

  _onCameraIdle(LatLng latLng) async {
    _latTextEditController.text = latLng.latitude.toString();
    _longTextEditController.text = latLng.longitude.toString();

    await _cubit.getAddressFrmLatLng(latLng);
    if (_cubit.state.fullAddress.isNotEmpty) {
      _addressTextEditController.text = _cubit.state.fullAddress;
    }
  }

  _onNvigatorToOpenMap() {
    Navigator.pushNamed(
      context,
      CustomerMapFullScreenScreen.routeName,
      arguments: LatLng(Helpers.toDouble(_latTextEditController.text), Helpers.toDouble(_longTextEditController.text)),
    ).then((value) async {
      if (value == null) return;
      final data = value as LatLng;
      await _onUpdateMapController(data);
    });
  }

  @override
  void dispose() {
    _latTextEditController.dispose;
    _longTextEditController.dispose;
    _nameTextEditController.dispose;
    _emailTextEditController.dispose;
    _addressTextEditController.dispose;
    _phoneTextEditController.dispose;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: BlocBuilder<CustomerFormCubit, CustomerFormState>(
        bloc: _cubit,
        builder: (BuildContext context, CustomerFormState state) {
          return buildBody(state);
        },
      ),
      persistentFooterButtons: [
        BtnWidget(
          horizontal: appSpace,
          size: BtnSize.medium,
          gradient: linearGradient,
          onPressed: _onUpdateHandler,
          title: greeting("update"),
        ),
      ],
    );
  }

  Widget buildBody(CustomerFormState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace), vertical: scaleFontSize(8)),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 8.scale),
        child: Column(
          spacing: 15.scale,
          children: [
            BoxWidget(
              padding: EdgeInsets.all(scaleFontSize(appSpace8)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: scaleFontSize(appSpace),
                  children: [
                    const BuildHeader(icon: Icons.person, label: "customer_info"),
                    TextFormFieldWidget(
                      label: greeting("Customer No"),
                      readOnly: true,
                      filled: true,
                      fillColor: grey20,
                      controller: _cusIdTextEditController,
                      isDefaultTextForm: true,
                    ),
                    TextFormFieldWidget(
                      label: greeting("full_name"),
                      controller: _nameTextEditController,
                      isDefaultTextForm: true,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "";
                        }
                        return null;
                      },
                    ),
                    TextFormFieldWidget(
                      label: greeting("phone_number"),
                      controller: _phoneTextEditController,
                      isDefaultTextForm: true,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "";
                        }
                        return null;
                      },
                    ),
                    TextFormFieldWidget(
                      label: greeting("email"),
                      controller: _emailTextEditController,
                      isDefaultTextForm: true,
                    ),
                    TextFormFieldWidget(
                      label: greeting("address"),
                      maxLines: 2,
                      controller: _addressTextEditController,
                      isDefaultTextForm: true,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "";
                        }
                        return null;
                      },
                    ),
                    Row(
                      spacing: 8.scale,
                      children: [
                        Expanded(
                          child: TextFormFieldWidget(
                            label: greeting("latitude"),
                            controller: _latTextEditController,
                            isDefaultTextForm: true,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "";
                              }
                              return null;
                            },
                          ),
                        ),
                        Expanded(
                          child: TextFormFieldWidget(
                            label: greeting("longitude"),
                            controller: _longTextEditController,
                            isDefaultTextForm: true,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const BuildHeader(icon: Icons.map, label: "address_map"),
                    BoxWidget(
                      isBorder: true,
                      isBoxShadow: false,
                      width: double.infinity,
                      height: 250.scale,
                      child: CustomerMapScreen(
                        isShowPin: true,
                        isGPS: true,
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        latLng: LatLng(widget.customer.latitude ?? 0.0, widget.customer.longitude ?? 0.0),
                        scrollGesturesEnabled: true,
                        onCameraIdle: (latLng) => _getLatLng(latLng),
                      ),
                    ),
                    _buildFootterBtn(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFootterBtn() {
    return Row(
      spacing: 8.scale,
      children: [
        Expanded(
          child: BtnWidget(
            borderColor: error.withValues(alpha: .2),
            icon: Icon(Icons.gps_fixed, size: 20.scale, color: error),
            size: BtnSize.small,
            variant: BtnVariant.outline,
            textColor: error,
            title: greeting("Current Location"),
            onPressed: () => getCurrentAddress(),
          ),
        ),
        Expanded(
          child: BtnWidget(
            icon: Icon(Icons.map, size: 20.scale, color: white),
            size: BtnSize.small,
            gradient: linearGradient,
            title: greeting("see_map"),
            onPressed: () => _onNvigatorToOpenMap(),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
