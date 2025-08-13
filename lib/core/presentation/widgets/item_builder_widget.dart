import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/animate_wrapper_item.dart';
import 'package:salesforce/core/presentation/widgets/item_shape_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

class ItemBuilderWidget extends StatelessWidget {
  const ItemBuilderWidget({
    super.key,
    required this.scrollController,
    required this.items,
    required this.saleLines,
    this.isLoading = false,
    this.shapeType = ShapeType.list,
    this.onItemTap,
  });

  final ScrollController scrollController;
  final List<Item> items;
  final List<PosSalesLine> saleLines;
  final ShapeType shapeType;
  final bool isLoading;

  final Function(Item)? onItemTap;

  static const int maxAnimatedItems = 10;

  @override
  Widget build(BuildContext context) {
    return shapeType == ShapeType.list ? _buildListView() : _buildGridView();
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: scrollController,
      padding: _buildPadding(),
      itemCount: _itemCount,
      itemBuilder: (context, index) => _buildItem(index),
    );
  }

  Widget _buildGridView() {
    return MasonryGridView.count(
      controller: scrollController,
      crossAxisCount: SizeConfig.screenWidth ~/ 150.scale,
      mainAxisSpacing: 8.scale,
      crossAxisSpacing: 8.scale,
      padding: _buildPadding(),
      itemCount: _itemCount,
      itemBuilder: (context, index) => _buildItem(index, isGrid: true),
    );
  }

  Widget _buildItem(int index, {bool isGrid = false}) {
    if (index == items.length) {
      return const LoadingPageWidget();
    }

    final item = items[index];
    final shouldAnimate = index < maxAnimatedItems;

    return RepaintBoundary(
      key: ValueKey(item.no),
      child: _buildItemContent(item: item, index: index, shouldAnimate: shouldAnimate, isGrid: isGrid),
    );
  }

  Widget _buildItemContent({
    required Item item,
    required int index,
    required bool shouldAnimate,
    required bool isGrid,
  }) {
    final hasCart = saleLines.any((e) {
      if (!e.isValid) {
        return false;
      }

      return e.no == item.no && e.specialTypeNo == "";
    });

    final itemShape = ItemShapeWidget(
      key: ValueKey(item.no),
      item: item,
      shapeType: isGrid ? ShapeType.grid : ShapeType.list,
      onItemTap: onItemTap,
      isAddedCart: hasCart,
    );

    return shouldAnimate ? AnimatedItemWrapper(key: ValueKey(item.no), index: index, child: itemShape) : itemShape;
  }

  EdgeInsets _buildPadding() {
    return EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace));
  }

  int get _itemCount => items.length + (isLoading ? 1 : 0);
}
