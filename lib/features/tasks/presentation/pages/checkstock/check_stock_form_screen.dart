import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/date_input_formatter.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/core/utils/quantity_input_formatter.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/barcode_scanner_page.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_item_stock/check_item_stock_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_item_stock/check_item_stock_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CheckStockFormScreen extends StatefulWidget {
  const CheckStockFormScreen({super.key, required this.item, required this.schedule, this.status = ""});

  static const String routeName = "editStockDetail";
  final Item item;
  final SalespersonSchedule schedule;
  final String status;

  @override
  State<CheckStockFormScreen> createState() => _CheckStockFormScreenState();
}

class _CheckStockFormScreenState extends State<CheckStockFormScreen> {
  final TextEditingController _qbFoController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _soQtyController = TextEditingController();
  final TextEditingController _qtyReController = TextEditingController();
  final TextEditingController _expirationController = TextEditingController();
  final TextEditingController _serialNoController = TextEditingController();
  final TextEditingController _lotNoController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _cubit = CheckItemStockCubit();
  late String _stockUomCode = "";
  late final Item _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _stockUomCode = widget.item.stockUomCode ?? "";
    initValues();
    _expirationController.addListener(() {
      _formKey.currentState?.validate();
    });
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _expirationController.dispose();
    _serialNoController.dispose();
    _lotNoController.dispose();
    _remarkController.dispose();
    _qbFoController.dispose();
    _qtyController.dispose();
    _soQtyController.dispose();
    _qtyReController.dispose();
    super.dispose();
  }

  bool _isItemTracking() {
    ApplicationSetup? appSetup;
    try {
      appSetup = getIt<ApplicationSetup>();
    } catch (_) {
      appSetup = null;
    }

    if (appSetup == null) return false;

    if (appSetup.ctrlItemTracking == kStatusNo) {
      return false;
    }

    if ((_item.itemTrackingCode ?? "").isEmpty) {
      return false;
    }

    return true;
  }

  bool _isItemLot() {
    // LOTALL : lot , SNALL : serail
    if (_item.itemTrackingCode == "LOTALL") {
      return true;
    }

    return false;
  }

  Future<String> _navigatorToBarcodeScaner() {
    return Navigator.pushNamed(
      context,
      BarcodeScannerPage.routeName,
    ).then((value) => _serialNoController.text = value as String);
  }

  Future<void> initValues() async {
    await _cubit.getCustomerItemLedgerEntry(itemNo: widget.item.no, visitNo: widget.schedule.id);

    final customerItem = _cubit.state.detailCustomerItemLedgerEntry;

    _qtyController.text = Helpers.formatNumber(customerItem?.quantity, option: FormatType.quantity);

    _soQtyController.text = Helpers.formatNumber(customerItem?.plannedQuantity, option: FormatType.quantity);

    _qtyReController.text = Helpers.formatNumber(customerItem?.plannedQuantityReturn, option: FormatType.quantity);

    _qbFoController.text = Helpers.formatNumber(customerItem?.quantityBuyFromOther, option: FormatType.quantity);

    final date = DateTimeExt.parse(customerItem?.expirationDate);

    _expirationController.text = date.year == 1999 ? '' : date.toDateString();
    _lotNoController.text = Helpers.toStrings(customerItem?.lotNo);
    _serialNoController.text = Helpers.toStrings(customerItem?.serialNo);
    _remarkController.text = Helpers.toStrings(customerItem?.remark);
  }

  Future<void> _onSaveChangeValue() async {
    final l = LoadingOverlay.of(context);
    l.show();

    try {
      // if (_formKey.currentState?.validate() != true) {
      //   l.hide();
      //   return;
      // }

      await _cubit.updateItemCheckStock(
        CheckItemStockArg(
          stockQty: Helpers.toDouble(_qtyController.text),
          schedule: widget.schedule,
          item: widget.item,
          expirationDate: _expirationController.text,
          lotNo: _lotNoController.text,
          serialNo: _serialNoController.text,
          plannedQuantity: Helpers.toDouble(_soQtyController.text).toString(),
          plannedQuantityReturn: Helpers.toDouble(_qtyReController.text).toString(),
          quantityBuyFromOther: Helpers.toDouble(_qbFoController.text).toString(),
          remark: _remarkController.text,
        ),
      );

      l.hide();

      if (!mounted) return;
      Navigator.pop(context, {"success": true});
    } catch (e) {
      Logger.log(e);
      l.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("Check Stock Form")),
      body: BlocBuilder<CheckItemStockCubit, CheckItemStockState>(
        bloc: _cubit,
        builder: (context, state) {
          final getDetailState = state.detailCustomerItemLedgerEntry;
          return buildBody(getDetailState);
        },
      ),
      persistentFooterButtons: [
        if (widget.status.isEmpty)
          SafeArea(
            child: BtnWidget(gradient: linearGradient, title: greeting("save"), onPressed: () => _onSaveChangeValue()),
          ),
      ],
    );
  }

  Widget buildBody(CustomerItemLedgerEntry? detail) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace), vertical: scaleFontSize(appSpace8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: scaleFontSize(appSpace8),
        children: [
          BoxWidget(
            padding: EdgeInsets.all(scaleFontSize(15)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageNetWorkWidget(imageUrl: _item.picture ?? "", width: 60, height: 60, round: 100),
                Helpers.gapW(6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: _item.description ?? "",
                        fontWeight: FontWeight.bold,
                        color: primary,
                        fontSize: scaleFontSize(13),
                      ),
                      SizedBox(height: scaleFontSize(2)),
                      TextWidget(text: _item.description2 ?? ""),
                    ],
                  ),
                ),
              ],
            ),
          ),
          BoxWidget(
            padding: EdgeInsets.all(scaleFontSize(appSpace8)),
            child: Column(
              spacing: 16.scale,
              children: [
                Row(
                  spacing: 16.scale,
                  children: [
                    buildTextFormFieldWidget(
                      controller: _qtyController,
                      suffixText: _stockUomCode,
                      label: greeting("quantity"),
                    ),
                    buildTextFormFieldWidget(
                      controller: _qbFoController,
                      suffixText: _stockUomCode,
                      label: greeting("qty_bought_form_other"),
                    ),
                  ],
                ),
                Row(
                  spacing: 16.scale,
                  children: [
                    buildTextFormFieldWidget(
                      controller: _soQtyController,
                      suffixText: _stockUomCode,
                      label: greeting("suggest_order_qty"),
                    ),
                    buildTextFormFieldWidget(
                      controller: _qtyReController,
                      suffixText: _stockUomCode,
                      label: greeting("qty_return"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextWidget(text: greeting("other_optional"), fontSize: 14, color: primary),
          BoxWidget(
            padding: EdgeInsets.all(scaleFontSize(appSpace8)),
            child: Column(
              spacing: 16.scale,
              children: [
                if (_isItemTracking()) ...[
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _expirationController,
                    builder: (context, value, child) {
                      return Form(
                        autovalidateMode: value.text.isNotEmpty ? AutovalidateMode.always : AutovalidateMode.disabled,
                        key: _formKey,
                        child: _buildTextSigleFormFieldWidget(
                          isInputrDate: true,
                          hinText: DateTime.now().toDateString(),
                          controller: _expirationController,
                          iconSuffix: Icons.calendar_month,
                          label: greeting("expiry_date"),
                        ),
                      );
                    },
                  ),
                  _isItemLot()
                      ? _buildTextSigleFormFieldWidget(
                          controller: _lotNoController,
                          suffixText: "",
                          label: greeting("lot_no"),
                          onTap: () => _navigatorToBarcodeScaner(),
                          iconSuffix: Icons.qr_code,
                        )
                      : _buildTextSigleFormFieldWidget(
                          controller: _serialNoController,
                          suffixText: "",
                          onTap: () => _navigatorToBarcodeScaner(),
                          label: greeting("serial_no"),
                          iconSuffix: Icons.qr_code,
                        ),
                ],
                _buildTextSigleFormFieldWidget(
                  maxLine: 3,
                  hinText: greeting("write_remark_here..."),
                  controller: _remarkController,
                  label: greeting("remark"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row _buildTextSigleFormFieldWidget({
    required TextEditingController controller,
    IconData? iconSuffix,
    String? label,
    String? hinText,
    bool isInputrDate = false,
    bool isInputrQty = false,
    String suffixText = "",
    int? maxLine = 1,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        buildTextFormFieldWidget(
          controller: controller,
          iconSuffix: iconSuffix,
          label: label,
          onTap: onTap,
          hinText: hinText,
          suffixText: suffixText,
          maxLine: maxLine,
          isInputrDate: isInputrDate,
          isInputrQty: isInputrQty,
        ),
      ],
    );
  }

  Widget buildTextFormFieldWidget({
    required TextEditingController controller,
    IconData? iconSuffix,
    String? label,
    String? hinText,
    bool isInputrDate = false,
    bool isInputrQty = true,
    String suffixText = "",
    int? maxLine = 1,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: TextFormFieldWidget(
        controller: controller,
        maxLines: maxLine,
        filled: true,
        inputFormatters: switchInputFormater(isInputrDate: isInputrDate, isInputrQty: isInputrQty),
        keyboardType: isInputrQty || isInputrDate
            ? const TextInputType.numberWithOptions(signed: true, decimal: true)
            : null,
        readOnly: widget.status.isEmpty ? false : true,
        fillColor: widget.status.isEmpty ? white : grey.withAlpha(50),
        suffixIcon: SizedBox(
          width: 60.scale,
          child: Align(alignment: Alignment.center, child: switchWidget(iconSuffix, suffixText, onTap)),
        ),
        label: label ?? "",
        isDefaultTextForm: true,
        textColor: primary,
        textFontWeight: FontWeight.bold,
        hintFontWeight: FontWeight.normal,
        hintText: hinText ?? "",
      ),
    );
  }

  List<TextInputFormatter>? switchInputFormater({bool isInputrDate = false, bool isInputrQty = false}) {
    if (isInputrDate) {
      return [DateInputFormatter()];
    } else if (isInputrQty) {
      return const [QuantityInputFormatter(decimalRange: 8)];
    }

    return null;
  }

  Widget switchWidget(IconData? iconSuffix, String suffixText, VoidCallback? onTap) {
    if (iconSuffix != null) {
      return InkWell(
        onTap: onTap,
        child: Icon(iconSuffix, color: textColor50),
      );
    }
    return TextWidget(
      text: suffixText,
      textAlign: TextAlign.center,
      fontWeight: FontWeight.bold,
      color: primary,
      overflow: TextOverflow.ellipsis,
    );
  }
}
