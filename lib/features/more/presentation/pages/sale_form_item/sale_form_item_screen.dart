import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/domain/entities/app_args.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/bottom_sheet_fn.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/image_box_cover_widget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/quantity_input_formatter.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/domain/entities/item_sale_arg.dart';
import 'package:salesforce/features/more/presentation/pages/sale_form_item/sale_form_item_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/sale_form_item/sale_form_item_state.dart';
import 'package:salesforce/features/tasks/domain/entities/sale_form_input.dart';
import 'package:salesforce/features/tasks/presentation/pages/task_component/build_uom_selected/build_uom_selected.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class SaleFormItemScreen extends StatefulWidget {
  static const String routeName = "saleFromITemScreen";
  const SaleFormItemScreen({super.key, required this.args});
  final ItemSaleArg args;

  @override
  SaleFormItemScreenState createState() => SaleFormItemScreenState();
}

class SaleFormItemScreenState extends State<SaleFormItemScreen> {
  final _cubit = SaleFormItemCubit();
  final Map<String, TextEditingController> _quantityCntr = {};
  final Map<String, TextEditingController> _uomCntr = {};

  final _disPercentageCntr = TextEditingController();
  final _disAmountCntr = TextEditingController();
  final _manualPriceCntr = TextEditingController();

  late final Item? _item;
  @override
  void initState() {
    super.initState();
    _item = widget.args.item;
    _initLoad();
  }

