import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/customer_address_form/customer_address_form_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/customer_address/customer_address_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/customer_address/customer_address_state.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CustomerAddressScreen extends StatefulWidget {
  const CustomerAddressScreen({
    super.key,
    required this.customerNo,
    required this.addressCode,
  });

  static const String routeName = "customerAddressTaskScreen";

  final String customerNo;
  final String addressCode;

  @override
  State<CustomerAddressScreen> createState() => _CustomerAddressScreenState();
}

class _CustomerAddressScreenState extends State<CustomerAddressScreen>
    with MessageMixin {
  final _cubit = CustomerAddressCubit();

  @override
  void initState() {
    _cubit.selectAddress(widget.addressCode);
    _cubit.getCustomerAddress(widget.customerNo);
    super.initState();
  }

  void _onSelectedCode(CustomerAddress address) {
    Navigator.pop(context, address);
  }

  void _handleDownload() async {
    final l = LoadingOverlay.of(context);
    l.show();
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      if (!await _cubit.isValidApiSession()) {
        l.hide();
        return;
      }

      List<String> tables = ["customer_address"];

      final filter = tables.map((table) => '"$table"').toList();

      final appSyncLogs = await _cubit.getAppSyncLogs({
        'tableName': 'IN {${filter.join(",")}}',
      });

      if (tables.isEmpty) {
        throw GeneralException("Cannot find any table related");
      }

      await _cubit.downloadDatas(
        appSyncLogs,
        param: {'customer_no': widget.customerNo},
      );

      l.hide();
    } on GeneralException catch (e) {
      l.hide();
      showWarningMessage(e.message);
    } on Exception {
      l.hide();
      showErrorMessage();
    }
  }

  void _onPushToCreateAddressScreen({CustomerAddress? address}) async {
    if (!await _cubit.isConnectedToNetwork()) {
      showWarningMessage(errorInternetMessage);
      // return;
    }

    if (!mounted) return;

    Navigator.pushNamed(
      context,
      CustomerAddressFormScreen.routeName,
      arguments: {'address': address, 'customer': widget.customerNo},
    ).then((value) {
      if (Helpers.shouldReload(value)) {
        _cubit.getCustomerAddress(widget.customerNo);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: "Customer Address",
        actions: [
          Padding(
            padding: EdgeInsets.only(right: scaleFontSize(appSpace8)),
            child: BtnIconCircleWidget(
              onPressed: _handleDownload,
              icons: const Icon(Icons.cloud_download_rounded, color: white),
              rounded: appBtnRound,
            ),
          ),

          Padding(
            padding: EdgeInsets.only(right: scaleFontSize(appSpace)),
            child: BtnIconCircleWidget(
              onPressed: () => _onPushToCreateAddressScreen(address: null),
              icons: const Icon(Icons.add, color: white),
              rounded: appBtnRound,
            ),
          ),
        ],
      ),
      body: BlocBuilder<CustomerAddressCubit, CustomerAddressState>(
        bloc: _cubit,
        builder: (BuildContext context, CustomerAddressState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(CustomerAddressState state) {
    final records = state.records;

    if (records.isEmpty) {
      return const EmptyScreen();
    }

    return ListView.separated(
      itemCount: records.length,
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final record = records[index];
        return ListTitleWidget(
          label: record.name ?? "",
          subTitle: record.code ?? "",
          type: ListTileType.trailingSelect,
          onTap: () => _onSelectedCode(record),
          borderRadius: 0,
          fontWeight: FontWeight.normal,
          isSelected: record.code == state.addressCode,
        );
      },
      separatorBuilder: (context, index) => const Hr(width: double.infinity),
    );
  }
}
