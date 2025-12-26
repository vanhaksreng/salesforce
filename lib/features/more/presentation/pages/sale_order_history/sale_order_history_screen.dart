import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/features/more/domain/entities/add_customer_arg.dart';
import 'package:salesforce/features/more/presentation/pages/add_customer/add_customer_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_screen.dart';
import 'package:salesforce/features/more/presentation/pages/upload/upload_screen.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:share_plus/share_plus.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/bottom_sheet_fn.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_history_card_box.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_bottomsheet_filter.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history/sale_order_history_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history/sale_order_history_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class SaleOrderHistoryScreen extends StatefulWidget {
  static const String routeName = "SaleOrderItemScreen";

  const SaleOrderHistoryScreen({super.key});

  @override
  State<SaleOrderHistoryScreen> createState() => _SaleOrderScreenState();
}

class _SaleOrderScreenState extends State<SaleOrderHistoryScreen>
    with MessageMixin, RouteAware {
  final _cubit = SaleOrderHistoryCubit();

  final ScrollController _scrollController = ScrollController();
  DateTime? initialToDate;
  DateTime? initialFromDate;
  String selectedDate = "This Week";
  String status = "All";
  String isShowAddCustomer = kStatusYes;

  @override
  void initState() {
    super.initState();
    initialFromDate = DateTime.now().firstDayOfWeek();
    initialToDate = DateTime.now().endDayOfWeek();
    getShowAddCustomer();
    _getSaleOrder();

    _scrollController.addListener(_handleScrolling);
  }

  getShowAddCustomer() async {
    isShowAddCustomer = await _cubit.isShowAccCustomer();
  }

  void _handleScrolling() {
    if (_shouldLoadMore()) {
      _loadMoreItems();
    }
  }

  bool _shouldLoadMore() {
    return _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _cubit.state.currentPage < _cubit.state.lastPage;
  }

  void _loadMoreItems() async {
    int pages = _cubit.state.currentPage + 1;
    await _getSaleOrder(pages);
  }

  void _onSearch({String? text}) {
    Map<String, dynamic> param = {'document_type': 'Order'};

    if (text != null && text.isNotEmpty) {
      param = {
        // "no": "LIKE %$text%",
        "customer_name": "LIKE %$text%",
      };
    }

    _cubit.getSaleOrders(param: param, page: 1, fetchingApi: true);
  }

  Future<Object?> navigatorToSaleCard(
    BuildContext context,
    SalesHeader record,
  ) {
    return Navigator.pushNamed(
      context,
      SaleOrderHistoryDetailScreen.routeName,
      arguments: {
        'documentNo': record.no,
        "docType": kSaleOrder,
        "isSync": record.isSync,
      },
    );
  }

  void _onApplyFilter(Map<String, dynamic> param, BuildContext context) async {
    Navigator.of(context).pop();
    if (param.isEmpty) return;

    if (param["from_date"] != null) {
      initialFromDate = param["from_date"];
    } else {
      initialFromDate = null;
    }

    if (param["to_date"] != null) {
      initialToDate = param["to_date"];
    } else {
      initialToDate = null;
    }

    if (param["date"] != null) {
      selectedDate = param["date"];
    } else {
      selectedDate = "";
    }

    // Build API parameters
    Map<String, dynamic> apiParam = {'document_type': 'Order'};

    // Add date range if both dates exist
    final String fromDate = initialFromDate != null
        ? DateTimeExt.parse(initialFromDate.toString()).toDateString()
        : "";
    final String toDate = initialToDate != null
        ? DateTimeExt.parse(initialToDate.toString()).toDateString()
        : "";

    if (fromDate.isNotEmpty && toDate.isNotEmpty) {
      apiParam["posting_date"] = '$fromDate .. $toDate';
    }

    // Handle status filter
    if (param["status"] != null && param["status"] != "All") {
      status = param["status"];
      apiParam["status"] = param["status"];
    } else {
      status = "All";
      // Don't add status filter if it's "All"
    }

    await _cubit.getSaleOrders(param: apiParam, page: 1, fetchingApi: true);
  }

  void _showModalFiltter(BuildContext context) {
    modalBottomSheet(context, child: _buildFilter());
  }

  Future<void> shareSaleOrder(String documentNo) async {
    final l = LoadingOverlay.of(context);
    l.show();

    try {
      final html = await _cubit.getInvoiceHtml(
        documentNo: documentNo,
        documenType: "Order",
      );

      if (html.isEmpty) {
        l.hide();
        return;
      }

      final pdfFile = await Helpers.generateToPdfDocument(
        htmlContent: html,
        documentNo: documentNo,
      );

      if (pdfFile == null) {
        l.hide();
        return;
      }

      l.hide();
      await SharePlus.instance.share(ShareParams(files: [XFile(pdfFile.path)]));
    } catch (e) {
      showErrorMessage(e.toString());
      l.hide();
    }
  }

  Future<void> _getSaleOrder([int page = 1]) {
    return _cubit.getSaleOrders(
      page: page,
      param: {
        'document_type': kSaleOrder,
        "posting_date":
            "${initialFromDate?.toDateString()} .. ${initialToDate?.toDateString()}",
      },
    );
  }

  Future<void> _getBackAction() {
    return Navigator.pushNamed(context, UploadScreen.routeName).then((action) {
      if (action == null) return;
      if (Helpers.shouldReload(action as ActionState)) {
        _getSaleOrder();
      }
    });
  }

  Future<void> pushToAddCustomer() =>
      Navigator.pushNamed(
        context,
        AddCustomerScreen.routeName,
        arguments: AddCustomerArg(documentType: kSaleOrder),
      ).then((value) {
        if (value == null) return;
        if (value as bool) {
          _getSaleOrder();
        }
      });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBarWidget(
        title: greeting("sale_orders"),
        onBack: () => Navigator.of(context).pop(ActionState.updated),
        actions: [
          BlocBuilder<SaleOrderHistoryCubit, SaleOrderHistoryState>(
            bloc: _cubit,
            builder: (context, state) {
              bool isHasUpload = state.records.any(
                (e) => e.isSync == kStatusNo,
              );
              if (!isHasUpload) {
                return SizedBox.shrink();
              }
              return BtnIconCircleWidget(
                isShowBadge: true,
                onPressed: () => _getBackAction(),
                icons: Icon(Icons.upload, color: white),
                rounded: appBtnRound,
              );
            },
          ),
          Helpers.gapW(appSpace8),
          if (isShowAddCustomer == kStatusYes) ...[
            BtnIconCircleWidget(
              onPressed: () => pushToAddCustomer(),
              icons: Icon(Icons.add, color: white),
              rounded: appBtnRound,
            ),
            Helpers.gapW(appSpace),
          ],
        ],
        heightBottom: heightBottomSearch,
        bottom: SearchWidget(
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
              onPressed: () => _showModalFiltter(context),
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
          onSubmitted: (text) => _onSearch(text: text),
          hintText: greeting("Find Sale Orders..."),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _getSaleOrder(),
        child: BlocBuilder<SaleOrderHistoryCubit, SaleOrderHistoryState>(
          bloc: _cubit,
          builder: (BuildContext context, SaleOrderHistoryState state) {
            if (state.isLoading) {
              return const LoadingPageWidget();
            }
            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(appSpace),
                  sliver: _buildBody(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(SaleOrderHistoryState state) {
    final records = state.records;

    if (records.isEmpty) {
      return SliverFillRemaining(child: const EmptyScreen());
    }

    return SliverList.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        return SaleHistoryCardBox(
          header: records[index],

          onTapShare: () => shareSaleOrder(records[index].no ?? ""),
          onTap: () => navigatorToSaleCard(context, records[index]),
        );
      },
    );
  }

  BlocBuilder<SaleOrderHistoryCubit, SaleOrderHistoryState> _buildFilter() {
    return BlocBuilder<SaleOrderHistoryCubit, SaleOrderHistoryState>(
      bloc: _cubit,
      builder: (context, state) {
        return SaleBottomsheetFilter(
          fromDate: initialFromDate,
          toDate: initialToDate,
          selectDate: selectedDate,
          onApply: (value) => _onApplyFilter(value, context),
          status: status,
        );
      },
    );
  }
}