  void _initLoad() async {
    await _cubit.getPromotionType();
    await _cubit.loadInitialData(
      ItemSaleArg(
        item: widget.args.item,
        documentType: widget.args.documentType,
        isRefreshing: widget.args.isRefreshing,
        customer: widget.args.customer,
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _quantityCntr.values) {
      controller.dispose();
    }

    for (final controller in _uomCntr.values) {
      controller.dispose();
    }

    _manualPriceCntr.dispose();
    _disPercentageCntr.dispose();
    _disAmountCntr.dispose();
    super.dispose();
  }

  void _onSaveRecord() async {
    final bool result = await _cubit.onSaveRecord();
    if (mounted && result) {
      Navigator.pop(context);
    }
  }

  void _initializeControllers(List<SaleFormInput> inputs) {
    _quantityCntr.clear();
    _uomCntr.clear();

    for (final input in inputs) {
      String qty = Helpers.formatNumber(
        input.quantity,
        option: FormatType.quantity,
        display: false,
      );

      String uomCode = input.uomCode;

      _quantityCntr[input.code] = TextEditingController(text: qty);

      _uomCntr[input.code] = TextEditingController(text: uomCode);
    }

    _disPercentageCntr.text = Helpers.formatNumber(
      _cubit.state.discountPercentage,
      option: FormatType.quantity,
    );

    _disAmountCntr.text = Helpers.formatNumber(
      _cubit.state.discountAmt,
      option: FormatType.quantity,
    );

    _manualPriceCntr.text = Helpers.formatNumber(
      _cubit.state.manualPrice,
      option: FormatType.price,
      display: false,
    );
  }

  void _showModalBottomSheet(SaleFormInput input) {
    modalBottomSheet(
      context,
      child: BuildUomSelected(
        arg: BuildUomArg(
          inputLabel: _item?.description,
          modalTitle: input.description,
          itemNo: _item?.no ?? "",
          uomCode: input.uomCode,
          onChanged: (value) {
            _onSelectedUomHandler(input.code, value);
            Navigator.pop(context);
          },
        ),
        key: const ValueKey("uom"),
      ),
    );
  }

  void _onSelectedUomHandler(String inputCode, String uomCode) {
    _uomCntr[inputCode] = TextEditingController(text: uomCode);
    _cubit.updateSaleUom(inputCode, uomCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("Sale Form")),
      body: BlocBuilder<SaleFormItemCubit, SaleFormItemState>(
        bloc: _cubit,

        builder: (BuildContext context, SaleFormItemState state) {
          if (state.isLoading) {
            return Center(child: LoadingPageWidget());
          }
          return buildBody(state);
        },
      ),
      persistentFooterButtons: [
        SafeArea(
          child: BtnWidget(
            gradient: linearGradient,
            horizontal: scaleFontSize(appSpace8),
            title: "save",
            onPressed: () => _onSaveRecord(),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryChip() {
    final inventory = Helpers.toDouble(_item?.inventory);
    Color chipColor;
    Color backgroundColor;

    if (inventory <= 0) {
      chipColor = error;
      backgroundColor = error.withValues(alpha: 0.1);
    } else if (inventory <= 10) {
      chipColor = orangeColor;
      backgroundColor = orangeColor.withValues(alpha: 0.1);
    } else {
      chipColor = success;
      backgroundColor = success.withValues(alpha: 0.1);
    }

    return ChipWidget(
      colorText: chipColor,
      bgColor: backgroundColor,
      label: inventory <= 0
          ? "Out of stock"
          : "${Helpers.formatNumberLink(_item?.inventory, option: FormatType.quantity)} ${_item?.stockUomCode}",
    );
  }

  Widget buildBody(SaleFormItemState state) {
    final inputs = state.saleForm;

    if (inputs.isNotEmpty && (_quantityCntr.isEmpty)) {
      _initializeControllers(inputs);
    }

    return ListView(
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      children: [
        SizedBox(height: scaleFontSize(8)),
        BoxWidget(
          padding: EdgeInsets.all(scaleFontSize(15)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageBoxCoverWidget(
                image: ImageNetWorkWidget(
                  imageUrl: _item?.picture ?? "",
                  width: 60.scale,
                  height: 60.scale,
                ),
              ),
              Helpers.gapW(6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text:
                              "${Helpers.formatNumber(state.itemUnitPrice, option: FormatType.amount)} / ${state.saleUomCode}",
                          fontWeight: FontWeight.bold,
                          color: primary,
                          fontSize: 16,
                        ),
                        _buildInventoryChip(),
                      ],
                    ),
                    SizedBox(height: scaleFontSize(8)),
                    TextWidget(text: _item?.description ?? ""),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: scaleFontSize(20)),
        BoxWidget(
          padding: EdgeInsets.all(scaleFontSize(15)),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: inputs.length,
            itemBuilder: (context, index) {
              final input = inputs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(input.description),
                    const SizedBox(height: 8),
                    Row(
                      spacing: scaleFontSize(8),
                      children: [
                        buildTextFormFieldWidget(
                          controller: _quantityCntr[input.code]!,
                          label: "Quantity",
                          isNumber: true,
                          onChanged: (value) {
                            _cubit.updateQuantity(input.code, value);
                          },
                        ),
                        buildTextFormFieldWidget(
                          controller: _uomCntr[input.code]!,
                          label: "",
                          redOnly: true,
                          isOption: true,
                          onTap: () {
                            _showModalBottomSheet(input);
                          },
                          suffix: SizedBox(
                            width: 30.scale,
                            child: const Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.arrow_drop_down_outlined,
                                color: primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (state.isExistedStd) ...[
          SizedBox(height: scaleFontSize(20)),
          const TextWidget(
            text: "discount_option_standard_sales",
            color: primary,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: scaleFontSize(10)),
          BoxWidget(
            padding: EdgeInsets.all(scaleFontSize(15)),
            child: Row(
              spacing: scaleFontSize(8),
              children: [
                buildTextFormFieldWidget(
                  controller: _disPercentageCntr,
                  label: "discount_percent",
                  isNumber: true,
                  redOnly: !state.canDiscount,
                  onChanged: (value) {
                    _disAmountCntr.text = "";
                    _cubit.updateDiscountPercentage(value);
                  },
                ),
                buildTextFormFieldWidget(
                  controller: _disAmountCntr,
                  label: "discount_amount",
                  isNumber: true,
                  redOnly: !state.canDiscount,
                  onChanged: (value) {
                    _disPercentageCntr.text = "";
                    _cubit.updateDiscountAmount(value);
                  },
                  suffix: SizedBox(
                    width: 30.scale,
                    child: Align(
                      alignment: Alignment.center,
                      child: TextWidget(
                        text: Helpers.currencySymble(),
                        fontSize: 18,
                        color: primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (state.isExistedStd && state.canModifyPrice) ...[
          SizedBox(height: scaleFontSize(20)),
          const TextWidget(
            text: "manual_selling_price_standard_sales",
            color: primary,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: scaleFontSize(2)),
          const TextWidget(
            text: "this_will_overwrite_item_default_selling_price",
            fontSize: 12,
            color: orangeColor,
          ),
          SizedBox(height: scaleFontSize(10)),
          BoxWidget(
            padding: EdgeInsets.all(scaleFontSize(15)),
            child: Row(
              spacing: scaleFontSize(8),
              children: [
                buildTextFormFieldWidget(
                  controller: _manualPriceCntr,
                  label: "manual_price_dollar",
                  onChanged: _cubit.updateManualPrice,
                  suffix: SizedBox(
                    width: 30.scale,
                    child: Align(
                      alignment: Alignment.center,
                      child: TextWidget(
                        text: Helpers.currencySymble(),
                        fontSize: 18,
                        color: primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget buildTextFormFieldWidget({
    required TextEditingController controller,
    Widget? suffix,
    String? label,
    bool redOnly = false,
    bool isOption = false,
    bool isNumber = false,
    VoidCallback? onTap,
    Function(String)? onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Expanded(
      child: TextFormFieldWidget(
        controller: controller,
        filled: true,
        readOnly: redOnly,
        isOption: isOption,
        suffixIcon: suffix,
        onTap: onTap,
        label: label ?? "",
        isDefaultTextForm: true,
        onChanged: onChanged,
        inputFormatters: isNumber
            ? [const QuantityInputFormatter(decimalRange: 8)]
            : null,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true, signed: true)
            : keyboardType,
      ),
    );
  }
}
