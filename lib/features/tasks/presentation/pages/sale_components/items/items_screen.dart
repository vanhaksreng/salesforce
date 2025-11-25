import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/item_builder_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/group_screen_filter_item/group_screen_filter_item.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/items/items_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/sale_form/sale_form_screen.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class ItemScreen extends StatefulWidget {
  static const String routeName = "Itemscreen";
  const ItemScreen({
    super.key,
    required this.schedule,
    required this.documentType,
    required this.onRefresh,
    this.isRefreshing = false,
  });

  final SalespersonSchedule schedule;
  final String documentType;
  final void Function()? onRefresh;
  final bool isRefreshing;

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen>
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
    super.initState();
    _getSaleLines();
    _scrollController.addListener(_handleScrolling);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.getItems();
    });
  }

  void _handleScrolling() {
    if (_shouldLoadMore()) {
      _loadMoreItems();
    }
  }

  void _getSaleLines() {
    _cubit.getSaleLines(
      documentType: widget.documentType,
      scheduleId: widget.schedule.id,
    );
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
      params["_raw_query"] =
          '(description CONTAINS[c] "$searchString" OR no CONTAINS[c] "$searchString")';
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

  String checkInventory(String status) {
    if (status == kInStock) {
      return '> 0';
    } else if (status == kOutOfStock) {
      return '< 1';
    }
    return '';
  }

  bool _checkShowFilter() {
    return filterString.isNotEmpty && filterString != "IN {}" ||
            statusStock.isNotEmpty
        ? true
        : false;
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
  void didUpdateWidget(ItemScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRefreshing != widget.isRefreshing) {
      _itemFilter();
    }
  }

  void _navigateToProcessForm(Item item) {
    if (widget.documentType != kSaleCreditMemo &&
        Helpers.toDouble(item.inventory) <= 0) {
      showWarningMessage("No stock left.");
      return;
    }

    Navigator.pushNamed(
      context,
      SaleFormScreen.routeName,
      arguments: SaleFormArg(
        item: item,
        schedule: widget.schedule,
        documentType: widget.documentType,
      ),
    ).then((value) {
      _getSaleLines();
      widget.onRefresh?.call();
    });
  }

  void _changLayout() {
    if (shapeType.value == ShapeType.list) {
      shapeType.value = ShapeType.grid;
    } else {
      shapeType.value = ShapeType.list;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: BlocBuilder<ItemsCubit, ItemsState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
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

  @override
  bool get wantKeepAlive => true;
}
