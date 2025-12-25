import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/constants/app_setting.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/bottom_sheet_fn.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/buttom_sheet_filter_widget.dart';
import 'package:salesforce/core/presentation/widgets/header_bottom_sheet.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_btn_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/components/customer_card_box.dart';
import 'package:salesforce/features/more/presentation/pages/customer_detail/customer_detail_screen.dart';
import 'package:salesforce/features/more/presentation/pages/customers/customers_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/customers/customers_state.dart';
import 'package:salesforce/features/more/presentation/pages/customers/filter_distance_custom.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/i_location_service.dart';
import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});
  static const routeName = "CustomersScreen";

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> with MessageMixin {
  final _cubit = CustomersCubit();
  final ILocationService _location = GeolocatorLocationService();
  final ValueNotifier<int> page = ValueNotifier<int>(1);
  final ScrollController _scrollController = ScrollController();

  final _codeController = TextEditingController();
  bool isValidation = false;
  String text = '';

  @override
  void initState() {
    _cubit.getCustomers(page: 1, context: context);
    _scrollController.addListener(_handleScrolling);
    super.initState();
  }

  void _handleScrolling() {
    if (_shouldLoadMore()) {
      _loadMoreItems();
    }
  }

  bool _shouldLoadMore() {
    return _scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent;
  }

  void _loadMoreItems() async {
    page.value++;
    await _cubit.getCustomers(
      page: _cubit.state.currentPage + 1,
      context: context,
      append: true,
    );
  }

  _filter(String text) {
    _cubit.getCustomers(
      page: 1,
      params: {'name': "LIKE %$text%"},
      context: context,
    );
  }

  void _handleDownload() async {
    if (!await _cubit.isConnectedToNetwork()) {
      showWarningMessage(errorInternetMessage);
      return;
    }

    if (!mounted) return;

    final l = LoadingOverlay.of(context);
    try {
      l.show(1);

      final tables = await _cubit.getAppSyncLogs({
        'tableName': 'IN {"customer","customer_address"}',
      });

      if (tables.isEmpty) {
        throw GeneralException("Cannot find any table related");
      }

      await Future.delayed(const Duration(milliseconds: 300));
      const String msg = "System will download only related data.";
      await _cubit.downloadDatas(
        tables,
        onProgress: (progress, p1, p2, errorMsg) {
          l.updateProgress(progress, text: msg);
        },
      );

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      await _cubit.getCustomers(page: 1, context: context);

      l.hide();
    } on GeneralException catch (e) {
      l.hide();
      showWarningMessage(e.message);
    } on Exception {
      l.hide();
      showErrorMessage();
    }
  }

  void _editCustomer(Customer customer) {
    Navigator.pushNamed(
      context,
      CustomerDetailScreen.routeName,
      arguments: customer,
    ).then((value) {
      if (Helpers.shouldReload(value)) {
        if (!mounted) return;
        _cubit.getCustomers(context: context);
      }
    });
  }

  void _onCreateNewCustonerHandler() async {
    if (_codeController.text.isEmpty) {
      _cubit.isValidate("Code Customer require");
      return;
    }

    final l = LoadingOverlay.of(context);
    l.show();

    final result = await _cubit.createNewCustomer(_codeController.text);
    l.hide();
    if (result && mounted) {
      _navigateToCustomerDetail(_cubit.state.customer);
    }
  }

  void _navigateToCustomerDetail(Customer? customer) async {
    _cubit.isValidate("");

    Navigator.of(context).pop();
    Navigator.pushNamed(
      context,
      CustomerDetailScreen.routeName,
      arguments: customer,
    ).then((value) {
      if (Helpers.shouldReload(value)) {
        if (!mounted) return;
        _cubit.getCustomers(context: context);
      }
    });
  }

  Future<bool> _canAddNewCustomer(LatLng latLng, double maxDistanceKm) async {
    for (Customer existingCustomer in _cubit.state.records) {
      if (existingCustomer.latitude == null || existingCustomer.latitude == 0) {
        continue;
      }

      final double distInMeters = _location.getDistanceBetween(
        existingCustomer.latitude ?? 0,
        existingCustomer.longitude ?? 0,
        latLng.latitude,
        latLng.longitude,
      );
      final double distInKm = distInMeters / 1000;

      if (distInKm < maxDistanceKm) {
        throw GeneralException(
          greeting(
            "existed_customer",
            params: {
              'name': existingCustomer.name ?? "",
              'km': Helpers.formatNumber(
                maxDistanceKm,
                option: FormatType.quantity,
              ),
            },
          ),
        );
      }
    }

    return true;
  }

  void _addNewCustomer() async {
    final connection = getIt.get<NetworkInfo>();

    if (!await connection.isConnected && mounted) {
      Helpers.showNoInternetDialog(context);
      return;
    }
    final l = LoadingOverlay.of(context);
    l.show();

    try {
      final String setting = await _cubit.getSetting(
        kCheckExistingCustomerByArea,
      );
      if (setting == kStatusYes) {
        final String maxvalue = await _cubit.getSetting(kMaxDistanceKm);
        if (!mounted) return;
        await _cubit.getLatLng(context);
        final location = _cubit.state.latLng;
        if (location == null) {
          throw GeneralException("Cannot get Latitude & Longitude");
        }

        if (!await _canAddNewCustomer(
          LatLng(location.latitude, location.longitude),
          Helpers.toDouble(maxvalue),
        )) {
          return;
        }
      }

      if (!mounted) return;

      l.hide();

      _clearInut(context);
      modalBottomSheet(context, child: _builInputNewCode());
    } on GeneralException catch (e) {
      l.hide();
      showWarningMessage(e.message);
    } on Exception catch (e) {
      l.hide();
      showErrorMessage(e.toString());
    }
  }

  void onclear() async {
    _codeController.clear();
    await _cubit.onClear();
  }

  void _clearInut(BuildContext context) {
    _codeController.clear();
    _cubit.onClear();
    _cubit.isValidate("");
  }

  void _onPushToCreateAddressScreen({Customer? customer}) {
    // Navigator.pushNamed(context, CustomerAddressScreen.routeName, arguments: customer);
    // Navigator.pushNamed(
    //   context,
    //    CustomerAddressScreen(customer: customer).routeName,
    //   arguments: {
    //     'address': address,
    //     'customer': customer,
    //   },
    // ).then((value) {
    //   if (value == null) return;
    //   if (value as bool && value == true) {
    //     _cubit.getCustomers();
    //   }
    // });
  }

  void _showModalFiltter() {
    modalBottomSheet(context, child: _buildFilter());
  }

  String gpsDisplay(double distInMeters) {
    final double distInKm = distInMeters / 1000;

    if (distInKm > 1) {
      return "${Helpers.formatNumberLink(distInKm, option: FormatType.quantity)}km";
    }

    return "${Helpers.formatNumberLink(distInMeters, option: FormatType.quantity)}m";
  }

  Future<void> _onApplyFilter({
    required bool isSort,
    required double distance,
  }) async {
    Navigator.of(context).pop();
    final l = LoadingOverlay.of(context);
    try {
      l.show();
      if (isSort) {
        await _cubit.sortCustomer(
          context: context,
          sortByDistance: true,
          maxDistance: distance > 0 ? distance : null,
        );
      } else {
        await _cubit.sortCustomer(maxDistance: distance, context: context);
      }

      if (!mounted) return;
    } catch (e) {
      showErrorMessage();
    } finally {
      l.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBarWidget(
        title: greeting("customers"),
        actions: [
          BtnIconCircleWidget(
            onPressed: _handleDownload,
            icons: const Icon(Icons.cloud_download_rounded, color: white),
            rounded: appBtnRound,
          ),
          Padding(
            padding: EdgeInsets.only(
              right: scaleFontSize(appSpace),
              left: scaleFontSize(appSpace),
            ),
            child: BtnIconCircleWidget(
              onPressed: () => _addNewCustomer(),
              icons: const Icon(Icons.add, color: white),
              rounded: appBtnRound,
            ),
          ),
        ],
        bottom: SearchWidget(
          onSubmitted: (value) async => _filter(value),
          showPrefixIcon: true,
          suffixIcon: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 4.scale,
              horizontal: 2.scale,
            ),
            child: BtnIconCircleWidget(
              widthIcon: 20,
              heightIcon: 23,
              padiingIcon: 2,
              isShowBadge: false,
              onPressed: () => _showModalFiltter(),
              rounded: 6,
              icons: SvgWidget(
                assetName: kAppOptionIcon,
                colorSvg: white,
                padding: EdgeInsets.all(4.scale),
                width: 18,
                height: 18,
              ),
            ),
          ),
        ),
        heightBottom: heightBottomSearch,
      ),
      body: BlocBuilder<CustomersCubit, CustomersState>(
        bloc: _cubit,
        builder: (BuildContext context, CustomersState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(CustomersState state) {
    final records = state.records;
    if (records.isEmpty) {
      return const EmptyScreen();
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: records.length + 1,
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      itemBuilder: (context, index) {
        if (index == state.records.length) {
          return state.isFetching ? LoadingPageWidget() : const SizedBox();
        }

        final customer = records[index];
        return CustomerCardBox(
          distance: gpsDisplay(Helpers.toDouble(customer.distance)),
          customer: customer,
          onAddAddress: (p0) =>
              _onPushToCreateAddressScreen(customer: customer),
          onEdit: (value) => _editCustomer(customer),
        );
      },
    );
  }

  Widget _builInputNewCode() {
    return BlocBuilder<CustomersCubit, CustomersState>(
      bloc: _cubit,
      builder: (context, state) {
        return Column(
          spacing: 8.scale,
          mainAxisSize: MainAxisSize.min,
          children: [
            HeaderBottomSheet(
              childWidget: TextWidget(
                text: greeting("New Customer No"),
                fontSize: 16,
                color: white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: scaleFontSize(appSpace),
                children: [
                  TextFormFieldWidget(
                    controller: _codeController,
                    isDefaultTextForm: true,
                    suffix: TextBtnWidget(
                      titleBtn: "Clear",
                      colorBtn: textColor50,
                      onTap: () => onclear(),
                    ),
                    label: greeting("Customer No"),
                  ),
                  if (state.messageCode.isNotEmpty)
                    TextWidget(text: state.messageCode, color: error),
                  BtnWidget(
                    gradient: linearGradient,
                    onPressed: () => _onCreateNewCustonerHandler(),
                    title: greeting("Create Now"),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilter() {
    return BlocBuilder<CustomersCubit, CustomersState>(
      bloc: _cubit,
      builder: (context, state) {
        return ButtomSheetFilterWidget(
          child: FilterDistanceCustom(
            distancevalue: state.distanceValue,
            isSortDistance: state.isSortdistance,
            changeSortBy: (bool isSort) => _cubit.isSortDistance(isSort),
            onSelectedDistance: (double v) => _cubit.onChangeDistance(v),
            onChanged: (newValue) => _cubit.onChangeDistance(newValue),
          ),
          onApply: () => _onApplyFilter(
            isSort: state.isSortdistance,
            distance: state.distanceValue * 1000,
          ),
        );
      },
    );
  }
}
