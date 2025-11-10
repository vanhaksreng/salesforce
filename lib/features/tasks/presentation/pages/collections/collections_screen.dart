import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_text_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/collections/component_collections/cash_receipt_journal_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/collections/collections_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/collections/collections_state.dart';
import 'package:salesforce/features/tasks/presentation/pages/collections/component_collections/row_title.dart';
import 'package:salesforce/features/tasks/presentation/pages/detail_collections/detail_collections_screen.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key, required this.arg});
  static const String routeName = "collectionScreen";
  final CollectionsArg arg;

  @override
  State<CollectionsScreen> createState() => CollectionsScreenState();
}

class CollectionsScreenState extends State<CollectionsScreen>
    with MessageMixin {
  final _cubit = CollectionsCubit();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _cubit.getPaymentType();

    await _handleDownload();

    await _cubit.getCustomerLedgerEntry(
      param: {'customer_no': widget.arg.schedule.customerNo},
    );

    await _cubit.getCashReceiptJournals(
      param: {'customer_no': widget.arg.schedule.customerNo},
    );
  }

  void _navigateToDetailScreen(CustomerLedgerEntry entry) {
    Navigator.pushNamed(
      context,
      DetailCollectionsScreen.routeName,
      arguments: {
        'schedule': widget.arg.schedule,
        'customerLedgerEntry': entry,
      },
    ).then((value) {
      if (Helpers.shouldReload(value)) {
        _cubit.getCashReceiptJournals();
      }
    });
  }

  Future<void> _onSubmitCollectionHandler() async {
    final journals = _cubit.state.casReJounals
        .where((journal) => journal.status == kStatusOpen)
        .toList();
    if (journals.isEmpty) {
      showWarningMessage(greeting("Nothing to submit"));
      return;
    }

    Helpers.showDialogAction(
      context,
      labelAction: greeting("confirmation"),
      subtitle: greeting("are_you_sure_to_submit_all_receipt?"),
      cancelText: greeting("cancel"),
      confirmText: greeting("Yes, i'am sure"),
      confirm: () {
        Navigator.pop(context);
        processCashReceiptJournals();
      },
    );
  }

  void processCashReceiptJournals() {
    try {
      _cubit.processCashReceiptJournals().then((_) {
        showSuccessMessage(greeting("Journals processed successfully"));
        _cubit.getCashReceiptJournals();
      });
    } catch (e) {
      showErrorMessage(greeting("Error processing journals: ${e.toString()}"));
      return;
    }
  }

  Future<void> _handleDownload() async {
    final l = LoadingOverlay.of(context);
    l.show();

    await Future.delayed(const Duration(milliseconds: 200));
    try {
      List<String> tables = ["customer_ledger_entry", "cash_receipt_journals"];

      final filter = tables.map((table) => '"$table"').toList();

      final appSyncLogs = await _cubit.getAppSyncLogs({
        'tableName': 'IN {${filter.join(",")}}',
      });

      if (tables.isEmpty) {
        throw GeneralException("Cannot find any table related");
      }

      await _cubit.downloadDatas(appSyncLogs);

      await _initializeData();

      l.hide();
    } on GeneralException catch (e) {
      l.hide();
      showWarningMessage(e.message);
    } on Exception {
      l.hide();
      showErrorMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("Customer Balance"),
        heightBottom: heightBottomSearch,
        bottom: SearchWidget(
          onSubmitted: (value) {
            // TODO: Implement search functionality
          },
        ),
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
      body: BlocBuilder<CollectionsCubit, CollectionsState>(
        bloc: _cubit,
        builder: (context, state) => _buildBody(state),
      ),
      persistentFooterButtons: [
        BlocBuilder<CollectionsCubit, CollectionsState>(
          bloc: _cubit,
          builder: (context, state) {
            final journals = state.casReJounals
                .where((journal) => journal.status == kStatusOpen)
                .toList();
            return Visibility(
              visible: journals.isNotEmpty,
              child: BtnWidget(
                onPressed: _onSubmitCollectionHandler,
                title: greeting("submit"),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(CollectionsState state) {
    final records = state.cusLedgerEntry;
    final boxMt = EdgeInsets.only(top: 8.scale);
    final boxPadding = EdgeInsets.all(15.scale);

    return ListView.builder(
      itemCount: records.length,
      padding: const EdgeInsets.symmetric(horizontal: appSpace),
      itemBuilder: (context, index) {
        final record = records[index];

        final matchingJournals = _getMatchingCashReceiptJournals(record);

        final totalAmt = matchingJournals.fold(0.0, (sum, journal) {
          return sum + Helpers.toDouble(journal.amountLcy);
        });
        final remainingAmt = Helpers.toDouble(record.amountLcy) - totalAmt;
        return BoxWidget(
          key: ValueKey(record.entryNo),
          blurRadius: 15,
          padding: boxPadding,
          isBoxShadow: true,
          margin: boxMt,
          child: Column(
            spacing: 8.scale,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: "#${record.documentNo ?? ''} ",

                    fontWeight: FontWeight.bold,
                  ),
                  if (DateTimeExt.parse(record.dueDate).aging() > 0)
                    ChipWidget(
                      bgColor: warning.withValues(alpha: 0.1),
                      radius: 8.scale,
                      vertical: 6.scale,
                      horizontal: 0,
                      child: TextWidget(
                        text: greeting(
                          "days_overdue",
                          params: {
                            'day': DateTimeExt.parse(
                              record.dueDate,
                            ).aging().toString(),
                          },
                        ),
                        color: warning,
                        fontSize: 12.scale,
                      ),
                    ),
                ],
              ),
              TextWidget(
                text: "ORDER NO: ${record.orderNo ?? ''}",
                color: mainColor50,
                fontWeight: FontWeight.w500,
              ),
              rowCollectionTitle(
                key: 'TYPE',
                value: "Invoice",
                key2: "DATE",
                value2: DateTimeExt.parse(
                  record.postingDate,
                ).toDateNameString(),
              ),
              rowCollectionTitle(
                key: 'TOTAL',
                value: Helpers.formatNumber(
                  record.amountLcy,
                  option: FormatType.amount,
                ),
                valueColor: success,
                key2: "REMAINING",
                value2: Helpers.formatNumber(
                  remainingAmt,
                  option: FormatType.amount,
                ),
                value2Color: error,
              ),
              Helpers.gapH(1),
              CashReceiptJournalScreen(
                cashReJournals: matchingJournals,
                paymentMethods: state.paymentMethods,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BtnTextWidget(
                    bgColor: grey20,
                    child: Row(
                      children: [
                        TextWidget(
                          text: greeting("view_detail"),
                          color: primary,
                        ),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    onPressed: () => _navigateToDetailScreen(record),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<CashReceiptJournals> _getMatchingCashReceiptJournals(
    CustomerLedgerEntry ledgerEntry,
  ) {
    final allJournals = _cubit.state.casReJounals;
    return allJournals
        .where((journal) => journal.applyToDocNo == ledgerEntry.documentNo)
        .toList();
  }
}
