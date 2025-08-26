import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/dot_line_widget.dart';
import 'package:salesforce/core/presentation/widgets/image_box_cover_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_row_shape.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/checkout_arg.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/add_card_preview/add_cart_preview_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/add_card_preview/add_cart_preview_state.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/sale_checkout/sale_checkout_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/sale_form/sale_form_screen.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class AddCartPreviewScreen extends StatefulWidget {
  const AddCartPreviewScreen({
    super.key,
    required this.scheduleId,
    required this.documentType,
    required this.customerNo,
  });

  final String scheduleId;
  final String documentType;
  final String customerNo;

  static const String routeName = "addedCardPreveiw";

  @override
  State<AddCartPreviewScreen> createState() => _AddCardPreviewScreenState();
}

class _AddCardPreviewScreenState extends State<AddCartPreviewScreen>
    with MessageMixin {
  final _cubit = AddCartPreviewCubit();

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  void _initLoad() async {
    await _cubit.loadInitialData(
      scheduleId: widget.scheduleId,
      documentType: widget.documentType,
    );

    await _cubit.getSchedule(widget.scheduleId);
    await _cubit.getSaleLines();
    await _cubit.getCustomer(widget.customerNo);
    await _cubit.getCustomerLedgerEntry(widget.customerNo);
    _checkCreditLimitType();
  }

  void _navigateToCheckoutScreen() {
    if (_cubit.state.salesHeader == null) {
      showWarningMessage("Nothing to checkout.");
      return;
    }

    if (_cubit.state.saleLines.isEmpty) {
      showWarningMessage("Nothing to checkout.");
      return;
    }

    Navigator.pushNamed(
      context,
      SaleCheckoutScreen.routeName,
      arguments: CheckoutArg(
        scheduleId: widget.scheduleId,
        salesHeader: _cubit.state.salesHeader!,
        subtotalAmount: _cubit.state.subTotalAmt,
        discountAmount: _cubit.state.totalDiscountAmt,
        vatAmount: _cubit.state.totalTaxAmt,
        amountDue: _cubit.state.totalAmt,
      ),
    );
  }

  void _onDeleteHandler(PosSalesLine line) {
    Helpers.showDialogAction(
      context,
      subtitle:
          "Would you like to delete?"
          "${line.description} - ${line.specialType}",
      cancelText: "No, Keep it",
      confirmText: greeting("Yes, Delete"),
      confirm: () async {
        await _cubit.deletedLine(line);
        if (!mounted) return;
        Navigator.pop(context);
      },
    );
  }

  void _onEditHandler(PosSalesLine line, Item? item) async {
    item ??= await _cubit.getItem(line.no ?? "");
    if (item == null) {
      return;
    }

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      SaleFormScreen.routeName,
      arguments: SaleFormArg(
        item: item,
        schedule: _cubit.state.schedule!,
        documentType: line.documentType ?? widget.documentType,
      ),
    ).then((value) {
      _cubit.getSaleLines();
    });
  }

  void _onShipmentHandler(PosSalesLine line, Item? item) async {
    item ??= await _cubit.getItem(line.no ?? "");
    if (item == null) {
      return;
    }
  }

  Color _getChipColor(String specialType) {
    switch (specialType) {
      case kPromotionTypeStd:
        return success;
      default:
        return warning;
    }
  }

  void _checkCreditLimitType() {
    final customer = _cubit.state.customer;
    if (customer == null) {
      _cubit.setCreditLimitText();
      return;
    }

    final String creditLimitType = customer.creditLimitedType ?? "";
    final creditLimitedAmount = Helpers.toDouble(customer.creditLimitedAmount);

    if (creditLimitType == kNoCredit) {
      _cubit.setCreditLimitText(
        "[${customer.name}], This customer must pay for what they buy. Please ensure payment is arranged, especially if there are existing unpaid invoices.",
      );
      return;
    }

    if (creditLimitedAmount == 0 && creditLimitType == "") {
      _cubit.setCreditLimitText();
      return;
    }

    final customerLedgerEntries = _cubit.state.customerLedgerEntries ?? [];

    if (creditLimitType == kBalance) {
      double remaining = customerLedgerEntries.fold(
        0.0,
        (sum, entry) => sum + Helpers.toDouble(entry.remainingAmount),
      );

      if ((remaining + _cubit.state.totalAmt) <=
          Helpers.toDouble(customer.creditLimitedAmount)) {
        return;
      }

      _cubit.setCreditLimitText(
        "[${customer.name}], This sale will cause the customer's total outstanding balance to exceed ${Helpers.formatNumber(creditLimitedAmount, option: FormatType.amount)}",
      );
    } else if (creditLimitType == kNoOfInvoice) {
      if (customerLedgerEntries.length <= creditLimitedAmount) {
        return;
      }

      _cubit.setCreditLimitText(
        "[${customer.name}], This customer already has ${Helpers.formatNumber(creditLimitedAmount, option: FormatType.quantity)} unpaid invoices. Proceeding may exceed the allowed limit.",
      );
    } else if (creditLimitType == kNoCredit) {
      _cubit.setCreditLimitText(
        "[${customer.name}], This customer must pay for what they buy. Please ensure payment is arranged, especially if there are existing unpaid invoices.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: "Sale ${widget.documentType} Cart"),
      body: BlocBuilder<AddCartPreviewCubit, AddCartPreviewState>(
        bloc: _cubit,
        builder: (BuildContext context, AddCartPreviewState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          if (state.saleLines.isEmpty) {
            return const EmptyScreen();
          }

          return buildBody(state);
        },
      ),
      persistentFooterButtons: [
        BlocBuilder<AddCartPreviewCubit, AddCartPreviewState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.saleLines.isEmpty) {
              return const SizedBox.shrink();
            }

            return SafeArea(
              child: BtnWidget(
                horizontal: appSpace,
                gradient: linearGradient,
                onPressed: _navigateToCheckoutScreen,
                title: "Next",
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildBody(AddCartPreviewState state) {
    if (state.saleLines.isEmpty) {
      return const EmptyScreen();
    }

    final totalLines = state.saleLines.length + 1;

    return Column(
      children: [
        if (state.creditLimitText.isNotEmpty)
          BoxWidget(
            rounding: 0,
            color: orangeColor.withValues(alpha: 0.1),
            padding: EdgeInsets.symmetric(
              horizontal: scaleFontSize(appSpace),
              vertical: scaleFontSize(8),
            ),
            width: double.infinity,
            isBoxShadow: false,
            child: TextWidget(
              color: warning,
              text: state.creditLimitText,
              fontSize: 16,
            ),
          ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: totalLines,
            padding: EdgeInsets.all(15.scale),
            itemBuilder: (context, index) {
              if (index + 1 == totalLines) {
                return BoxWidget(
                  key: ValueKey(index),
                  padding: EdgeInsets.all(8.scale),
                  margin: EdgeInsets.only(bottom: scaleFontSize(6)),
                  child: Column(
                    spacing: 8.scale,
                    children: [
                      TextShapeRow(
                        label: "Subtotal",
                        labelColor: textColor,
                        value: Helpers.formatNumberLink(
                          state.subTotalAmt,
                          option: FormatType.amount,
                        ),
                      ),
                      TextShapeRow(
                        label: "Discount",
                        labelColor: error,
                        valueColor: error,
                        value: Helpers.formatNumberLink(
                          state.totalDiscountAmt,
                          option: FormatType.amount,
                        ),
                      ),
                      TextShapeRow(
                        label: "Total VAT",
                        labelColor: textColor,
                        value: Helpers.formatNumberLink(
                          state.totalTaxAmt,
                          option: FormatType.amount,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: scaleFontSize(8),
                        ),
                        child: const DotLine(),
                      ),
                      TextShapeRow(
                        label: "Total",
                        labelColor: textColor,
                        labelFontWeight: FontWeight.bold,
                        labelFontSize: 18,
                        value: Helpers.formatNumberLink(
                          state.totalAmt,
                          option: FormatType.amount,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final line = state.saleLines[index];
              final indexItem = state.items.indexWhere((i) => i.no == line.no);

              Item? item;
              if (indexItem != -1) {
                item = state.items[indexItem];
              }

              final lineSubtotal =
                  Helpers.toDouble(line.quantity) *
                  Helpers.toDouble(line.unitPrice);
              final disAmt = lineSubtotal - Helpers.toDouble(line.amount);

              return BoxWidget(
                key: ValueKey(line.id),
                padding: EdgeInsets.all(8.scale),
                margin: EdgeInsets.only(bottom: scaleFontSize(6)),
                child: Column(
                  key: ValueKey(line.id),
                  spacing: 8.scale,
                  children: [
                    Row(
                      key: ValueKey("imgroo${line.id}"),
                      spacing: 6.scale,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ImageBoxCoverWidget(
                          key: ValueKey(line.id),
                          image: ImageNetWorkWidget(
                            key: ValueKey(line.id),
                            imageUrl: item?.avatar128 ?? "",
                            width: scaleFontSize(60),
                            height: scaleFontSize(60),
                          ),
                        ),
                        Expanded(
                          key: ValueKey("imgroo${line.id}"),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                key: ValueKey("imgroo${line.id}"),
                                spacing: 6.scale,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 6.scale,
                                      children: [
                                        TextWidget(
                                          text: line.no ?? "",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        TextWidget(
                                          text: line.description ?? "",
                                        ),
                                      ],
                                    ),
                                  ),
                                  if ((line.specialType ?? "").isNotEmpty)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: _getChipColor(
                                          line.specialType ?? "",
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          6.scale,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(5.scale),
                                      height: 70.scale,
                                      child: Text(
                                        line.specialType ?? "",
                                        style: TextStyle(
                                          color: white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.scale,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ChipWidget(
                          bgColor: grey20,
                          colorText: textColor,
                          label:
                              "${Helpers.formatNumber(line.quantity, option: FormatType.quantity)} ${line.unitOfMeasure ?? ''}",
                        ),
                        TextWidget(
                          text: Helpers.formatNumber(
                            line.unitPrice,
                            option: FormatType.amount,
                          ),
                          fontSize: 16,
                          color: success,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        spacing: 6.scale,
                        children: [
                          TextShapeRow(
                            label: "Price",
                            value: Helpers.formatNumberLink(
                              lineSubtotal,
                              option: FormatType.price,
                            ),
                            labelFontSize: 12,
                            valueFontSize: 13,
                          ),
                          TextShapeRow(
                            label: "Discount",
                            value: Helpers.formatNumberLink(
                              disAmt,
                              option: FormatType.amount,
                            ),
                            valueColor: error,
                            labelFontSize: 12,
                            valueFontSize: 13,
                          ),
                          TextShapeRow(
                            label: "VAT",
                            value: Helpers.formatNumberLink(
                              line.vatAmount,
                              option: FormatType.amount,
                            ),
                            labelFontSize: 12,
                            valueFontSize: 13,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.scale),
                            child: const DotLine(),
                          ),
                          TextShapeRow(
                            labelColor: textColor,
                            valueColor: primary,
                            label: "Line Total",
                            value: Helpers.formatNumberLink(
                              line.amountIncludingVatLcy,
                              option: FormatType.amount,
                            ),
                            labelFontSize: 12,
                            valueFontSize: 13,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      key: ValueKey("footerrow${line.id}"),
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 8.scale,
                      children: [
                        Expanded(
                          child: BtnWidget(
                            bgColor: mainColor.withValues(alpha: 0.2),
                            textColor: mainColor,
                            onPressed: () => _onEditHandler(line, item),
                            title: "Edit",
                            icon: const SvgWidget(
                              width: 20,
                              height: 20,
                              colorSvg: mainColor,
                              assetName: kEditIcon,
                            ),
                          ),
                        ),
                        // Expanded(
                        //   child: BtnWidget(
                        //     bgColor: skyColor.withValues(alpha: 0.2),
                        //     textColor: skyColor,
                        //     onPressed: () => _onShipmentHandler(line, item),
                        //     title: "Ship",
                        //     icon: const SvgWidget(
                        //       colorSvg: skyColor,
                        //       assetName: kSvgTruck,
                        //     ),
                        //   ),
                        // ),
                        Expanded(
                          child: BtnWidget(
                            bgColor: error.withValues(alpha: 0.2),
                            textColor: error,
                            onPressed: () => _onDeleteHandler(line),
                            title: "Delete",
                            icon: const SvgWidget(
                              colorSvg: error,
                              assetName: kSvgDelete,
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
      ],
    );
  }
}
