import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/bottom_sheet_fn.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_text_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/custom_alert_dialog_widget.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_component/qty_input.dart';
import 'package:salesforce/features/tasks/domain/entities/checkout_arg.dart';
import 'package:salesforce/features/tasks/domain/entities/promotion_item_line_entity.dart';
import 'package:salesforce/features/tasks/domain/entities/promotion_line_entity.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/item_promotion_form/item_promotion_form_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/item_promotion_form/item_promotion_form_state.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/item_promotion_form/components/item_promotion_in_form_screen.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

Color getPromotionStatusColor(String? type) {
  if (type == "Item") {
    return success;
  } else if (type == "Category") {
    return warning;
  } else if (type == "Group") {
    return success.withValues(alpha: 0.5);
  } else if (type == "G/L Account") {
    return red;
  } else if (type == "Brand") {
    return red.withValues(alpha: 0.5);
  } else {
    return primary;
  }
}

class ItemPromotionFormScreen extends StatefulWidget {
  const ItemPromotionFormScreen({Key? key, required this.arg}) : super(key: key);

  static const String routeName = "/itemPromotionFromScreen";

  final ItemPromotionFormArg arg;

  @override
  State<ItemPromotionFormScreen> createState() => _ItemPromotionFormScreenState();
}

class _ItemPromotionFormScreenState extends State<ItemPromotionFormScreen> with MessageMixin {
  final _cubit = ItemPromotionFormCubit();

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  void _initLoad() async {
    await _cubit.loadInitialData(widget.arg);
    _cubit.getPromotionLines(widget.arg.header.no ?? "");

    if (_cubit.state.maxAllowedQty != -1) {
      _cubit.reachMaxOrderQty(1);
    }
  }

  void _addToCart() async {
    if (!_cubit.validated()) {
      _showInvalideList();
      return;
    }

    if (_cubit.state.maxAllowedQty != -1) {
      if (await _cubit.reachMaxOrderQty(_cubit.state.orderQty)) {
        showWarningMessage("You have reached maximum order quantity");
        return;
      }
    }

    _showConfirmList();
  }

  void _processingAddItemToCart() async {
    final l = LoadingOverlay.of(context);
    l.show();
    await _cubit.addToCart();
    l.hide();
  }

  double _canAddMore() {
    if (_cubit.state.maxAllowedQty != -1) {
      return _cubit.state.maxAllowedQty - _cubit.state.totalExistingQty;
    }

    return -1;
  }

