import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
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
import 'package:salesforce/core/presentation/widgets/header_bottom_sheet.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_btn_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/components/customer_card_box.dart';
import 'package:salesforce/features/more/presentation/pages/customer_detail/customer_detail_screen.dart';
import 'package:salesforce/features/more/presentation/pages/customers/customers_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/customers/customers_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);
  static const routeName = "CustomersScreen";

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> with MessageMixin {
  final _cubit = CustomersCubit();
  final _codeController = TextEditingController();
  bool isValidation = false;
  String text = '';

  @override
  void initState() {
    _cubit.getCustomers(page: 1);
    super.initState();
  }

  _filter(String text) {
    _cubit.getCustomers(page: 1, params: {'name': "LIKE %$text%"});
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

      final tables = await _cubit.getAppSyncLogs({'tableName': 'IN {"customer","customer_address"}'});

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

      await _cubit.getCustomers(page: 1);

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
    Navigator.pushNamed(context, CustomerDetailScreen.routeName, arguments: customer).then((value) {
      if (Helpers.shouldReload(value)) {
        _cubit.getCustomers();
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
    Navigator.pushNamed(context, CustomerDetailScreen.routeName, arguments: customer).then((value) {
      if (Helpers.shouldReload(value)) {
        _cubit.getCustomers();
      }
    });
  }

  Future<bool> _canAddNewCustomer(LatLng latLng, double maxDistanceKm) async {
    for (Customer existingCustomer in _cubit.state.records) {
      if (existingCustomer.latitude == null || existingCustomer.latitude == 0) {
        continue;
      }

      const Distance distance = Distance();

      final LatLng customerLatLng = LatLng(existingCustomer.latitude ?? 0, existingCustomer.longitude ?? 0);

      final double distInMeters = distance(customerLatLng, latLng);
      final double distInKm = distInMeters / 1000;

      if (distInKm < maxDistanceKm) {
        throw GeneralException(
          greeting(
            "existed_customer",
            params: {
              'name': existingCustomer.name ?? "",
              'km': Helpers.formatNumber(maxDistanceKm, option: FormatType.quantity),
            },
          ),
        );
      }
    }

    return true;
  }

  void _addNewCustomer() async {
    final l = LoadingOverlay.of(context);
    l.show();

    try {
      final String setting = await _cubit.getSetting(kCheckExistingCustomerByArea);
      if (setting == kStatusYes) {
        final String maxvalue = await _cubit.getSetting(kMaxDistanceKm);

        await _cubit.getLatLng();
        final location = _cubit.state.latLng;
        if (location == null) {
          throw GeneralException("Cannot get Latitude & Longitude");
        }

        if (!await _canAddNewCustomer(LatLng(location.latitude, location.longitude), Helpers.toDouble(maxvalue))) {
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
            padding: EdgeInsets.only(right: scaleFontSize(appSpace), left: scaleFontSize(appSpace)),
            child: BtnIconCircleWidget(
              onPressed: () => _addNewCustomer(),
              icons: const Icon(Icons.add, color: white),
              rounded: appBtnRound,
            ),
          ),
        ],
        bottom: SearchWidget(onSubmitted: (value) async => _filter(value)),
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
      itemCount: records.length,
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      itemBuilder: (context, index) {
        final customer = records[index];
        return CustomerCardBox(
          customer: customer,
          onAddAddress: (p0) => _onPushToCreateAddressScreen(customer: customer),
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
                    suffix: TextBtnWidget(titleBtn: "clear", colorBtn: textColor50, onTap: () => onclear()),
                    label: greeting("Customer No"),
                  ),
                  if (state.messageCode.isNotEmpty) TextWidget(text: state.messageCode, color: error),
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
}
