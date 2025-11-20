import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/stock/domain/entities/stock_args.dart';
import 'package:salesforce/features/stock/main_page_stock_cubit.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_box/stock_box.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_request/stock_request_screen.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class MainPageStockScreen extends StatefulWidget {
  const MainPageStockScreen({super.key});

  @override
  State<MainPageStockScreen> createState() => _MainPageStockScreenState();
}

class _MainPageStockScreenState extends State<MainPageStockScreen>
    with MessageMixin {
  final _cubit = MainPageStockCubit();
  final ValueNotifier<bool> isFloatingBtn = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<int> page = ValueNotifier<int>(1);
  final ScrollController _scrollController = ScrollController();

  ActionState action = ActionState.init;

  @override
  void initState() {
    _cubit.getItems();
    _cubit.getItemWorkSheets(
      param: {
        'quantity': '>0',
        'status': 'IN {"$kStatusPending","$kStatusNew"}',
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
        _scrollController.position.maxScrollExtent;
  }

  void _loadMoreItems() async {
    page.value++;
    await _cubit.getItems(page: page.value, isLoading: false).then((_) {
      isLoading.value = false;
    });
  }

  void _onStoreStockRequest(double value, String uomCode, Item item) async {
    await _cubit.storeStockRequest(
      item: item,
      quantity: value,
      itemUomCode: uomCode,
    );
  }

  void _navigateToStockRequest(String docNo) {
    Navigator.pushNamed(
      context,
      StockRequestScreen.routeName,
      arguments: StockRequestArg(documentNo: docNo),
    ).then((value) async {
      await _cubit.getItemWorkSheets();
      if (Helpers.shouldReload(value)) {
        _handleDownload();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    isLoading.dispose();
    page.dispose();
    super.dispose();
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

      List<String> tables = ["item"];

      final filter = tables.map((table) => '"$table"').toList();

      final appSyncLogs = await _cubit.getAppSyncLogs({
        'tableName': 'IN {${filter.join(",")}}',
      });

      if (tables.isEmpty) {
        throw GeneralException("Cannot find any table related");
      }

      await _cubit.downloadDatas(appSyncLogs);

      l.hide();

      _cubit.getItems();
    } on GeneralException catch (e) {
      l.hide();
      showWarningMessage(e.message);
    } on Exception {
      l.hide();
      showErrorMessage();
    }
  }

  _onSearch(String value) async {
    await _cubit.getItems(param: {"description": 'LIKE $value%'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: "Stock",
        isBackIcon: false,
        heightBottom: heightBottomSearch,
        bottom: SearchWidget(
          hintText: "Search item",
          onChanged: (value) => _onSearch(value),
          onSubmitted: (value) => _onSearch(value),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: scaleFontSize(appSpace)),
            child: BtnIconCircleWidget(
              onPressed: _handleDownload,
              icons: const Icon(Icons.cloud_download_rounded, color: white),
              rounded: appBtnRound,
            ),
          ),
        ],
      ),
      body: BlocBuilder<MainPageStockCubit, MainPageStockState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          final items = state.items;
          if (items.isEmpty) {
            return const EmptyScreen();
          }

          final itemWorkSheets = state.itemWorkSheet;
          final readonly = itemWorkSheets.any((e) => e.status != "New");

          return ListView.builder(
            controller: _scrollController,
            itemCount: items.length + 1,
            addAutomaticKeepAlives: false,
            padding: EdgeInsets.all(scaleFontSize(appSpace)),
            itemBuilder: (context, int index) {
              if (index == items.length) {
                return const LoadingPageWidget();
              }

              final item = items[index];

              double qty = 0;
              String uom = item.stockUomCode ?? "";
              final atIndex = itemWorkSheets.indexWhere(
                (worksheet) => worksheet.itemNo == item.no,
              );

              if (atIndex != -1) {
                qty = itemWorkSheets[atIndex].quantity;
                uom = itemWorkSheets[atIndex].unitOfMeasureCode ?? uom;
              }

              return StockBox(
                isReadonly: readonly,
                key: ValueKey(item.no),
                qty: Helpers.formatNumberLink(qty, option: FormatType.quantity),
                uom: uom,
                item: item,
                onChangedUom: (qty, uom) =>
                    _onStoreStockRequest(qty, uom, item),
                onChangedQty: (qty, uom) =>
                    _onStoreStockRequest(qty, uom, item),
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<MainPageStockCubit, MainPageStockState>(
        bloc: _cubit,
        builder: (context, state) {
          final itemRequest = state.itemWorkSheet;

          return SizedBox(
            width: 45.scale,
            height: 45.scale,
            child: FloatingActionButton(
              backgroundColor: mainColor,
              heroTag: null,
              onPressed: () =>
                  _navigateToStockRequest(itemRequest.first.documentNo ?? ""),
              child: Badge(
                isLabelVisible: itemRequest.isEmpty ? false : true,
                offset: Offset(5, -10.scale),
                backgroundColor: error,
                padding: EdgeInsets.all(scaleFontSize(2)),
                label: TextWidget(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  text: itemRequest.length.toString(),
                  color: white,
                ),
                child: const Icon(Icons.shopping_cart_rounded),
              ),
            ),
          );
        },
      ),
    );
  }
}
