import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_setting.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/bottom_sheet_fn.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkin_out/checkin_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkin_out/checkin_state.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/i_location_service.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/dotted_border_painter.dart';
import 'package:salesforce/core/presentation/widgets/header_bottom_sheet.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/smooth_image_loader.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key, required this.schedule});

  static const String routeName = "checkInScreen";
  final SalespersonSchedule schedule;

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> with MessageMixin {
  final _cubit = CheckinCubit();
  final TextEditingController commentController = TextEditingController();
  XFile? imgPath;
  ValueNotifier<bool> isSelectShopClose = ValueNotifier(false);
  final ILocationService _location = GeolocatorLocationService();

  @override
  void initState() {
    super.initState();
    _cubit.validateWithPhoto();
  }

  void _checkInOutHandler() {
    if (!_isCheckYet()) {
      _processCheckIn();
      return;
    }

    _processCheckOut();
  }

  void _processCheckIn() async {
    final l = LoadingOverlay.of(context);
    l.show();

    try {
      if (imgPath == null && _cubit.state.checkInWithPhoto == "Yes") {
        throw GeneralException(
          greeting("Please take a picture before checkin"),
        );
      }

      if (isSelectShopClose.value && commentController.text.isEmpty) {
        throw GeneralException(greeting("comments_field_require"));
      }

      await _cubit.getLatLng(context);
      final location = _cubit.state.latLng;
      if (location == null) {
        throw GeneralException("Cannot get Latitude & Longitude");
      }

      final areaByMeters = Helpers.toDouble(
        await _cubit.getSetting(kCheckedInAreaKey),
      );
      final double distInMeters = _location.getDistanceBetween(
        widget.schedule.latitude ?? 0,
        widget.schedule.longitude ?? 0,
        _cubit.state.latLng?.latitude ?? 0,
        _cubit.state.latLng?.longitude ?? 0,
      );

      if (areaByMeters > 0 && distInMeters > areaByMeters) {
        throw GeneralException(
          greeting(
            "must_within_store_checkin",
            params: {
              'value': Helpers.formatNumber(
                areaByMeters,
                option: FormatType.quantity,
              ),
            },
          ),
        );
      }

      bool result = await _cubit.processCheckIn(
        schedule: widget.schedule,
        args: CheckInArg(
          latitude: location.latitude,
          longitude: location.longitude,
          checkInPosition: distanceDisplay(distInMeters),
          comment: commentController.text,
          imagePath: imgPath,
          isCloseShop: isSelectShopClose.value,
        ),
      );

      l.hide();
      if (mounted && result) {
        Navigator.pop(context, _cubit.state.schedule);
      }
    } on GeneralException catch (e) {
      l.hide();
      showWarningMessage(e.message);
    } on Exception catch (e) {
      l.hide();
      showErrorMessage(e.toString());
    }
  }

  void _processCheckOut() async {
    final l = LoadingOverlay.of(context);
    l.show();

    try {
      if (imgPath == null && _cubit.state.checkOutWithPhoto == kStatusYes) {
        throw GeneralException(
          greeting("Please take a picture before checkout"),
        );
      }

      await _cubit.getLatLng(context);
      final location = _cubit.state.latLng;
      if (location == null) {
        throw GeneralException("Cannot get Latitude & Longitude");
      }

      final areaByMeters = Helpers.toDouble(
        await _cubit.getSetting(kCheckedOutAreaKey),
      );
      final double distInMeters = _location.getDistanceBetween(
        widget.schedule.latitude ?? 0,
        widget.schedule.longitude ?? 0,
        _cubit.state.latLng?.latitude ?? 0,
        _cubit.state.latLng?.longitude ?? 0,
      );
      // if (areaByMeters > 0) {
      //   // final double distInMeters = _location.getDistanceBetween(
      //   //   widget.schedule.latitude ?? 0,
      //   //   widget.schedule.longitude ?? 0,
      //   //   _cubit.state.latLng?.latitude ?? 0,
      //   //   _cubit.state.latLng?.longitude ?? 0,
      //   // );

      //   if (areaByMeters < distInMeters) {
      //     throw GeneralException(
      //       greeting(
      //         "must_within_store_checkout",
      //         params: {
      //           'value': Helpers.formatNumber(
      //             areaByMeters,
      //             option: FormatType.quantity,
      //           ),
      //         },
      //       ),
      //     );
      //   }
      // }
      if (areaByMeters > 0 && distInMeters > areaByMeters) {
        throw GeneralException(
          greeting(
            "must_within_store_checkout",
            params: {
              'value': Helpers.formatNumber(
                areaByMeters,
                option: FormatType.quantity,
              ),
            },
          ),
        );
      }

      bool result = await _cubit.processCheckout(
        schedule: widget.schedule,
        args: CheckInArg(
          checkOutPosition: distanceDisplay(distInMeters),
          latitude: location.latitude,
          imagePath: imgPath,
          longitude: location.longitude,
          comment: commentController.text,
          isCloseShop: isSelectShopClose.value,
        ),
      );

      l.hide();
      if (mounted && result) {
        Navigator.pop(context, _cubit.state.schedule);
      }
    } on GeneralException catch (e) {
      l.hide();
      showWarningMessage(e.message);
    } on Exception {
      l.hide();
      showErrorMessage();
    }
  }

  String distanceDisplay(double distInMeters) {
    final double distInKm = distInMeters / 1000;

    if (distInKm > 1) {
      return "${Helpers.formatNumberLink(distInKm, option: FormatType.quantity)}km";
    }

    return "${Helpers.formatNumberLink(distInMeters, option: FormatType.quantity)}m";
  }

  String screenTitle() {
    if (widget.schedule.status == "Scheduled") {
      return "check_in";
    }

    return "check_out";
  }

  bool _isCheckYet() {
    return widget.schedule.status != "Scheduled";
  }

  Future _pickImage(ImageSource imageSource) async {
    Navigator.pop(context);
    try {
      final picker = await ImagePicker().pickImage(
        imageQuality: 100,
        source: imageSource,
      );
      if (picker == null) return;
      setState(() {
        imgPath = XFile(picker.path);
      });
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  void openCamera(BuildContext context) {
    _pickImage(ImageSource.camera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting(screenTitle())),
      body: buildBody(),
      persistentFooterButtons: [buildBtnCheckIn()],
    );
  }

  Widget buildBody() {
    return BlocBuilder<CheckinCubit, CheckinState>(
      bloc: _cubit,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(top: scaleFontSize(appSpace)),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleFontSize(appSpace),
                  ),
                  children: [
                    if (!_isCheckYet() && state.checkInWithPhoto == kStatusYes)
                      buildImageUpload(),
                    if (_isCheckYet() && state.checkOutWithPhoto == kStatusYes)
                      buildImageUpload(),
                    SizedBox(height: scaleFontSize(appSpace)),
                    buildInsertComment(),
                    Helpers.gapH(8),
                    if (!_isCheckYet()) checkShopClose(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildBtnCheckIn() {
    return BlocBuilder<CheckinCubit, CheckinState>(
      bloc: _cubit,
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: scaleFontSize(appSpace),
              vertical: scaleFontSize(appSpace8),
            ),
            child: BtnWidget(
              gradient: linearGradient,
              title: greeting(!_isCheckYet() ? "check_in" : "check_out"),
              onPressed: () => _checkInOutHandler(),
              height: 45,
            ),
          ),
        );
      },
    );
  }

  showBottomSheetCamera() {
    modalBottomSheet(
      context,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: scaleFontSize(appSpace),
          children: [
            HeaderBottomSheet(
              childWidget: TextWidget(
                text: greeting("Take a picture"),
                fontSize: 16,
                color: white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(scaleFontSize(8)),
              child: Column(
                spacing: scaleFontSize(8),
                children: [
                  ListTitleWidget(
                    leading: const Icon(Icons.camera_alt, color: mainColor),
                    onTap: () => openCamera(context),
                    label: greeting("Camera"),
                    subTitle: greeting("Take photo by using camera."),
                  ),
                  // if (kDebugMode)
                  //   ListTitleWidget(
                  //     leading: const Icon(
                  //       Icons.photo,
                  //       color: mainColor,
                  //     ),
                  //     onTap: () => _pickImage(ImageSource.gallery),
                  //     label: greeting("gallery"),
                  //     subTitle: greeting("Take photo from gallery."),
                  //   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget checkShopClose() {
    return BoxWidget(
      padding: EdgeInsets.all(8.scale),
      child: Column(
        spacing: 8.scale,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 8.scale,
                children: [
                  ChipWidget(
                    radius: 6,
                    bgColor: mainColor50.withValues(alpha: 0.2),
                    vertical: 8,
                    horizontal: 0,
                    child: Icon(
                      size: 16.scale,
                      Icons.home_work_rounded,
                      color: mainColor,
                    ),
                  ),
                  TextWidget(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    text: greeting("shop_is_close"),
                  ),
                ],
              ),
              ValueListenableBuilder(
                valueListenable: isSelectShopClose,
                builder: (context, result, child) {
                  return CupertinoSwitch(
                    value: result,
                    activeTrackColor: CupertinoColors.activeGreen,
                    onChanged: (value) {
                      isSelectShopClose.value = value;
                    },
                  );
                },
              ),
            ],
          ),
          BoxWidget(
            rounding: 4,
            padding: EdgeInsets.all(8.scale),
            isBoxShadow: false,
            color: grey20.withValues(alpha: .1),
            child: TextWidget(
              color: orangeColor,
              text: greeting(
                "When you enable \"Shop is close\"  the system will automatically check you out after you check in",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInsertComment() {
    return TextFormFieldWidget(
      controller: commentController,
      maxLines: 5,
      fillColor: white,
      filled: true,
      label: "Write comment here!...",
      isDefaultTextForm: true,
      hintColor: textColor50,
    );
  }

  Widget buildImageUpload() {
    return CustomPaint(
      painter: DottedBorderPainter(),
      child: BoxWidget(
        color: white,
        onPress: () => showBottomSheetCamera(),
        margin: const EdgeInsets.only(top: 2, left: 2),
        isBoxShadow: false,
        rounding: 8,
        child: ImageNetWorkWidget(
          width: double.infinity,
          height: scaleFontSize(200),
          imageUrl: imgPath?.path ?? "",
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget buildTapText() {
    return Column(
      children: [
        SizedBox(
          height: scaleFontSize(100),
          child: Center(
            child: SmoothImageLoader(
              imageLocal: kSampleImage,
              width: 60,
              height: 60,
            ),
          ),
        ),
        TextWidget(text: greeting("tap_to_upload_picture"), color: textColor50),
      ],
    );
  }
}
