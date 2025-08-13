import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/components/address_card_box.dart';
import 'package:salesforce/features/more/presentation/pages/components/build_header.dart';
import 'package:salesforce/features/more/presentation/pages/customer_address/customer_address_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/customer_address/customer_address_state.dart';
import 'package:salesforce/features/more/presentation/pages/customer_address_form/customer_address_form_screen.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class CustomerAddressScreen extends StatefulWidget {
  const CustomerAddressScreen({Key? key, required this.customer}) : super(key: key);

  final Customer? customer;
  static const routeName = "customerAddressScreen";

  @override
  State<CustomerAddressScreen> createState() => _CustomerAddressScreenState();
}

class _CustomerAddressScreenState extends State<CustomerAddressScreen> with MessageMixin {
  final _cubit = CustomerAddressCubit();

  @override
  void initState() {
    super.initState();
    _cubit.getCustomerAddress(param: {"customer_no": widget.customer?.no});
  }

  Future<void> _onDeleteAddress(CustomerAddress address) async {
    try {
      Helpers.showDialogAction(
        context,
        confirm: () async {
          await _cubit.deletedCusAddress(address);
          if (!mounted) return;

          Navigator.pop(context, true);
        },
      );
    } catch (e) {
      Navigator.pop(context, false);
      showErrorMessage(e.toString());
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
      arguments: {'address': address, 'customer': widget.customer},
    ).then((value) {
      if (Helpers.shouldReload(value)) {
        _cubit.getCustomerAddress(param: {"customer_no": widget.customer?.no});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CustomerAddressCubit, CustomerAddressState>(
        bloc: _cubit,
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(appSpace),
            child: Column(spacing: 8.scale, children: [_buildBttnAddNew(), _buildListView(state)]),
          );
        },
      ),
    );
  }

  Widget _buildListView(CustomerAddressState state) {
    final address = state.cusAddresss;

    if (address.isEmpty) {
      return const EmptyScreen();
    }

    return BoxWidget(
      padding: EdgeInsets.all(scaleFontSize(8.scale)),
      child: Column(
        children: [
          const BuildHeader(icon: Icons.home_rounded, label: "currently_address"),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 8.scale),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: address.length,
            itemBuilder: (context, index) {
              final addr = address[index];
              return AddressCardBox(
                address: addr,
                onEdit: () => _onPushToCreateAddressScreen(address: addr),
                onDelete: () => _onDeleteAddress(addr),
              );
            },
          ),
        ],
      ),
    );
  }

  BtnWidget _buildBttnAddNew() {
    return BtnWidget(
      icon: Icon(Icons.add, size: 20.scale),
      title: greeting("add_new_address"),
      fntSize: 16,
      size: BtnSize.medium,
      gradient: linearGradient,
      onPressed: () => _onPushToCreateAddressScreen(address: null),
    );
  }
}
