import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_component/qty_input.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_item_competitor_stock/check_item_competitor_stock_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_item_competitor_stock/check_item_competitor_stock_state.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_item_competitor_stock_form.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_stock_submit_preview_competitor_item/check_stock_submit_preview_competitor_item_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/process_components/box_check_stock.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CheckItemCompetitorStockScreen extends StatefulWidget {
  const CheckItemCompetitorStockScreen({super.key, required this.schedule});

  final SalespersonSchedule schedule;

  @override
  State<CheckItemCompetitorStockScreen> createState() =>
      _CheckItemCompetitorStockScreenState();
}

class _CheckItemCompetitorStockScreenState
    extends State<CheckItemCompetitorStockScreen>
    with MessageMixin, PermissionMixin {
  final _cubit = CheckItemCompetitorStockCubit();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _cubit.getCompetitorItemLedgetEntry(
      args: {"schedule_id": widget.schedule.id},
    );

    _cubit.getItems(page: 1);
    _scrollController.addListener(_handleScrolling);
  }

  bool _shouldLoadMore() {
    return _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_cubit.state.isFetching;
  }

  void _handleScrolling() {
    if (_shouldLoadMore()) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() async {
    final page = Helpers.toInt(_cubit.state.currentPage) + 1;
    await _cubit.getItems(page: page, isLoading: false);
  }

  Future<void> _onSearch(String value) async {
    await _cubit.getItems(param: {"description": 'LIKE $value%'});
  }

  _showModalInput(double qtyCount, CompetitorItem item) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      showDragHandle: false,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(scaleFontSize(16)),
        ),
      ),
      builder: (BuildContext context) {
        return _buildInputQty(context, item, qtyCount);
      },
    );
  }

  Future<void> _onUpdateQty(
    CompetitorItem item, {
    required double qtyCount,
  }) async {
    try {
      await _cubit.updateCompititorItemLedgerEntry(
        CheckCompititorItemStockArg(
          item: item,
          stockQty: qtyCount,
          schedule: widget.schedule,
          updateOnlyQty: true,
        ),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      Logger.log(e.toString());
    }
  }

  _navigateToEditStockQty(CompetitorItem item, String? status) {
    return Navigator.pushNamed(
      context,
      CheckItemCompetitorStockForm.routeName,
      arguments: CheckCompititorItemStockArg(
        item: item,
        stockQty: 0,
        schedule: widget.schedule,
        status: status ?? "",
      ),
    ).then((value) {
      if (value != null && value is Map<String, dynamic>) {
        _cubit.getCompetitorItemLedgetEntry(
          args: {"schedule_id": widget.schedule.id},
        );
      }
    });
  }

  _navigateToPreviewScreen() {
    if (_cubit.state.cile.isEmpty) {
      showWarningMessage("Nothing to preview");
      return;
    }

    return Navigator.pushNamed(
      context,
      CheckStockSubmitPreviewCompetitorItemScreen.routeName,
      arguments: widget.schedule,
    ).then((value) {
      if (Helpers.shouldReload(value)) {
        _cubit.getCompetitorItemLedgetEntry(
          args: {"schedule_id": widget.schedule.id},
        );
      }
    });
  }

  Widget _buildInputQty(
    BuildContext context,
    CompetitorItem item,
    double qtyCount,
  ) {
    return SafeArea(
      child: RepaintBoundary(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: QtyInput(
            key: const ValueKey("qty"),
            initialQty: Helpers.formatNumber(
              qtyCount,
              option: FormatType.quantity,
            ),
            onChanged: (value) => _onUpdateQty(item, qtyCount: value),
            modalTitle: item.description,
            inputLabel: "Quantity count",
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          BlocBuilder<
            CheckItemCompetitorStockCubit,
            CheckItemCompetitorStockState
          >(
            bloc: _cubit,
            builder:
                (BuildContext context, CheckItemCompetitorStockState state) {
                  if (state.isLoading) {
                    return const LoadingPageWidget();
                  }

                  return buildBody(state);
                },
          ),
      persistentFooterButtons: [
        SafeArea(
          child:
              BlocBuilder<
                CheckItemCompetitorStockCubit,
                CheckItemCompetitorStockState
              >(
                bloc: _cubit,
                builder: (context, state) {
                  final matching = state.cile
                      .where((entry) => entry.status == kStatusOpen)
                      .toList();
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

  Widget buildBody(CheckItemCompetitorStockState state) {
    return Column(
      children: [
        SearchWidget(
          svgIconColor: primary.withValues(alpha: .5),
          bgColor: white,
          textColor: textColor,
          hintextColor: textColor50,
          borderColor: primary.withValues(alpha: .5),
          onChanged: (value) => _onSearch(value),
          hintText: "Search Cometitor ...",
        ),
        _buildListItem(state),
      ],
    );
  }

  Widget _buildListItem(CheckItemCompetitorStockState state) {
    final items = state.items;
    if (items.isEmpty) {
      return const Center(child: Text('No items found'));
    }
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: scaleFontSize(appSpace8),
          vertical: scaleFontSize(appSpace8),
        ),
        itemCount: state.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = state.items[index];

          final matching = state.cile
              .where(
                (entry) =>
                    entry.itemNo == item.no &&
                    entry.scheduleId?.toString() == widget.schedule.id,
              )
              .toList();

          double qty = 0.0;
          String? status = "";

          if (matching.isNotEmpty) {
            qty = Helpers.toDouble(matching.first.quantity ?? 0.0);

            status = matching.first.status == kStatusSubmit
                ? matching.first.status
                : "";
          }

          return BoxCheckStock(
            key: ValueKey(item.no),
            description: item.description ?? "",
            description2: item.description2 ?? "",
            stockUomCode: item.salesUomCode ?? "",
            status: status ?? "",
            qtyStock: Helpers.formatNumber(qty, option: FormatType.quantity),
            onUpdateQty: (itemQty) => _showModalInput(itemQty, item),
            onEditScreen: () => _navigateToEditStockQty(item, status),
          );
        },
      ),
    );
  }
}
