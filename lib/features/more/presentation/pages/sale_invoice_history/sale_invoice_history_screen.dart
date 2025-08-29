import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/features/more/presentation/pages/add_customer/add_customer_screen.dart';
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
import 'package:salesforce/features/more/presentation/pages/components/sale_bottomsheet_filter.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_history_card_box.dart';
import 'package:salesforce/features/more/presentation/pages/sale_invoice_history/sale_invoice_history_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/sale_invoice_history/sale_invoice_history_state.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_screen.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class SaleInvoiceHistoryScreen extends StatefulWidget {
  const SaleInvoiceHistoryScreen({super.key});
  static const routeName = "SaleInvoiceHistoryScreen";

  @override
  State<SaleInvoiceHistoryScreen> createState() => _SaleInvoiceScreenState();
}

class _SaleInvoiceScreenState extends State<SaleInvoiceHistoryScreen>
    with MessageMixin {
  final _cubit = SaleInvoiceHistoryCubit();

  final ScrollController _scrollController = ScrollController();

  DateTime? initialToDate;
  DateTime? initialFromDate;
  String selectedDate = "This Week";
  String status = "All";

  @override
  void initState() {
    initialFromDate = DateTime.now().firstDayOfWeek();
    initialToDate = DateTime.now().endDayOfWeek();
    _cubit.getSaleInvoice(
      param: {
        'document_type': 'Invoice',
        "posting_date":
            "${initialFromDate?.toDateString()} .. ${initialToDate?.toDateString()}",
      },
    );
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
            _scrollController.position.maxScrollExtent &&
        !_cubit.state.isFetching;
  }

  void _loadMoreItems() async {
    int pages = _cubit.state.currentPage + 1;
    await _cubit.getSaleInvoice(page: pages);
  }

  void _onApplyFilter(Map<String, dynamic> param, BuildContext context) {
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
    final String fromDate = initialFromDate != null
        ? DateTimeExt.parse(initialFromDate.toString()).toDateString()
        : "";
    final String toDate = initialToDate != null
        ? DateTimeExt.parse(initialToDate.toString()).toDateString()
        : "";

    if (fromDate.isNotEmpty && toDate.isNotEmpty) {
      param["posting_date"] = '$fromDate .. $toDate';
    }

    param['document_type'] = 'Invoice';
    status = param["status"];

    param.remove("from_date");
    param.remove("to_date");
    param.remove("date");
    param.remove("isFilter");

    _cubit.getSaleInvoice(param: param, page: 1, fetchingApi: true);

    Navigator.of(context).pop();
  }

  Future<Object?> navigatorToSaleHistoryList(
    BuildContext context,
    List<dynamic> records,
    int index,
  ) {
    return Navigator.pushNamed(
      context,
      SaleOrderHistoryDetailScreen.routeName,
      arguments: {'documentNo': records[index].no, "docType": "Invoice"},
    );
  }

  void _showModalFiltter(BuildContext context) {
    modalBottomSheet(context, child: _buildFilter());
  }

  void _onSearch({String? text}) {
    Map<String, dynamic> param = {'document_type': 'Invoice'};

    if (text != null && text.isNotEmpty) {
      param = {
        // "no": "LIKE %$text%",
        "customer_name": "LIKE %$text%",
      };
    }

    _cubit.getSaleInvoice(param: param, page: 1, fetchingApi: true);
  }

  Future<void> shareSaleOrder(String documentNo) async {
    final l = LoadingOverlay.of(context);
    try {
      l.show();
      final html = await _cubit.getInvoiceHtml(
        documentNo: documentNo,
        documenType: "Invoice",
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
      return;
    }
  }

  Future<void> pushToAddCustomer() =>
      Navigator.pushNamed(
        context,
        AddCustomerScreen.routeName,
        arguments: kSaleInvoice,
      ).then((value) async {
        await _cubit.getSaleInvoice(
          param: {
            'document_type': 'Invoice',
            "posting_date":
                "${initialFromDate?.toDateString()} .. ${initialToDate?.toDateString()}",
          },
        );
      });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBarWidget(
        title: greeting("sale_invoice"),
        actions: [
          BtnIconCircleWidget(
            onPressed: () => pushToAddCustomer(),
            icons: Icon(Icons.add, color: white),
            rounded: appBtnRound,
          ),
          Helpers.gapW(appSpace),
        ],
        heightBottom: heightBottomSearch,
        bottom: SearchWidget(
          showPrefixIcon: true,
          suffixIcon: BtnIconCircleWidget(
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
          onSubmitted: (text) => _onSearch(text: text),
          hintText: greeting("Find Sale Invoice..."),
        ),
      ),
      body: BlocBuilder<SaleInvoiceHistoryCubit, SaleInvoiceHistoryState>(
        bloc: _cubit,
        builder: (BuildContext context, SaleInvoiceHistoryState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(SaleInvoiceHistoryState state) {
    final records = state.records;

    if (records.isEmpty) {
      return const EmptyScreen();
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: records.length,
      padding: const EdgeInsets.all(appSpace),
      itemBuilder: (context, index) => SaleHistoryCardBox(
        header: records[index],
        onTapShare: () => shareSaleOrder(records[index].no ?? ""),
        onTap: () => navigatorToSaleHistoryList(context, records, index),
      ),
    );
  }

  BlocBuilder<SaleInvoiceHistoryCubit, SaleInvoiceHistoryState> _buildFilter() {
    return BlocBuilder<SaleInvoiceHistoryCubit, SaleInvoiceHistoryState>(
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
