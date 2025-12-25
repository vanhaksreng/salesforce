import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_screen.dart';
import 'package:salesforce/features/more/presentation/pages/upload/upload_screen.dart';
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
import 'package:salesforce/features/more/presentation/pages/sale_credit_memo_history/sale_credit_memo_history_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/sale_credit_memo_history/sale_credit_memo_history_state.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_screen_old.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class SaleCreditMemoHistoryScreen extends StatefulWidget {
  const SaleCreditMemoHistoryScreen({super.key});

  static const routeName = "SaleCreditMemoHistoryScreen";

  @override
  State<SaleCreditMemoHistoryScreen> createState() =>
      _SaleCreditMemoScreenState();
}

class _SaleCreditMemoScreenState extends State<SaleCreditMemoHistoryScreen>
    with MessageMixin {
  final _cubit = SaleCreditMemoHistoryCubit();
  final ScrollController _scrollController = ScrollController();

  DateTime? initialToDate;
  DateTime? initialFromDate;
  String selectedDate = "This Week";
  String status = "All";

  @override
  void initState() {
    initialFromDate = DateTime.now().firstDayOfWeek();
    initialToDate = DateTime.now().endDayOfWeek();
    _cubit.getSaleCreditMemo(
      param: {
        'document_type': 'Credit Memo',
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
    await _cubit.getSaleCreditMemo(page: pages);
  }

  void _onApplyFilter(Map<String, dynamic> param, BuildContext context) async {
    if (param.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

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

    param['document_type'] = 'Credit Memo';

    if (param["status"] != null) {
      status = param["status"];
      if (status == "All") {
        param.remove("status");
      }
    }

    param.remove("from_date");
    param.remove("to_date");
    param.remove("date");
    param.remove("isFilter");

    Navigator.of(context).pop();

    await _cubit.getSaleCreditMemo(param: param, page: 1, fetchingApi: true);
  }

  void _showModalFiltter(BuildContext context) {
    modalBottomSheet(context, child: _buildFilter());
  }

  void _onSearch({String? text}) {
    Map<String, dynamic> param = {'document_type': 'Credit Memo'};

    if (text != null && text.isNotEmpty) {
      param = {
        // "no": "LIKE %$text%",
        "customer_name": "LIKE %$text%",
      };
    }

    _cubit.getSaleCreditMemo(param: param, page: 1, fetchingApi: true);
  }

  Future<Object?> navigatorToSaleHistoryList(
    BuildContext context,
    List<dynamic> records,
    int index,
  ) {
    return Navigator.pushNamed(
      context,
      SaleOrderHistoryDetailScreen.routeName,
      arguments: {
        'documentNo': records[index].no,
        "docType": "Credit Memo",
        "isSync": records[index].isSync,
      },
    );
  }

  Future<void> shareSaleOrder(String documentNo) async {
    final l = LoadingOverlay.of(context);
    try {
      l.show();
      final html = await _cubit.getInvoiceHtml(
        documentNo: documentNo,
        documenType: "Credit Memo",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBarWidget(
        onBack: () => Navigator.of(context).pop(ActionState.updated),
        title: greeting("sale_credit_memo"),
        actions: [
          // BlocBuilder<SaleCreditMemoHistoryCubit, SaleCreditMemoHistoryState>(
          //   bloc: _cubit,
          //   builder: (context, state) {
          //     bool isHasUpload = state.records.any(
          //       (e) => e.isSync == kStatusNo,
          //     );
          //     if (!isHasUpload) {
          //       return SizedBox.shrink();
          //     }
          //     return BtnIconCircleWidget(
          //       isShowBadge: true,
          //       onPressed: () {
          //         Navigator.pushNamed(context, UploadScreen.routeName);
          //       },
          //       icons: Icon(Icons.upload, color: white),
          //       rounded: appBtnRound,
          //     );
          //   },
          // ),
          BtnIconCircleWidget(
            onPressed: () => _showModalFiltter(context),
            icons: SvgWidget(
              assetName: kAppOptionIcon,
              colorSvg: white,
              padding: EdgeInsets.all(4.scale),
              width: 18,
              height: 18,
            ),
            rounded: appBtnRound,
          ),
          Helpers.gapW(appSpace),
        ],
        heightBottom: heightBottomSearch,
        bottom: SearchWidget(
          onSubmitted: (text) => _onSearch(text: text),
          hintText: greeting("Find Sale Credit Memo..."),
        ),
      ),
      body: BlocBuilder<SaleCreditMemoHistoryCubit, SaleCreditMemoHistoryState>(
        bloc: _cubit,
        builder: (BuildContext context, SaleCreditMemoHistoryState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(SaleCreditMemoHistoryState state) {
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

  BlocBuilder<SaleCreditMemoHistoryCubit, SaleCreditMemoHistoryState>
  _buildFilter() {
    return BlocBuilder<SaleCreditMemoHistoryCubit, SaleCreditMemoHistoryState>(
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
