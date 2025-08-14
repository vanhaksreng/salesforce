import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_component/qty_input.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_item_stock/check_item_stock_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_item_stock/check_item_stock_state.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_stock_submit_preview/check_stock_submit_preview_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_stock_form_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/process_components/box_check_stock.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CheckItemStockScreen extends StatefulWidget {
  const CheckItemStockScreen({super.key, required this.schedule, required this.customerNo});

  final SalespersonSchedule schedule;
  final String customerNo;

  @override
  State<CheckItemStockScreen> createState() => _CheckItemStockScreenState();
}

class _CheckItemStockScreenState extends State<CheckItemStockScreen> with MessageMixin, PermissionMixin {
  final _screenCubit = CheckItemStockCubit();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _screenCubit.getItems();
    _screenCubit.getCustomerItemLegerEntries(args: {"schedule_id": widget.schedule.id});
    _scrollController.addListener(_handleScrolling);
  }

  void _handleScrolling() {
    if (_shouldLoadMore()) {
      _loadMoreItems();
    }
  }

  bool _shouldLoadMore() {
    return _scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        !_screenCubit.state.isFetching;
  }

  Future<void> _loadMoreItems() async {
    final page = Helpers.toInt(_screenCubit.state.currentPage) + 1;
    await _screenCubit.getItems(page: page);
  }

  _showModalInput(double qtyCount, Item item) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      showDragHandle: false,
      isDismissible: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(scaleFontSize(16)))),
      builder: (BuildContext context) {
        return _buildInputQty(context, item, qtyCount);
      },
    );
  }

  Future<void> _onUpdateQty(Item item, {required double qtyCount}) async {
    try {
      await _screenCubit.updateItemCheckStock(
        CheckItemStockArg(item: item, stockQty: qtyCount, schedule: widget.schedule, updateOnlyQty: true),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      Logger.log(e.toString());
    }
  }

  _navigateToEditStockQty(Item item, String? status) {
    return Navigator.pushNamed(
      context,
      CheckStockFormScreen.routeName,
      arguments: {"item": item, "schedule": widget.schedule, "status": status},
    ).then((value) {
      if (value != null && value is Map<String, dynamic>) {
        _screenCubit.getCustomerItemLegerEntries(args: {"schedule_id": widget.schedule.id});
      }
    });
  }

  _navigateToPreviewScreen() {
    if (_screenCubit.state.cile.isEmpty) {
      showWarningMessage("Nothing to preview");
      return;
    }

    return Navigator.pushNamed(
      context,
      CheckStockSubmitPreviewScreen.routeName,
      arguments: CheckStockArgs(schedule: widget.schedule, customerNo: widget.customerNo),
    ).then((value) {
      _screenCubit.getCustomerItemLegerEntries(args: {"schedule_id": widget.schedule.id});
    });
  }

  Future<void> _onSearch(String value) async {
    await _screenCubit.getItems(param: {"description": 'LIKE $value%'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<CheckItemStockCubit, CheckItemStockState>(
        bloc: _screenCubit,
        builder: (BuildContext context, CheckItemStockState state) {
          return buildBody(state);
        },
      ),
      persistentFooterButtons: [
        SafeArea(
          child: BlocBuilder<CheckItemStockCubit, CheckItemStockState>(
            bloc: _screenCubit,
            builder: (context, state) {
              final matching = state.cile.where((entry) => entry.status == kStatusOpen).toList();
              return BtnWidget(
                gradient: linearGradient,
                horizontal: scaleFontSize(appSpace8),
                title: "${greeting("Preview")} (${matching.length})",
                onPressed: () => _navigateToPreviewScreen(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildBody(CheckItemStockState state) {
    return Column(
      children: [
        SearchWidget(
          svgIconColor: primary.withValues(alpha: .5),
          bgColor: white,
          textColor: textColor,
          hintextColor: textColor50,
          borderColor: primary.withValues(alpha: .5),
          onChanged: (value) => _onSearch(value),
          hintText: "Search items ...",
        ),
        _buildListItem(state),
      ],
    );
  }

  Widget _buildListItem(CheckItemStockState state) {
    final items = state.items;
    if (items.isEmpty) {
      return const Center(child: Text('No items found'));
    }

    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace8), vertical: scaleFontSize(appSpace8)),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];
          final matching = state.cile
              .where((entry) => entry.itemNo == item.no && entry.scheduleId?.toString() == widget.schedule.id)
              .toList();

          double qty = 0.0;
          String? status = "";

          if (matching.isNotEmpty) {
            qty = Helpers.toDouble(matching.first.quantity ?? 0.0);
            status = matching.first.status == "Submitted" ? matching.first.status : "";
          }

          return BoxCheckStock(
            key: ValueKey(item.no),
            description: item.description ?? "",
            description2: item.description2 ?? "",
            stockUomCode: item.stockUomCode ?? "",
            status: status ?? "",
            imgUrl: item.picture ?? "",
            qtyStock: Helpers.formatNumber(qty, option: FormatType.quantity),
            onUpdateQty: (itemQty) => _showModalInput(itemQty, item),
            onEditScreen: () => _navigateToEditStockQty(item, status),
          );
        },
      ),
    );
  }

  Widget _buildInputQty(BuildContext context, Item item, double qtyCount) {
    return SafeArea(
      child: RepaintBoundary(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: QtyInput(
            key: const ValueKey("qty"),
            initialQty: Helpers.formatNumber(qtyCount, option: FormatType.quantity),
            onChanged: (value) => _onUpdateQty(item, qtyCount: value),
            modalTitle: item.description,
            inputLabel: "Quantity count",
          ),
        ),
      ),
    );
  }
}
