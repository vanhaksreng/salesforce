import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/constants/permission.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/date_input_formatter.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/quantity_input_formatter.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/checkout_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/customer_address/customer_address_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/distributor/distributor_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/payment_screen/payment_screen_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/payment_term/payment_term_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/sale_checkout/sale_checkout_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/sale_checkout/sale_checkout_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class SaleCheckoutScreen extends StatefulWidget {
  const SaleCheckoutScreen({super.key, required this.arg});

  static const String routeName = "checkoutScreen";

  final CheckoutArg arg;

  @override
  State<SaleCheckoutScreen> createState() => _SaleCheckoutScreenState();
}

class _SaleCheckoutScreenState extends State<SaleCheckoutScreen>
    with MessageMixin {
  final _cubit = SaleCheckoutCubit();
  final _shipmentDateCntr = TextEditingController();
  final _shipmentCodeCtr = TextEditingController();
  final _paymentAmoutCtr = TextEditingController();
  final _paymentTypeCtr = TextEditingController();
  final _paymentTermCtr = TextEditingController();
  final _commentCtr = TextEditingController();
  final _distributorCtr = TextEditingController();

  PaymentMethod? _paymentMethod;
  Distributor? _distributor;
  DateTime? pickDate;

  @override
  void initState() {
    super.initState();
    _cubit.loadInitialData(widget.arg.salesHeader);
    _shipmentCodeCtr.text = widget.arg.salesHeader.shipToCode ?? "";
    _initLoad();
  }

  void _initLoad() async {
    await _cubit.getCustomerLedgerEntry(
      widget.arg.salesHeader.customerNo ?? "",
    );
    await _cubit.getDefaultPaymentTerm(
      widget.arg.salesHeader.paymentTermCode ?? "",
    );
    if (_cubit.state.paymentTerm != null) {
      _paymentTermCtr.text = _cubit.state.paymentTerm?.description ?? "";
    }

    _paymentAmoutCtr.text = "";
    if (widget.arg.salesHeader.documentType == kSaleCreditMemo) {
      _paymentAmoutCtr.text = "${widget.arg.amountDue}";
    }
  }

  void _onCheckoutHandler() async {
    try {
      if (widget.arg.salesHeader.documentType == kSaleInvoice) {
        await _validateSaleInvoice();
      } else if (widget.arg.salesHeader.documentType == kSaleCreditMemo) {
        if (_paymentMethod == null) {
          throw GeneralException("Payment method is required");
        }
      } else if (widget.arg.salesHeader.documentType == kSaleOrder) {
        // await _validateSaleCreditLimitAmount();
      }

      _processCheckout();
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (e) {
      showErrorMessage(e.toString());
    }
  }

  void _processCheckout() async {
    final l = LoadingOverlay.of(context);
    l.show();
    try {
      final result = await _cubit.processCheckout(
        CheckoutSubmitArg(
          salesHeader: widget.arg.salesHeader,
          subtotalAmount: widget.arg.subtotalAmount,
          discountAmount: widget.arg.discountAmount,
          vatAmount: widget.arg.vatAmount,
          amountDue: widget.arg.amountDue,
          scheduleId: widget.arg.scheduleId,
          shipmentAddress: _cubit.state.shipmentAddress!,
          comments: _commentCtr.text,
          distributor: _distributor,
          paymentMethod: _paymentMethod,
          paymentAmount: Helpers.toDouble(_paymentAmoutCtr.text),
          paymentTerm: _cubit.state.paymentTerm,
          requestShipmentDate: _shipmentDateCntr.text,
        ),
      );

      l.hide();

      if (mounted && result) {
        showSuccessMessage("Checkout success.");
        int count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == (widget.arg.fromScreen == "task" ? 3 : 4);
        });
      }
    } on GeneralException catch (e) {
      l.hide();
      showWarningMessage(e.message);
    } catch (e) {
      l.hide();
      showErrorMessage(e.toString());
    }
  }

  Future<void> _validateSaleInvoice() async {
    final paymentAmt = Helpers.toDouble(_paymentAmoutCtr.text);

    // if (paymentAmt <= 0) {
    //   throw GeneralException("Payment amount is required");
    // }

    final amountDue = Helpers.formatNumberDb(
      widget.arg.amountDue,
      option: FormatType.amount,
    );

    if (paymentAmt > amountDue) {
      throw GeneralException(
        "Payment amount cannot greater than amount due. $amountDue",
      );
    }

    if (paymentAmt > 0 && _paymentMethod == null) {
      throw GeneralException("Payment method is required");
    }

    if (!await _cubit.hasPermission(kPostCreditInvoice) &&
        (widget.arg.amountDue - paymentAmt) > 0) {
      throw GeneralException(
        "Payment amount must ${Helpers.formatNumber(widget.arg.amountDue, option: FormatType.amount)}",
      );
    }
  }

  Future<void> _validateSaleCreditLimitAmount() async {
    // final customer = _cubit.state.customer;
    // final customerLedgerEntries = _cubit.state.customerLedgerEntries;

    // if (customer == null) {
    //   throw GeneralException("Customer is required");
    // }

    // final String creditLimitType = customer.creditLimitedType ?? "";
    // final double cla = customer.creditLimitedAmount ?? 0;

    // double sumRemaining = customerLedgerEntries.fold(
    //   0.0,
    //   (sum, entry) => sum + Helpers.toDouble(entry.remainingAmount),
    // );

    // if (cla > 0) {
    //   switch (creditLimitType) {
    //     case kBalance:
    //       if (sumRemaining > cla) {
    //         throw GeneralException(
    //           "Customer credit limit is ${Helpers.formatNumberLink(customer.creditLimitedAmount, option: FormatType.amount)}. Please clear pending payments before proceeding.",
    //         );
    //       }

    //     case kNoOfInvoice:
    //       if (customerLedgerEntries.length > cla) {
    //         throw GeneralException(
    //           "Customer has pending payments exceeding the credit limit of ${Helpers.formatNumber(customer.creditLimitedAmount ?? "0", option: FormatType.quantity)} invoices.",
    //         );
    //       }

    //     case kNoCredit:
    //       throw GeneralException("No credit allowed for this customer");
    //   }
    // }

    // Check if credit limit type is no empty
    // Balance, by amount : Allow to credit up to $100
    // No of Invoices, by number of invoices  : Pending payments 3 invoices
    // No Credit, // No credit allowed for this customer
    // over Aging : Allow to credit up to 30 days
  }

  void _navigateToCustomerAddress() {
    Navigator.pushNamed(
      context,
      CustomerAddressScreen.routeName,
      arguments: widget.arg.salesHeader.customerNo,
    ).then((value) => _handleCustomerAddress(value));
  }

  void _handleCustomerAddress(Object? value) {
    if (value == null) return;

    if (value is CustomerAddress) {
      _shipmentCodeCtr.text = value.code ?? "";
      _cubit.changeShipmentAddress(value);
    }
  }

  void _navigatorToDistributorScreen() {
    Navigator.pushNamed(
      context,
      DistributorScreen.routeName,
      arguments: _paymentTypeCtr.text,
    ).then((value) {
      if (value == null) return;

      if (value is Distributor) {
        _cubit.setDistribute(value.name ?? value.code);
        _distributorCtr.text = _cubit.state.codeDis;
        _distributor = value;
      }
    });
  }

  void _navigatorToPaymentTermScreen() {
    Navigator.pushNamed(
      context,
      PaymentTermScreen.routeName,
      arguments: _paymentTypeCtr.text,
    ).then((value) {
      if (value == null) return;

      if (value is PaymentTerm) {
        _paymentTermCtr.text = value.description ?? value.code;
        _cubit.changePaymentTerm(value);
      }
    });
  }

  void _navigatorToPaymentScreen() {
    Navigator.pushNamed(
      context,
      PaymentScreenScreen.routeName,
      arguments: _paymentTypeCtr.text,
    ).then((value) => _handleCodePayment(value));
  }

  void _handleCodePayment(Object? value) {
    if (value == null) return;

    if (value is PaymentMethod) {
      _paymentTypeCtr.text = value.description ?? value.code;
      _paymentMethod = value;
    }
  }

  Color _getTagColor() {
    return const Color(0XFF7C3AED);
  }

  void _onChangeDateHandler() {
    showDatePicker(
      context: context,
      initialDate: _cubit.state.pickDate ?? pickDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: greeting("select_date"),
      cancelText: greeting("cancel"),
      confirmText: greeting("ok"),
    ).then((selectedDate) {
      if (selectedDate != null && selectedDate != pickDate) {
        _cubit.onPickDate(selectedDate);
        _shipmentDateCntr.text =
            (_cubit.state.pickDate ?? pickDate)?.toDateString() ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: "Checkout",
        actions: [
          ChipWidget(
            label: "Sale ${widget.arg.salesHeader.documentType ?? ''}",
            fontWeight: FontWeight.bold,
            fontSize: 12,
            colorText: _getTagColor(),
            radius: 15,
            bgColor: _getTagColor().withValues(alpha: 0.1),
          ),
          const SizedBox(width: appSpace),
        ],
      ),
      body: BlocBuilder<SaleCheckoutCubit, SaleCheckoutState>(
        bloc: _cubit,
        builder: (BuildContext context, SaleCheckoutState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
      persistentFooterButtons: [
        BtnWidget(
          gradient: linearGradient,
          onPressed: () => _onCheckoutHandler(),
          title: greeting("Submit"),
        ),
      ],
    );
  }

  Widget buildBody(SaleCheckoutState state) {
    return ListView(
      padding: const EdgeInsets.all(appSpace),
      children: [
        if (state.shipmentAddress != null) ...[
          _shipmentBox(state.shipmentAddress!),
          Helpers.gapH(15),
        ],
        _geenralBox(state),
        Helpers.gapH(15),
        _headerBoxInfo(),
        Helpers.gapH(15),
        if (widget.arg.salesHeader.documentType != kSaleOrder) _paymentBox(),
      ],
    );
  }

  BoxWidget _headerBoxInfo() {
    return BoxWidget(
      padding: EdgeInsets.all(15.scale),
      child: Column(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 6.scale,
            children: [
              ChipWidget(
                bgColor: _getTagColor().withValues(alpha: 0.1),
                radius: 8,
                vertical: 6,
                horizontal: 3,
                fontSize: 11,
                child: TextWidget(
                  text: Helpers.currencySymble(),
                  fontSize: 11,
                  color: _getTagColor(),
                ),
              ),
              const TextWidget(
                text: "Price Breakdown",
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              const Spacer(),
              ChipWidget(
                label: (widget.arg.salesHeader.documentType ?? "")
                    .toUpperCase(),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                vertical: 6,
                colorText: success,
                radius: 15,
                bgColor: success.withValues(alpha: 0.2),
              ),
            ],
          ),
          Helpers.gapH(1),
          _rowTitle(
            key: "Subtotal",
            value: Helpers.formatNumberLink(
              widget.arg.subtotalAmount,
              option: FormatType.amount,
            ),
            keyColor: Colors.black87,
            fontSize: 15,
          ),
          _rowTitle(
            key: "Discount",
            value:
                "-${Helpers.formatNumber(widget.arg.discountAmount, option: FormatType.amount)}",
            keyColor: red,
            valueColor: red,
            fontSize: 15,
          ),
          _rowTitle(
            key: "Total VAT",
            value: Helpers.formatNumberLink(
              widget.arg.vatAmount,
              option: FormatType.amount,
            ),
            keyColor: Colors.black87,
            fontSize: 15,
          ),
          const Hr(width: double.infinity),
          _rowTitle(
            key: "Total",
            value: Helpers.formatNumberLink(
              widget.arg.amountDue,
              option: FormatType.amount,
            ),
            keyColor: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ],
      ),
    );
  }

  BoxWidget _geenralBox(SaleCheckoutState state) {
    return BoxWidget(
      padding: EdgeInsets.all(15.scale),
      child: Column(
        spacing: 15.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8.scale,
            children: [
              ChipWidget(
                bgColor: _getTagColor().withValues(alpha: 0.1),
                radius: 8,
                vertical: 6,
                horizontal: 0,
                child: Icon(
                  Icons.info_outline,
                  size: 12.scale,
                  color: _getTagColor(),
                ),
              ),
              const TextWidget(
                text: 'General Info',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          TextFormFieldWidget(
            onTap: () => _navigatorToPaymentTermScreen(),
            readOnly: true,
            textColor: textColor50,
            controller: _paymentTermCtr,
            isDense: true,
            label: greeting("Payment Term"),
            suffixIcon: const Icon(
              Icons.arrow_forward_ios_sharp,
              size: 10,
              color: primary,
            ),
            isDefaultTextForm: true,
          ),
          TextFormFieldWidget(
            onTap: () => _navigatorToDistributorScreen(),
            readOnly: true,
            textColor: textColor50,
            controller: _distributorCtr,
            isDense: true,
            label: greeting("Distributor"),
            suffixIcon: BtnIconCircleWidget(
              flipX: false,
              onPressed: () => _cubit.clearTextFromField(_distributorCtr),
              icons: Icon(
                state.codeDis.isNotEmpty
                    ? Icons.cancel
                    : Icons.arrow_forward_ios_sharp,
                size: state.codeDis.isNotEmpty ? 24.scale : 10.scale,
                color: state.codeDis.isNotEmpty ? error : primary,
              ),
            ),
            isDefaultTextForm: true,
          ),
          TextFormFieldWidget(
            textColor: textColor50,
            controller: _commentCtr,
            label: greeting("Comment"),
            isDefaultTextForm: true,
          ),
        ],
      ),
    );
  }

  BoxWidget _paymentBox() {
    return BoxWidget(
      padding: EdgeInsets.all(15.scale),
      child: Column(
        spacing: 15.scale,
        children: [
          Row(
            spacing: 8.scale,
            children: [
              ChipWidget(
                bgColor: _getTagColor().withValues(alpha: 0.1),
                radius: 8,
                vertical: 6,
                horizontal: 0,
                child: Icon(
                  Icons.payment,
                  color: _getTagColor(),
                  size: 13.scale,
                ),
              ),
              const TextWidget(
                text: 'Payment',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          TextFormFieldWidget(
            controller: _paymentAmoutCtr,
            isDense: true,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            inputFormatters: const [QuantityInputFormatter(decimalRange: 8)],
            textColor: textColor50,
            label: greeting("Payment Amount"),
            isDefaultTextForm: true,
          ),
          TextFormFieldWidget(
            onTap: () => _navigatorToPaymentScreen(),
            readOnly: true,
            textColor: textColor50,
            controller: _paymentTypeCtr,
            isDense: true,
            label: greeting("payment_type"),
            suffixIcon: const Icon(
              Icons.arrow_forward_ios_sharp,
              size: 10,
              color: primary,
            ),
            isDefaultTextForm: true,
          ),
        ],
      ),
    );
  }

  BoxWidget _shipmentBox(CustomerAddress shipment) {
    return BoxWidget(
      padding: EdgeInsets.all(15.scale),
      child: Column(
        spacing: 15.scale,
        children: [
          Row(
            spacing: 8.scale,
            children: [
              ChipWidget(
                bgColor: _getTagColor().withValues(alpha: 0.1),
                radius: 8,
                vertical: 6,
                horizontal: 0,
                child: SvgWidget(
                  assetName: kSvgTruck,
                  colorSvg: _getTagColor(),
                  width: 12,
                  height: 12,
                ),
              ),
              const TextWidget(
                text: 'Shipment',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          if (widget.arg.salesHeader.documentType == kSaleOrder)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _shipmentDateCntr,
              builder: (context, value, child) {
                return TextFormFieldWidget(
                  isDefaultTextForm: true,
                  hintText: DateTime.now().toDateString(),
                  controller: _shipmentDateCntr,
                  label: greeting("Request Shipment Date"),
                  suffixIcon: BtnIconCircleWidget(
                    icons: Icon(
                      Icons.date_range,
                      color: primary,
                      size: 18.scale,
                    ),
                    onPressed: () => _onChangeDateHandler(),
                  ),
                  inputFormatters: switchInputFormater(
                    isInputrDate: true,
                    isInputrQty: false,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                );
              },
            ),
          TextFormFieldWidget(
            onTap: () => _navigateToCustomerAddress(),
            readOnly: true,
            textColor: textColor50,
            controller: _shipmentCodeCtr,
            isDense: true,
            label: greeting("Ship To Code"),
            suffixIcon: const Icon(
              Icons.arrow_forward_ios_sharp,
              size: 10,
              color: primary,
            ),
            isDefaultTextForm: true,
          ),
          _shipmentRow(
            key: "Name".toUpperCase(),
            value: shipment.name ?? "",
            key2: "Phone No".toUpperCase(),
            value2: shipment.phoneNo ?? "",
          ),
          _shipmentRow(
            key: "Address".toUpperCase(),
            value: shipment.address ?? "",
          ),
          _shipmentRow(
            key: "Address 2".toUpperCase(),
            value: shipment.address2 ?? "",
          ),
        ],
      ),
    );
  }

  Row _shipmentRow({
    required String key,
    required String value,
    String? key2,
    String? value2,
    Color? valueColor,
    Color? value2Color,
    double fontSize = 15,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                key,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: scaleFontSize(fontSize - 3),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: scaleFontSize(fontSize),
                ),
              ),
            ],
          ),
        ),
        if (key2 != null && value2 != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key2,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: scaleFontSize(fontSize - 3),
                  ),
                ),
                Text(
                  value2,
                  style: TextStyle(
                    color: value2Color,
                    fontSize: scaleFontSize(fontSize),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<TextInputFormatter>? switchInputFormater({
    bool isInputrDate = false,
    bool isInputrQty = false,
  }) {
    if (isInputrDate) {
      return [DateInputFormatter()];
    } else if (isInputrQty) {
      return const [QuantityInputFormatter(decimalRange: 8)];
    }

    return null;
  }

  Row _rowTitle({
    required String key,
    required String value,
    Color keyColor = Colors.black54,
    Color? valueColor,
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          key,
          style: TextStyle(
            color: keyColor,
            fontSize: scaleFontSize(fontSize),
            fontWeight: fontWeight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: valueColor,
            fontSize: scaleFontSize(fontSize),
          ),
        ),
      ],
    );
  }
}
