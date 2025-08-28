import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/presentation/pages/add_schedule/add_schedule_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/task_component/build_select_customer.dart';
import 'package:salesforce/features/tasks/presentation/pages/task_component/choose_address_customer.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class AddScheduleScreen extends StatefulWidget {
  static const String routeName = "addNewSchedule";

  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _cubit = AddScheduleCubit();
  final ValueNotifier<int> selectedCustomerCount = ValueNotifier(0);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _cubit.loadCustomers(page: 1);
    _cubit.getSalePersonSchedule();
    _scrollController.addListener(_handleScrolling);
    super.initState();
  }

  _showError({String msg = errorMessage}) {
    Helpers.showMessage(msg: msg, status: MessageStatus.errors);
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

  void _onSelectedCustomerHandler(
    String customerNo, {
    CustomerAddress? addresss,
  }) async {
    await _processSelectCustomer(customerNo, addresss);
    selectedCustomerCount.value = _cubit.state.selectedCustomers.length;
  }

  Future<void> _processSelectCustomer(
    String customerNo,
    CustomerAddress? addresss,
  ) async {
    bool isExisted = _cubit.state.selectedCustomers.any((e) {
      return e["customer_no"] == customerNo;
    });

    if (isExisted) {
      _cubit.removeSelectedCustomers(customerNo);
      return;
    }

    if (addresss == null) {
      await _cubit.loadCustomersAddress(cusNO: customerNo);
      final customerAddresses = _cubit.state.customerAddresses ?? [];

      if (customerAddresses.isNotEmpty) {
        _showCustomerAddress(customerAddresses);
        return;
      }
    }

    _cubit.addSelectedCustomers(customerNo, addresss);
  }

  _showCustomerAddress(List<CustomerAddress> address) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: false,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(scaleFontSize(16)),
        ),
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        minWidth: MediaQuery.of(context).size.width,
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ChooseAddressCustomer(
              cusAddress: address,
              getValue: "",
              getAddress: (addresss) {
                _onSelectedCustomerHandler(
                  addresss.customerNo ?? "",
                  addresss: addresss,
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _processCreateSchedule() async {
    final l = LoadingOverlay.of(context);
    l.show();
    try {
      final result = await _cubit.createSchedule();
      l.hide();

      if (!result) {
        return;
      }

      if (!mounted) return;
      Navigator.pop(context, ActionState.created);
    } catch (e) {
      l.hide();
      _showError();
    }
  }

  Future<void> createSalePersonSchedule() async {
    if (_cubit.state.selectedCustomers.isEmpty) {
      return;
    }

    Helpers.showDialogAction(
      context,
      confirmText: "yes, i'm sure",
      labelAction: greeting('add_schedules'),
      subtitle: greeting('do_you_want_to_create'),
      confirm: () {
        Navigator.pop(context);
        _processCreateSchedule();
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("add_schedule"),
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
      body: BlocBuilder<AddScheduleCubit, AddScheduleState>(
        bloc: _cubit,
        builder: (context, state) {
          return buildBody(state);
        },
      ),
      persistentFooterButtons: [
        ValueListenableBuilder(
          valueListenable: selectedCustomerCount,
          builder: (context, counted, child) {
            return Visibility(
              visible: counted > 0,
              child: BtnWidget(
                gradient: linearGradient,
                title: greeting("create_schedules"),
                height: 45,
                horizontal: 16,
                vertical: 4,
                extendTitle: counted.toString(),
                onPressed: () => createSalePersonSchedule(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildBody(AddScheduleState state) {
    if (state.isLoading) {
      return const LoadingPageWidget();
    }

    final customers = state.customers;
    if (customers.isEmpty) {
      return const EmptyScreen();
    }

    final schedules = state.schedules ?? [];

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
        final hasSchedule = schedules.any((e) => e.customerNo == customer.no);

        return BuildSelectCustomer(
          key: ValueKey(customer.no),
          isSelected: state.selectedCustomers.any((e) {
            return e["customer_no"] == customer.no;
          }),
          customer: customer,
          onTap: hasSchedule
              ? null
              : () => _onSelectedCustomerHandler(customer.no),
        );
      },
    );
  }
}