  void _addQuantityToCart(double value) async {
    if (value <= 0) {
      return;
    }

    if (_cubit.state.maxAllowedQty != -1) {
      if (await _cubit.reachMaxOrderQty(value)) {
        return;
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    _cubit.updateOrderQty(value);
  }

  String _getInfoText() {
    if (_canAddMore() != -1) {
      if (_canAddMore() == 0) {
        return "You cannot make more order on this promotion.";
      }

      return "Maximun quantity per order. [${_canAddMore()}]";
    }

    return "";
  }

  bool _haveOwnLine(String lineType) {
    return ['Item', 'G/L Account'].contains(lineType);
  }

  Color _color(double qty1, double qty2) {
    if (qty1 == qty2) {
      return success;
    }

    return red;
  }

  Widget _getIcon(double qty1, double qty2) {
    return ChipWidget(
      isCircle: true,
      bgColor: _color(qty1, qty2),
      child: Icon(qty1 == qty2 ? Icons.check : Icons.close, color: white, size: 16.scale),
    );
  }

  void _showInvalideList() {
    final tempLines = _cubit.state.linesTemplate;

    showDialog(
      context: context,
      builder: (context) => AlertDialogBuilderWidget(
        labelAction: "Validation Check",
        subTitle: "Please review the promotion requirements",
        child: Column(
          spacing: 15.scale,
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextWidget(text: "Please review the promotion requirements"),
            ...tempLines.map((e) {
              return BoxWidget(
                isBoxShadow: false,
                padding: EdgeInsets.all(8.scale),
                borderColor: _color(e.addedQty, e.totalLineQty),
                isBorder: true,
                color: _color(e.addedQty, e.totalLineQty).withValues(alpha: 0.1),
                child: Row(
                  spacing: 8.scale,
                  children: [
                    _getIcon(e.addedQty, e.totalLineQty),
                    Expanded(
                      child: Column(
                        spacing: 4.scale,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_haveOwnLine(e.type)) TextWidget(text: " ${e.type}", fontSize: 16),
                          if (!_haveOwnLine(e.type)) ...[
                            TextWidget(text: " ${e.line.type}", fontSize: 16),
                            TextWidget(text: " ${e.line.description}", fontSize: 12),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ChipWidget(
                                bgColor: primary.withValues(alpha: 0.1),
                                colorText: primary,
                                label: "Required: ${Helpers.formatNumberLink(e.addedQty, option: FormatType.quantity)}",
                              ),
                              ChipWidget(
                                bgColor: _color(e.addedQty, e.totalLineQty).withValues(alpha: 0.2),
                                colorText: _color(e.addedQty, e.totalLineQty),
                                label:
                                    "Added: ${Helpers.formatNumberLink(e.totalLineQty, option: FormatType.quantity)}",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showConfirmList() {
    final tempLines = _cubit.state.linesTemplate;

    showDialog(
      context: context,
      builder: (context) => AlertDialogBuilderWidget(
        labelAction: "Confirm Checked",
        subTitle: "Please review the promotion requirements",
        confirmText: "Yes, Confirm",
        confirm: () {
          Navigator.of(context).pop();
          _processingAddItemToCart();
        },
        child: Column(
          spacing: 15.scale,
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextWidget(
              text: "Once added to the cart, quantity can't be changed. Please double-check before continuing.",
              fontSize: 11,
              color: warning,
            ),
            ...tempLines.map((e) {
              return BoxWidget(
                isBoxShadow: false,
                padding: EdgeInsets.all(8.scale),
                borderColor: _color(e.addedQty, e.totalLineQty),
                isBorder: true,
                color: _color(e.addedQty, e.totalLineQty).withValues(alpha: 0.1),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.scale,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 15.scale),
                        _getIcon(e.addedQty, e.totalLineQty),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        spacing: 4.scale,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_haveOwnLine(e.type)) TextWidget(text: " ${e.type}", fontSize: 16),
                          if (!_haveOwnLine(e.type)) ...[
                            TextWidget(text: " ${e.line.type}", fontSize: 16),
                            TextWidget(text: " ${e.line.description}", fontSize: 12),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ChipWidget(
                                bgColor: primary.withValues(alpha: 0.1),
                                colorText: primary,
                                label: "Required: ${Helpers.formatNumberLink(e.addedQty, option: FormatType.quantity)}",
                              ),
                              ChipWidget(
                                bgColor: _color(e.addedQty, e.totalLineQty).withValues(alpha: 0.2),
                                colorText: _color(e.addedQty, e.totalLineQty),
                                label:
                                    "Added: ${Helpers.formatNumberLink(e.totalLineQty, option: FormatType.quantity)}",
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.scale, vertical: 6.scale),
                            child: Column(
                              children: [
                                ...e.lines.where((l) => l.orderQty > 0).map((pl) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 6.scale),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextWidget(text: pl.itemName),
                                        TextWidget(
                                          text: Helpers.formatNumberLink(pl.orderQty, option: FormatType.quantity),
                                          color: success,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _updateQty({required PromotionItemLineEntity line, required PromotionLineEntity row, required double qty}) {
    _cubit.updateAddedQty(line: line, row: row, qty: qty);
  }

  void buildOrderQty() async {
    modalBottomSheet(
      context,
      child: QtyInput(
        key: const ValueKey("qty"),
        initialQty: Helpers.formatNumber(_cubit.state.orderQty, option: FormatType.quantity),
        infoText: _getInfoText(),
        errorMsg: _cubit.state.errorMsg ?? "",
        onChanged: _addQuantityToCart,
        modalTitle: "Order Quantity",
        inputLabel: "",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting('Item Promotion Mix')),
      body: BlocBuilder<ItemPromotionFormCubit, ItemPromotionFormState>(
        bloc: _cubit,
        builder: (BuildContext context, ItemPromotionFormState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(ItemPromotionFormState state) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderPomotion(),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: state.linesTemplate.length,
              padding: EdgeInsets.symmetric(horizontal: 15.scale),
              itemBuilder: (context, index) {
                final template = state.linesTemplate[index];
                return BoxWidget(
                  key: ValueKey(template.type),
                  border: Border(left: BorderSide(width: 4, color: getPromotionStatusColor(template.line.type))),
                  margin: EdgeInsets.symmetric(vertical: 8.scale),
                  child: Column(
                    key: ValueKey(template.type),
                    children: [
                      BoxWidget(
                        key: ValueKey(template.type),
                        color: grey20.withValues(alpha: 0.2),
                        isBoxShadow: false,
                        rounding: 8,
                        isRounding: false,
                        bottomLeft: 0,
                        bottomRight: 0,
                        topLeft: 8,
                        topRight: 8,
                        width: double.infinity,
                        padding: const EdgeInsets.all(appSpace),
                        margin: EdgeInsets.only(bottom: 8.scale),
                        child: _buildHeadItems(template),
                      ),
                      ItemPromotionInFormScreen(
                        key: ValueKey("template${template.type}"),
                        type: template.type,
                        lines: template.lines,
                        onChangeQTY: (line, qty) {
                          _updateQty(line: line, qty: qty, row: template);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadItems(PromotionLineEntity template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6.scale,
      children: [
        Row(
          spacing: 8.scale,
          children: [
            Icon(Icons.circle, size: 12, color: getPromotionStatusColor(template.line.type)),
            TextWidget(text: template.line.type ?? "", fontSize: 15, fontWeight: FontWeight.bold),
            if (!_haveOwnLine(template.type))
              ChipWidget(
                bgColor: getPromotionStatusColor(template.line.type).withValues(alpha: 0.2),
                child: Row(
                  spacing: 8.scale,
                  children: [
                    TextWidget(
                      text: template.promotionType,
                      fontSize: 10,
                      color: getPromotionStatusColor(template.line.type),
                      fontWeight: FontWeight.w700,
                    ),
                    Icon(Icons.circle, size: 4.scale, color: getPromotionStatusColor(template.line.type)),
                    TextWidget(
                      text: "Qty : ${Helpers.formatNumber(template.addedQty, option: FormatType.quantity)}",
                      fontSize: 12,
                      color: getPromotionStatusColor(template.line.type),
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Visibility(
              visible: template.totalLineQty > 0,
              child: ChipWidget(
                bgColor: red.withValues(alpha: 0.1),
                isCircle: true,
                child: TextWidget(
                  text: Helpers.formatNumber(template.totalLineQty, option: FormatType.quantity),
                  fontSize: 11,
                  color: red,
                ),
              ),
            ),
          ],
        ),
        if (!_haveOwnLine(template.type)) TextWidget(text: template.line.description ?? "", fontSize: 12),
      ],
    );
  }

  Widget _buildHeaderPomotion() {
    return BoxWidget(
      margin: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace), vertical: 8.scale),
      width: double.infinity,
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      child: Column(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(text: widget.arg.header.no ?? "", fontSize: 16, fontWeight: FontWeight.bold),
          TextWidget(fontSize: 14, text: widget.arg.header.description ?? ""),
          Hr(width: double.infinity, vertical: scaleFontSize(6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100.scale,
                child: BtnTextWidget(
                  vertical: 10.scale,
                  bgColor: Colors.transparent,
                  borderColor: grey,
                  borderWith: 0.5,
                  onPressed: buildOrderQty,
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: TextWidget(
                            text: Helpers.formatNumber(_cubit.state.orderQty, option: FormatType.quantity),
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down_circle, size: 15.scale, color: primary),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 100.scale,
                child: BtnWidget(onPressed: _addToCart, size: BtnSize.small, radius: 8.scale, title: "Add to cart"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
