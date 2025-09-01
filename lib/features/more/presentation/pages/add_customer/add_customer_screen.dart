import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';

import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/domain/entities/add_customer_arg.dart';
import 'package:salesforce/features/more/domain/entities/item_sale_arg.dart';
import 'package:salesforce/features/more/presentation/pages/add_customer/add_customer_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/add_customer/add_customer_state.dart';
import 'package:salesforce/features/more/presentation/pages/items/items_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/task_component/build_select_customer.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key, required this.addCustomerArg});
  static const String routeName = "addCustomerScreen";
  final AddCustomerArg addCustomerArg;

  @override
  AddCustomerScreenState createState() => AddCustomerScreenState();
}

class AddCustomerScreenState extends State<AddCustomerScreen> {
  final _cubit = AddCustomerCubit();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _cubit.loadCustomers(page: 1);
    _scrollController.addListener(_handleScrolling);
    super.initState();
  }

  void _handleScrolling() {
    if (_shouldLoadMore()) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    _cubit.loadCustomers(page: _cubit.state.currentPage + 1, isLoading: false);
  }

  bool _shouldLoadMore() {
    return !_cubit.state.isLoadingMore &&
        _cubit.state.currentPage != _cubit.state.lastPage &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent;
  }

  void _handleDownload() async {
    final l = LoadingOverlay.of(context);
    try {
      l.show(1);

      if (!await _cubit.isValidApiSession()) {
        l.hide();
        return;
      }

      final tables = await _cubit.getAppSyncLogs({
        'tableName': 'IN {"customer", "customer_address"}',
      });

      if (tables.isEmpty) {
        throw GeneralException("Cannot find any table related");
      }

      await Future.delayed(const Duration(milliseconds: 300));
      const String msg = "System will download only related data.";
      await _cubit.downloadDatas(
        tables,
        onProgress: (progress, p1, tableName, errorMsg) {
          l.updateProgress(progress, text: msg);
        },
      );

      await Future.delayed(const Duration(milliseconds: 300));
      await _cubit.loadCustomers(page: 1, isLoading: false);
      l.hide();
    } on GeneralException catch (e) {
      l.hide();
      _showError(msg: e.message);
    } on Exception {
      l.hide();
      _showError();
    }
  }

  _onSearch(String value) {
    _cubit.loadCustomers(page: 1, param: {"name": 'LIKE $value%'});
  }

  _showError({String msg = errorMessage}) {
    Helpers.showMessage(msg: msg, status: MessageStatus.errors);
  }

  void showMessageSelect(Customer customer) {
    Helpers.showDialogAction(
      context,
      labelAction: greeting("confirm"),
      subtitle: greeting("Are you sure to selected ${customer.name}"),
      confirmText: "Yes , Confirm",
      confirm: () {
        _cubit.selectCustomer(customer);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          ItemsScreen.routeName,
          arguments: ItemSaleArg(
            isRefreshing: false,
            customer: customer,
            documentType: widget.addCustomerArg.documentType,
          ),
        ).then((value) {
          if (value == null) return;
          widget.addCustomerArg.onRefresh?.call(value as bool);
          if (!mounted) return;
          Navigator.pop(context);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("Customers"),
        heightBottom: heightBottomSearch,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: scaleFontSize(appSpace)),
            child: BtnIconCircleWidget(
              icons: const Icon(Icons.cloud_download_rounded, color: white),
              onPressed: _handleDownload,
            ),
          ),
        ],
        bottom: SearchWidget(onChanged: (value) => _onSearch(value)),
      ),
      body: BlocBuilder<AddCustomerCubit, AddCustomerState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) {
            return LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(AddCustomerState state) {
    if (state.isLoading) {
      return const LoadingPageWidget();
    }

    final customers = state.customers;
    if (customers.isEmpty) {
      return const EmptyScreen();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: scaleFontSize(appSpace8)),
      controller: _scrollController,
      itemCount: customers.length + 1,
      itemBuilder: (context, index) {
        if (index == customers.length) {
          if (state.currentPage == state.lastPage) {
            return const SizedBox.shrink();
          }
          return const LoadingPageWidget();
        }

        final customer = customers[index];

        return BuildSelectCustomer(
          key: ValueKey(customer.no),
          isSelected: state.customer == customer,
          customer: customer,
          onTap: () => showMessageSelect(customer),
        );
      },
    );
  }
}
