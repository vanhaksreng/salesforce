import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/quantity_input_formatter.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/collections/component_collections/cash_receipt_journal_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/collections/component_collections/row_title.dart';
import 'package:salesforce/features/tasks/presentation/pages/detail_collections/detail_collections_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/detail_collections/detail_collections_state.dart';
import 'package:salesforce/features/tasks/presentation/pages/payment_screen/payment_screen_screen.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class DetailCollectionsScreen extends StatefulWidget {
  const DetailCollectionsScreen({
    super.key,
    required this.customerLedgerEntry,
    required this.schedule,
  });
  static const String routeName = "detailCollection";

  final CustomerLedgerEntry customerLedgerEntry;
  final SalespersonSchedule schedule;

  @override
  DetailCollectionsScreenState createState() => DetailCollectionsScreenState();
}

class DetailCollectionsScreenState extends State<DetailCollectionsScreen>
    with MessageMixin {
  final _cubit = DetailCollectionsCubit();
  final _receiveAmoutCtr = TextEditingController();
  final _paymentTypeCtr = TextEditingController();
  bool isUpdate = false;
  PaymentMethod? _paymentMethod;
  late CustomerLedgerEntry cEntry;
  late ActionState _action = ActionState.init;

  @override
  void initState() {
    super.initState();
    _cubit.getPaymentType();
    _cubit.getCashReceiptJournals(
      param: {"apply_to_doc_no": widget.customerLedgerEntry.documentNo},
    );

    cEntry = widget.customerLedgerEntry;
  }

  void _onNavigatorToPaymentScreen() {
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

  void _deletedPayment(CashReceiptJournals journal) async {
    Helpers.showDialogAction(
      context,
      subtitle: greeting("do_you_want_to_delete_new_payment?"),
      confirmText: greeting("Yes, Delete"),
      cancelText: "No, Keet it",
      confirm: () async {
        Navigator.of(context).pop();
        await _cubit.deletedPayment(journal, cEntry);
        _action = ActionState.updated;
      },
    );
  }

  void _onSaveCollectionHandler() async {
    if (_receiveAmoutCtr.text.isEmpty) {
      return showWarningMessage(greeting("receive_amoun_require"));
    }

    final remainingAmt =
        Helpers.toDouble(cEntry.amountLcy) - _cubit.state.totalReceiveAmt;
    if (Helpers.toDouble(_receiveAmoutCtr.text) > remainingAmt) {
      return showWarningMessage(
        greeting("Receive amount cannot greather than remaining amount."),
      );
    }

    if (_paymentMethod == null) {
      return showWarningMessage(greeting("payment_method_require"));
    }

    try {
      await _cubit.processPayment(
        PaymentArg(
          amount: Helpers.toDouble(_receiveAmoutCtr.text),
          paymentMethod: _paymentMethod!,
          schedule: widget.schedule,
          customerLedgerEntry: cEntry,
        ),
      );
      _receiveAmoutCtr.text = "";
      _action = ActionState.created;
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: "Payments",
        onBack: () => Navigator.of(context).pop(_action),
      ),
      body: BlocBuilder<DetailCollectionsCubit, DetailCollectionsState>(
        bloc: _cubit,
        builder: (context, state) {
          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(DetailCollectionsState state) {
    final remainingAmt =
        Helpers.toDouble(cEntry.amountLcy) - state.totalReceiveAmt;

    final hasJournals = state.cashReceiptJournals.isNotEmpty;
    final lastJournalApproved =
        hasJournals && state.cashReceiptJournals.last.status == kStatusApprove;

    final shouldShowPaymentBox =
        (hasJournals && lastJournalApproved && remainingAmt > 0) ||
        !hasJournals;

    return ListView(
      padding: EdgeInsets.all(15.scale),
      children: [
        _headerBoxInfo(remainingAmt),
        if (hasJournals) ...[
          Helpers.gapH(15),
          BoxWidget(
            padding: EdgeInsets.all(15.scale),
            child: Column(
              children: [
                Row(
                  spacing: 8.scale,
                  children: [
                    ChipWidget(
                      bgColor: success.withValues(alpha: 0.1),
                      radius: 8.scale,
                      vertical: 6.scale,
                      horizontal: 0,
                      child: Icon(
                        Icons.history,
                        color: success,
                        size: 16.scale,
                      ),
                    ),
                    TextWidget(
                      text: 'Payment Histories',
                      fontSize: 16.scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                Helpers.gapH(15),
                CashReceiptJournalScreen(
                  cashReJournals: state.cashReceiptJournals,
                  paymentMethods: state.paymentMethods,
                  onPressed: (journal) => _deletedPayment(journal),
                ),
              ],
            ),
          ),
        ],
        if (shouldShowPaymentBox) ...[Helpers.gapH(15), _paymentBox()],
      ],
    );
  }

  BoxWidget _headerBoxInfo(double remainingAmt) {
    return BoxWidget(
      padding: EdgeInsets.all(15.scale),
      child: Column(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(
                text: cEntry.customerName ?? '',
                fontSize: 16.scale,
                fontWeight: FontWeight.bold,
              ),
              ChipWidget(
                label: "${cEntry.documentType}".toUpperCase(),
                fontWeight: FontWeight.bold,
                fontSize: 13.scale,
                vertical: 6.scale,
                colorText: success,
                radius: 15.scale,
                bgColor: success.withValues(alpha: 0.1),
              ),
            ],
          ),
          rowCollectionTitle(
            key: 'Order No'.toUpperCase(),
            value: cEntry.documentNo ?? "",
            key2: "Date".toUpperCase(),
            value2: DateTimeExt.parse(cEntry.postingDate).toDateNameString(),
          ),
          rowCollectionTitle(
            key: 'Total Amount'.toUpperCase(),
            value: Helpers.formatNumberLink(
              cEntry.amountLcy,
              option: FormatType.amount,
            ),
            key2: "Remaining Amount".toUpperCase(),
            value2: Helpers.formatNumberLink(
              remainingAmt,
              option: FormatType.amount,
            ),
            value2Color: red,
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
                bgColor: const Color(0XFF7C3AED).withValues(alpha: 0.1),
                radius: 8.scale,
                vertical: 6.scale,
                horizontal: 0,
                child: Icon(
                  Icons.payment,
                  color: const Color(0XFF7C3AED),
                  size: 16.scale,
                ),
              ),
              TextWidget(
                text: 'New Payment',
                fontSize: 16.scale,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          TextFormFieldWidget(
            controller: _receiveAmoutCtr,
            isDense: true,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            inputFormatters: const [QuantityInputFormatter(decimalRange: 8)],
            textColor: textColor50,
            label: greeting("receive_amount"),
            isDefaultTextForm: true,
            suffixIcon: const SizedBox.shrink(),
          ),
          TextFormFieldWidget(
            onTap: () => _onNavigatorToPaymentScreen(),
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
          BtnWidget(
            bgColor: primary,
            onPressed: () => _onSaveCollectionHandler(),
            title: greeting("save"),
          ),
        ],
      ),
    );
  }
}
