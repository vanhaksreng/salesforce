import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/tab_bar_widget.dart';
import 'package:salesforce/features/more/presentation/pages/customer_address/customer_address_screen.dart';
import 'package:salesforce/features/more/presentation/pages/customer_detail/customer_detail_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/customer_detail/customer_detail_state.dart';
import 'package:salesforce/features/more/presentation/pages/customer_form/customer_form_screen.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.customer});

  static const routeName = "customerDetailScreen";

  final Customer customer;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen>
    with SingleTickerProviderStateMixin, MessageMixin {
  Customer? customer;
  late final TabController _tabController;
  final _cubit = CustomerDetailCubit();
  late ActionState _action = ActionState.init;

  final List<Tab> tabBarName = [
    Tab(text: greeting("cutomer_info")),
    Tab(text: greeting("cutomer_address")),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    customer = widget.customer;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSwitchScreen(int value) {
    if (value == 1 && (customer == null || customer?.status == 'Unsave')) {
      showWarningMessage("You need to save customer first");

      _tabController.index = 0;
      return;
    }

    _cubit.setTabIndex(value);
  }

  void updateCustomer(Customer cus) {
    customer = cus;
    _action = ActionState.updated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBarWidget(
        title: greeting("customer_details"),
        onBack: () => Navigator.of(context).pop(_action),
        heightBottom: heightBottomSearch,
        bottom: BlocBuilder<CustomerDetailCubit, CustomerDetailState>(
          bloc: _cubit,
          builder: (context, state) {
            return TabBarWidget(
              tabs: tabBarName,
              controller: _tabController,
              onTap: _onSwitchScreen,
            );
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          CustomerformScreen(
            customer: widget.customer,
            onCustomerChanged: updateCustomer,
          ),
          CustomerAddressScreen(customer: customer),
        ],
      ),
    );
  }
}
