import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/customer_address_form/customer_address_form_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/customer_address_form/customer_address_form_state.dart';
import 'package:salesforce/features/more/presentation/pages/customer_map/customer_map_screen.dart';
import 'package:salesforce/features/more/presentation/pages/customer_map/customer_map_full_screen_screen.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/i_location_service.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CustomerAddressFormScreen extends StatefulWidget {
  const CustomerAddressFormScreen({Key? key, required this.address, required this.customer}) : super(key: key);

  static const String routeName = "customerFormscreen";
  final CustomerAddress? address;
  final Customer customer;

  @override
  State<CustomerAddressFormScreen> createState() => CustomerAddressFormScreenState();
}

class CustomerAddressFormScreenState extends State<CustomerAddressFormScreen>
    with MessageMixin, TickerProviderStateMixin {
  final _cubit = CustomerAddressFormCubit();
  final _nameAddController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _addressController = TextEditingController();
  final _address2Controller = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  GoogleMapController? _mapController;
  final ILocationService _location = GeolocatorLocationService();

  @override
  void initState() {
    super.initState();

    _initSetAddressValue();
  }

  void _initSetAddressValue() {
    if (widget.address == null) {
      return;
    }

    _codeController.text = widget.address?.code ?? "";
    _nameAddController.text = widget.address?.name ?? "";
    _addressController.text = widget.address?.address ?? "";
    _latController.text = (widget.address?.latitude ?? "").toString();
    _lngController.text = (widget.address?.longitude ?? "").toString();
  }

  _onCameraIdle(LatLng latLng) async {
    _latController.text = latLng.latitude.toString();
    _lngController.text = latLng.longitude.toString();

    await _cubit.getAddressFromLatLng(latLng);
    if (_cubit.state.fullAddress.isNotEmpty) {
      _addressController.text = _cubit.state.fullAddress;
    }
  }

  void _processSave() async {
    if (!await _cubit.isConnectedToNetwork()) {
      showWarningMessage(errorInternetMessage);
      return;
    }

    if (!mounted) return;

    final l = LoadingOverlay.of(context);
    l.show();

    final address = CustomerAddress(
      Helpers.generateUniqueNumber().toString(),
      customerNo: widget.customer.no,
      code: _codeController.text,
      name: _nameAddController.text,
      contactName: _contactNameController.text,
      address: _addressController.text,
      address2: _address2Controller.text,
      phoneNo: _phoneController.text,
      latitude: Helpers.toDouble(_latController.text),
      longitude: Helpers.toDouble(_lngController.text),
    );

    bool result = false;
    if (_cubit.state.cusAddress == null) {
      result = await _cubit.storeNewCustomerAddress(address: address);
    } else {
      result = await _cubit.updateCustomerAddress(address: address);
    }

    l.hide();

    if (!mounted) return;

    if (result) {
      Navigator.of(context).pop(ActionState.created);
    }
  }

  Future<void> _onSaveAddress() async {
    if (!await _cubit.isConnectedToNetwork()) {
      showWarningMessage(errorInternetMessage);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    if (_codeController.text.isEmpty) {
      showWarningMessage("Code is require");
      return;
    }
    if (_nameAddController.text.isEmpty) {
      showWarningMessage("Address Name is require");
      return;
    }

    if (!mounted) return;
    Helpers.showDialogAction(
      context,
      confirm: () {
        Navigator.of(context).pop();
        _processSave();
      },
    );
  }

  Future<void> getCurrentAddress() async {
    final locationData = await _location.getCurrentLocation();

    _onUpdateMapController(LatLng(locationData.latitude, locationData.longitude));
  }

  _onNvigatorToOpenMap() {
    Navigator.pushNamed(
      context,
      CustomerMapFullScreenScreen.routeName,
      arguments: LatLng(Helpers.toDouble(_latController.text), Helpers.toDouble(_lngController.text)),
    ).then((value) async {
      if (value == null) return;
      final data = value as LatLng;
      await _onUpdateMapController(data);
    });
  }

  Future<void> _onUpdateMapController(LatLng data) async {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(data.latitude, data.longitude), 14));
    await _onCameraIdle(LatLng(data.latitude, data.longitude));
  }

  bool _hideCondition() => widget.address == null ? false : true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarWidget(title: greeting(widget.address == null ? "create_address" : "update_address")),
      body: BlocBuilder<CustomerAddressFormCubit, CustomerAddressFormState>(
        bloc: _cubit,
        builder: (BuildContext context, CustomerAddressFormState state) {
          return buildBody(state);
        },
      ),
      persistentFooterButtons: [
        BtnWidget(
          horizontal: appSpace,
          size: BtnSize.medium,
          onPressed: () => _onSaveAddress(),
          gradient: linearGradient,
          title: greeting(widget.address == null ? "save_address" : "update_address"),
        ),
      ],
    );
  }

  Widget buildBody(CustomerAddressFormState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace), vertical: 8.scale),
      child: Column(
        spacing: 8.scale,
        children: [
          Form(key: _formKey, child: _builInputInfo()),
          Helpers.gapH(8),
          BoxWidget(
            isBoxShadow: false,
            borderWidth: 2,
            isBorder: true,
            height: 150.scale,
            child: CustomerMapScreen(
              latLng: LatLng(widget.address?.latitude ?? 0, widget.address?.longitude ?? 0),
              radius: 8,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              scrollGesturesEnabled: true,
              isShowPin: true,
              onCameraIdle: _onCameraIdle,
            ),
          ),
          _buildFootterBtn(),
        ],
      ),
    );
  }

  Widget _builInputInfo() {
    return BlocBuilder<CustomerAddressFormCubit, CustomerAddressFormState>(
      bloc: _cubit,
      builder: (context, state) {
        return Column(
          spacing: scaleFontSize(appSpace),
          children: [
            TextFormFieldWidget(
              controller: _codeController,
              isDefaultTextForm: true,
              filled: _hideCondition(),
              readOnly: _hideCondition(),
              label: greeting("code_address"),
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "";
                }
                return null;
              },
            ),
            TextFormFieldWidget(
              controller: _contactNameController,
              isDefaultTextForm: true,
              label: greeting("Contact Name"),
            ),
            TextFormFieldWidget(
              controller: _phoneController,
              isDefaultTextForm: true,
              label: greeting("Phone No"),
              keyboardType: TextInputType.phone,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "";
                }
                return null;
              },
            ),
            TextFormFieldWidget(
              controller: _nameAddController,
              isDefaultTextForm: true,
              label: greeting("address_name"),
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "";
                }
                return null;
              },
            ),
            TextFormFieldWidget(
              controller: _addressController,
              isDefaultTextForm: true,
              label: greeting("address"),
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "";
                }
                return null;
              },
            ),
            TextFormFieldWidget(
              controller: _address2Controller,
              isDefaultTextForm: true,
              label: greeting("Address Name 2"),
            ),
            Row(
              spacing: 8.scale,
              children: [
                Expanded(
                  child: TextFormFieldWidget(
                    readOnly: true,
                    filled: true,
                    controller: _latController,
                    isDefaultTextForm: true,
                    label: greeting("latitude"),
                  ),
                ),
                Expanded(
                  child: TextFormFieldWidget(
                    readOnly: true,
                    filled: true,
                    controller: _lngController,
                    isDefaultTextForm: true,
                    label: greeting("longitude"),
                  ),
                ),
              ],
            ),
          ],
        );
      },
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
}
