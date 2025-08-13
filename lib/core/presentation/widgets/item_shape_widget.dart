import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/image_box_cover_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/presentation/pages/process/process_cubit.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/dot_line_widget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class ItemShapeWidget extends StatefulWidget {
  const ItemShapeWidget({
    super.key,
    required this.item,
    this.shapeType = ShapeType.list,
    this.onItemTap,
    this.isAddedCart = true,
  });

  final Item item;
  final ShapeType shapeType;
  final Function(Item)? onItemTap;
  final bool isAddedCart;

  @override
  State<ItemShapeWidget> createState() => _ItemShapeState();
}

class _ItemShapeState extends State<ItemShapeWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _cubit = ProcessCubit();
  late String _uomCode = "";

  @override
  void initState() {
    _uomCode = widget.item.salesUomCode ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<ProcessCubit, ProcessState>(bloc: _cubit, builder: (context, state) => _buildContent());
  }

  Widget _buildContent() {
    return BoxWidget(
      margin: EdgeInsets.only(bottom: 8.scale),
      padding: EdgeInsets.all(16.scale),
      isBoxShadow: true,
      borderColor: grey20,
      isBorder: true,
      child: widget.shapeType == ShapeType.list ? _buildListShape() : _buildGridShape(),
    );
  }

  Widget _buildListShape() {
    return Column(
      spacing: scaleFontSize(appSpace),
      children: [
        Row(
          spacing: scaleFontSize(appSpace),
          children: [
            _buildItemImage(80),
            Expanded(
              child: Column(
                spacing: 8.scale,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(text: widget.item.description ?? "", maxLines: 2, fontWeight: FontWeight.bold),
                  if ((widget.item.description2 ?? "").isNotEmpty)
                    TextWidget(text: widget.item.description2 ?? "", maxLines: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_buildItemPrice(), _buildInventoryChip()],
                  ),
                ],
              ),
            ),
          ],
        ),
        const DotLine(),
        _buildFooter(),
      ],
    );
  }

  Widget _buildGridShape() {
    return Column(
      spacing: scaleFontSize(appSpace),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _buildItemImage(80)),
        _buildItemDescription(),
        _buildInventoryChip(),
        _buildItemPrice(),
        Helpers.gapH(3.scale),
        _buildBtn(),
      ],
    );
  }

  Widget _buildBtn() {
    if (widget.isAddedCart) {
      return BtnWidget(size: BtnSize.small, onPressed: () => widget.onItemTap?.call(widget.item), title: 'edit_cart');
    }

    return BtnWidget(
      gradient: linearGradient,
      size: BtnSize.small,
      onPressed: () => widget.onItemTap?.call(widget.item),
      title: 'add_to_cart',
    );
  }

  Widget _buildItemImage(double size) {
    return ImageBoxCoverWidget(
      key: ValueKey("img${widget.item.no}"),
      image: ImageNetWorkWidget(
        key: ValueKey("img${widget.item.no}"),
        imageUrl: widget.item.picture ?? "",
        width: size,
        height: size,
      ),
    );
  }

  Widget _buildItemDescription() {
    return SizedBox(
      height: 60.scale,
      child: Column(
        spacing: scaleFontSize(5),
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(text: widget.item.description ?? "", maxLines: 2, fontWeight: FontWeight.bold),
          if (widget.item.description2?.isNotEmpty ?? false)
            Expanded(child: TextWidget(text: widget.item.description2 ?? "", maxLines: 1)),
        ],
      ),
    );
  }

  Widget _buildItemPrice() {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: Helpers.formatNumberLink(widget.item.unitPrice, option: FormatType.amount),
            style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 18.scale),
          ),
          TextSpan(
            text: ' /$_uomCode',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12.scale),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryChip() {
    final inventory = Helpers.toDouble(widget.item.inventory);
    Color chipColor;
    Color backgroundColor;

    if (inventory <= 0) {
      chipColor = error;
      backgroundColor = error.withValues(alpha: .1);
    } else if (inventory <= 10) {
      chipColor = orangeColor;
      backgroundColor = orangeColor.withValues(alpha: .1);
    } else {
      chipColor = success;
      backgroundColor = success.withValues(alpha: .1);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.scale, vertical: 4.scale),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16.scale)),
      child: TextWidget(
        text: inventory <= 0
            ? "Out of stock"
            : "${Helpers.formatNumberLink(widget.item.inventory, option: FormatType.quantity)} ${widget.item.stockUomCode}",
        fontSize: 12,
        color: chipColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategoryChip(),
        SizedBox(width: 110.scale, child: _buildBtn()),
      ],
    );
  }

  Widget _buildCategoryChip() {
    final category = widget.item.itemCategoryCode ?? "";
    return Visibility(
      visible: category.isNotEmpty,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.scale, vertical: 4.scale),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12.scale)),
        child: TextWidget(text: category, fontSize: 12, color: Colors.grey.shade600),
      ),
    );
  }
}
