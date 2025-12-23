import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/badge_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/item_builder_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/domain/entities/cart_preview_arg.dart';
import 'package:salesforce/features/more/domain/entities/item_sale_arg.dart';
import 'package:salesforce/features/more/presentation/pages/cart_preview_item/cart_preview_item_screen.dart';
import 'package:salesforce/features/more/presentation/pages/items/items_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/items/items_state.dart';
import 'package:salesforce/features/more/presentation/pages/sale_form_item/sale_form_item_screen.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/group_screen_filter_item/group_screen_filter_item.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class ItemsScreen extends StatefulWidget {
  static const String routeName = "itemScreenMore";
  const ItemsScreen({super.key, required this.args});
  final ItemSaleArg args;
  @override
  ItemsScreenState createState() => ItemsScreenState();
}

class ItemsScreenState extends State<ItemsScreen>
    with AutomaticKeepAliveClientMixin, MessageMixin {
  final _cubit = ItemsCubit();

  final _scrollController = ScrollController();
  final ValueNotifier<ShapeType> shapeType = ValueNotifier<ShapeType>(
    ShapeType.list,
  );

  late List<String> _selectedGroups = [];
  late String statusStock = "";
  final searchItem = TextEditingController();
  late String filterString = "";
  late String searchString = "";

  @override
  void initState() {
    _scrollController.addListener(_handleScrolling);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.getItems();
    });
    _loadCountCart();
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

  void _loadMoreItems() {
    final page = Helpers.toInt(_cubit.state.currentPage) + 1;
    _itemFilter(page);
  }

  void _itemFilter([int page = 1]) async {
    Map<String, dynamic> params = {};
    if (filterString.isNotEmpty) {
      params["item_group_code"] = filterString;
    }

    if (searchString.isNotEmpty) {
      params["description"] = 'LIKE $searchString%';
    }

    if (params["item_group_code"] == "IN {}") {
      params["item_group_code"] = "";
    }
    if (statusStock.isNotEmpty) {
      params["inventory"] = statusStock;
    }
    await _cubit.getItems(page: page, isLoading: false, param: params);
  }

  String _formatGroupCodesFilter(List<String> codes) {
    return "IN {${_selectedGroups.map((e) => "'$e'").join(', ')}}";
  }

  void _navigateToGroupScreenFilter() {
    Navigator.pushNamed(
      context,
      GroupScreenFilterItem.routeName,
      arguments: GroupFilterArgs(
        groupCodes: _selectedGroups,
        status: statusStock,
      ),
    ).then(_handleFilterResult);
  }

  void _handleFilterResult(dynamic result) {
    if (result is! Map || result.isEmpty) return;

    final List<String> groupCodes = result["groupCode"] ?? [];

    _handleGroupCodesUpdate(groupCodes, result["stock"].toString());
  }

  String checkInventory(String status) {
    if (status == kInStock) {
      return '> 0';
    } else if (status == kOutOfStock) {
      return '< 1';
    }
    return '';
  }

  void _handleGroupCodesUpdate(List<String> groupCodes, String status) {
    _selectedGroups = groupCodes;
    filterString = _formatGroupCodesFilter(groupCodes);
    statusStock = checkInventory(status);

    _itemFilter();
  }

  void _onSearchItem(String value) async {
    searchString = value;
    _itemFilter();
  }

  @override
  void didUpdateWidget(ItemsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.args.isRefreshing != widget.args.isRefreshing) {
      _itemFilter();
    }
  }

  void _loadCountCart() {
    _cubit.getSaleLines(
      scheduleId: widget.args.customer.no,
      documentType: widget.args.documentType,
    );
  }

  void _navigateToProcessForm(Item item) {
    if (item.preventNegativeInventory == kStatusYes &&
        widget.args.documentType == kSaleInvoice &&
        Helpers.toDouble(item.inventory) <= 0) {
      showWarningMessage("No stock left.");
      return;
    }

    Navigator.pushNamed(
      context,
      SaleFormItemScreen.routeName,
      arguments: ItemSaleArg(
        item: item,
        documentType: widget.args.documentType,
        isRefreshing: widget.args.isRefreshing,
        customer: widget.args.customer,
      ),
    ).then((value) {
      _loadCountCart();
    });
  }

  void _changLayout() {
    if (shapeType.value == ShapeType.list) {
      shapeType.value = ShapeType.grid;
    } else {
      shapeType.value = ShapeType.list;
    }
  }

  void _navigateToAddedCart() {
    Navigator.pushNamed(
      context,
      CartPreviewItemScreen.routeName,
      arguments: CartPreviewArg(
        documentType: widget.args.documentType,
        customer: widget.args.customer,
      ),
    ).then((value) {
      _loadCountCart();
    });
  }

  bool _checkShowFilter() {
    return filterString.isNotEmpty && filterString != "IN {}" ||
            statusStock.isNotEmpty
        ? true
        : false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleDownload() async {
    if (!await _cubit.isConnectedToNetwork()) {
      showWarningMessage(errorInternetMessage);
      return;
    }

    if (!mounted) return;

    final l = LoadingOverlay.of(context);
    l.show(1);
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      List<String> tables = [
        "item",
        "item_sales_line_prices",
        "item_unit_of_measure",
      ];

      final filter = tables.map((table) => '"$table"').toList();

      final appSyncLogs = await _cubit.getAppSyncLogs({
        'tableName': 'IN {${filter.join(",")}}',
      });

      if (tables.isEmpty) {
        throw GeneralException("Cannot find any table related");
      }

      const String text = "System will donwload only related data.";
      await Future.delayed(const Duration(milliseconds: 300));

      await _cubit.downloadDatas(
        appSyncLogs,
        onProgress: (progress, count, tableName, errorMsg) {
          l.updateProgress(progress, text: text);
        },
      );
      l.hide();
    } on GeneralException catch (e) {
      l.hide();
      showWarningMessage(e.message);
    } on Exception catch (e) {
      l.hide();
      showErrorMessage(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBarWidget(
        enableGradient: true,
        title: greeting("Items"),
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
      body: BlocBuilder<ItemsCubit, ItemsState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
      floatingActionButton: _buildStoreItemBtn(),
    );
  }

  Widget buildBody(ItemsState state) {
    final items = state.items;
    final saleLines = state.saleLines;

    return ValueListenableBuilder(
      valueListenable: shapeType,
      builder: (context, valueShapeType, child) {
        return Column(
          spacing: 8.scale,
          children: [
            SearchWidget(
              textColor: textColor,
              hintextColor: textColor50,
              bgColor: white,
              borderColor: primary.withValues(alpha: .5),
              onChanged: (value) async => _onSearchItem(value),
              showPrefixIcon: false,
              hintText: "Search items ...",
              suffixIcon: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 3.scale,
                  horizontal: 3.scale,
                ),
                child: SizedBox(
                  width: 110.scale,
                  child: Row(
                    spacing: 4.scale,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      BtnIconCircleWidget(
                        onPressed: _changLayout,
                        icons: Icon(
                          shapeType.value == ShapeType.grid
                              ? Icons.view_list_rounded
                              : Icons.grid_view_rounded,
                          color: mainColor50,
                          size: 20.scale,
                        ),
                        bgColor: grey20.withValues(alpha: 0.2),
                        rounded: 4.scale,
                      ),
                      BtnIconCircleWidget(
                        isShowBadge: _checkShowFilter(),
                        onPressed: () => _navigateToGroupScreenFilter(),
                        icons: Icon(
                          Icons.filter_list,
                          color: mainColor50,
                          size: 20.scale,
                        ),
                        bgColor: grey20,
                        rounded: 4.scale,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildItem(items, valueShapeType, saleLines),
          ],
        );
      },
    );
  }

  Widget _buildItem(
    List<Item> items,
    ShapeType valueShapeType,
    List<PosSalesLine> saleLines,
  ) {
    if (items.isEmpty) {
      return const Center(child: Text('No items found'));
    }
    return Expanded(
      child: ItemBuilderWidget(
        scrollController: _scrollController,
        items: items,
        shapeType: valueShapeType,
        onItemTap: (item) => _navigateToProcessForm(item),
        saleLines: saleLines,
      ),
    );
  }

  Widget filterBtn({required VoidCallback onTap}) {
    return Badge(
      smallSize: 10,
      isLabelVisible: filterString.isNotEmpty && filterString != "IN {}"
          ? true
          : false,
      backgroundColor: red,
      child: BtnWidget(
        onPressed: onTap,
        icon: SvgWidget(
          assetName: kFilter,
          colorSvg: primary,
          padding: EdgeInsets.all(scaleFontSize(appSpace8)),
        ),
        height: 35.scale,
        width: 35.scale,
        bgColor: secondary.withAlpha(70),
      ),
    );
  }

  Widget _buildStoreItemBtn() {
    return SafeArea(
      child: BlocBuilder<ItemsCubit, ItemsState>(
        bloc: _cubit,
        builder: (context, state) {
          return BtnIconCircleWidget(
            bgColor: mainColor50,
            flipX: false,
            onPressed: () => _navigateToAddedCart(),
            icons: Center(
              child: BadgeWidget(
                label: "${state.cartCount}",
                colorIcon: white,
                iconSvg: kAddCart,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
