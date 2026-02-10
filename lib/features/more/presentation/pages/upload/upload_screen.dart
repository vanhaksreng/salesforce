import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/upload/upload_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/upload/upload_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  static const String routeName = '/uploadMoreScreen';

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _cubit = UploadCubit();

  final boxPadding = EdgeInsets.symmetric(
    horizontal: 15.scale,
    vertical: 10.scale,
  );

  final boxContentPadding = EdgeInsets.symmetric(vertical: 10.scale);

  final double headerFontSize = 14;

  @override
  void initState() {
    super.initState();
    _cubit.loadInitialData(DateTime.now());
  }

  void _uploadDataHandler() {
    //Vilidate before process;

    Helpers.showDialogAction(
      context,
      labelAction: greeting("Upload Data"),
      subtitle: "Your data is ready. Would you like to upload it now?",
      confirmText: "Yes, Upload",
      canCancel: true,
      cancelText: "Not Now",
      confirm: () {
        Navigator.of(context).pop();
        _processUploadNow();
      },
    );
  }

  void _processUploadNow() async {
    final l = LoadingOverlay.of(context);
    l.show();

    try {
      await _cubit.processUpload();

      if (!context.mounted) return;

      if (!_cubit.state.isconnect) {
        l.hide();
        if (!mounted) return;
        Helpers.showNoInternetDialog(context);
        return;
      }
      l.hide();
      if (_cubit.error == 0) {
        _cubit.showSuccessMessage('Upload completed successfully');
      }

      // _cubit.showSuccessMessage('Upload completed successfully');
    } catch (e) {
      if (!context.mounted) return;
      l.hide();
      _cubit.showErrorMessage(e.toString());
    }
  }

  Color getScheduleColor(String status) {
    if (status == kStatusCheckIn) {
      return warning;
    } else if (status == kStatusCheckOut) {
      return mainColor;
    }

    return success;
  }

  String _getScheduleText(SalespersonSchedule schedule) {
    if (schedule.status != kStatusCheckOut) {
      return "Pending : ${schedule.name}".toUpperCase();
    }

    return "Visited : ${schedule.name}".toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: "Upload Dashboard",
        onBack: () => Navigator.pop(context, ActionState.updated),
      ),
      body: BlocBuilder<UploadCubit, UploadState>(
        bloc: _cubit,
        builder: (BuildContext context, UploadState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
      persistentFooterButtons: [
        SafeArea(
          child: BtnWidget(
            size: BtnSize.medium,
            gradient: linearGradient,
            title: greeting("Upload Data"),
            onPressed: _uploadDataHandler,
          ),
        ),
      ],
    );
  }

  Widget buildBody(UploadState state) {
    final merchanise = state.merchandiseSchedules
        .where((e) => e.merchandiseOption == kMerchandize)
        .toList();
    final posm = state.merchandiseSchedules
        .where((e) => e.merchandiseOption == kPOSM)
        .toList();

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 15.scale, vertical: 10.scale),
      children: [
        _buildBox(
          title: 'Check Stock',
          child: _buildCheckStockBox(
            state.customerItemLedgerEntries,
            state.salespersonSchedules,
          ),
          totalRecords: state.customerItemLedgerEntries.length,
        ),
        _buildBox(
          title: 'Competitor Check Stock',
          child: _buildCompetitorCheckStockBox(
            state.competitorItemLedgerEntries,
            state.salespersonSchedules,
          ),
          totalRecords: state.competitorItemLedgerEntries.length,
        ),
        _buildBox(
          title: 'Collection',
          child: _buildCollectionBox(state.cashReceiptJournals),
          totalRecords: state.cashReceiptJournals.length,
        ),
        // _buildBox(
        //   title: 'Competitor Promotion',
        //   child: _buildCompetitorPromotionBox(state.compitorPromotionHeaders),
        //   totalRecords: state.compitorPromotionHeaders.length,
        // ),
        _buildBox(
          title: 'Merchandising',
          child: _buildCheckPosmAndMerchandisingBox(
            merchanise,
            state.salespersonSchedules,
          ),
          totalRecords: merchanise.length,
        ),
        _buildBox(
          title: 'POSM',
          child: _buildCheckPosmAndMerchandisingBox(
            posm,
            state.salespersonSchedules,
          ),
          totalRecords: posm.length,
        ),
        _buildBox(
          title: 'Redemption',
          child: _buildRedemptionBox(
            state.redemptions,
            state.salespersonSchedules,
          ),
          totalRecords: state.redemptions.length,
        ),
        _buildBox(
          title: 'Sales',
          child: _buildSalekBox(state.salesHeaders, state.salespersonSchedules),
          totalRecords: state.salesHeaders.length,
        ),
        _buildBox(
          title: 'Schedule',
          child: _buildScheduleBox(state.salespersonSchedules),
          totalRecords: state.salespersonSchedules.length,
        ),
      ],
    );
  }

  Widget _buildEmptyBox() {
    return SizedBox(
      height: 60.scale,
      child: const Center(
        child: TextWidget(text: "No data available", fontSize: 14, color: grey),
      ),
    );
  }

  Widget _buildCollectionBox(List<CashReceiptJournals> records) {
    if (records.isEmpty) {
      return _buildEmptyBox();
    }

    final List<String> grouped = [];
    for (final record in records) {
      final dateKey = record.postingDate ?? "";
      if (dateKey.isNotEmpty && !grouped.contains(dateKey)) {
        grouped.add(dateKey);
      }
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 15.scale),
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, _) => Padding(
        padding: EdgeInsets.symmetric(vertical: 15.scale),
        child: Hr(height: 1.scale, color: grey20, width: double.infinity),
      ),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final date = grouped[index];
        final newRecords = records.where((e) => e.postingDate == date).toList();

        return Column(
          key: ValueKey(date),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getDateBox(date),
            ListView.builder(
              itemCount: newRecords.length,
              shrinkWrap: true,
              key: ValueKey(date),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final record = newRecords[index];
                return Container(
                  key: ValueKey(record.id),
                  padding: EdgeInsets.all(8.scale),
                  margin: EdgeInsets.only(top: 8.scale),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color.fromARGB(84, 239, 237, 237),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRightAlignedText(
                        "#${record.applyToDocNo}",
                        record.description ?? "",
                      ),
                      Column(
                        key: ValueKey(record.id),
                        children: [
                          TextWidget(
                            key: ValueKey(record.id),
                            text: Helpers.formatNumberLink(
                              record.amountLcy,
                              option: FormatType.amount,
                            ),
                            color: success,
                            fontSize: headerFontSize - 2,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 5.scale),
                          TextWidget(
                            text: record.paymentMethodCode ?? "",
                            fontSize: headerFontSize - 3,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckStockBox(
    List<CustomerItemLedgerEntry> entries,
    List<SalespersonSchedule> schedules,
  ) {
    if (entries.isEmpty) {
      return _buildEmptyBox();
    }

    return ListView.separated(
      itemCount: schedules.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 15.scale),
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        if (index + 1 >= schedules.length) return const SizedBox.shrink();

        final nextSchedule = schedules[index + 1];
        final nextStockRecords = entries
            .where((e) => e.scheduleId == nextSchedule.id)
            .toList();
        if (nextStockRecords.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 15.scale),
          child: Hr(height: 1.scale, color: grey20, width: double.infinity),
        );
      },
      itemBuilder: (BuildContext context, int index) {
        final schedule = schedules[index];

        final stockRecords = entries
            .where((e) => e.scheduleId == schedule.id)
            .toList();

        if (stockRecords.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          key: ValueKey(schedule.id),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              key: ValueKey("row${schedule.id}"),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChipWidget(
                  key: ValueKey("text${schedule.id}"),
                  bgColor: primary.withValues(alpha: 0.06),
                  colorText: primary,
                  radius: 8.scale,
                  child: TextWidget(
                    key: ValueKey("text${schedule.id}"),
                    text: _getScheduleText(schedule),
                    fontSize: headerFontSize - 4,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                _getDateBox(schedule.scheduleDate ?? ""),
              ],
            ),
            ListView.builder(
              key: ValueKey(schedule.id),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stockRecords.length,
              itemBuilder: (context, index) {
                final entry = stockRecords[index];
                return Container(
                  key: ValueKey(entry.entryNo),
                  padding: EdgeInsets.all(8.scale),
                  margin: EdgeInsets.only(top: 8.scale),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color.fromARGB(84, 239, 237, 237),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRightAlignedText(
                        entry.itemDescription ?? "",
                        entry.itemNo ?? "",
                      ),
                      ChipWidget(
                        bgColor: success.withValues(alpha: 0.08),
                        colorText: success,
                        radius: 8.scale,
                        vertical: 6.scale,
                        horizontal: 0,
                        label:
                            Helpers.formatNumber(
                              entry.quantity,
                              option: FormatType.quantity,
                            ).isEmpty
                            ? "Out of stock"
                            : "${Helpers.formatNumberLink(entry.quantity, option: FormatType.quantity)} ${entry.unitOfMeasureCode ?? ""}",
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompetitorCheckStockBox(
    List<CompetitorItemLedgerEntry> entries,
    List<SalespersonSchedule> schedules,
  ) {
    if (entries.isEmpty) {
      return _buildEmptyBox();
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 15.scale),
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        if (index + 1 >= schedules.length) return const SizedBox.shrink();

        final nextSchedule = schedules[index + 1];
        final nextStockRecords = entries
            .where((e) => e.scheduleId == nextSchedule.id)
            .toList();
        if (nextStockRecords.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          key: ValueKey("seperate${nextSchedule.id}"),
          padding: EdgeInsets.symmetric(vertical: 15.scale),
          child: Hr(
            key: ValueKey("seperate${nextSchedule.id}"),
            height: 1.scale,
            color: grey20,
            width: double.infinity,
          ),
        );
      },
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];

        final stockRecords = entries
            .where((e) => e.scheduleId == schedule.id)
            .toList();

        if (stockRecords.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          key: ValueKey(schedule.id),
          children: [
            Row(
              key: ValueKey("row${schedule.id}"),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChipWidget(
                  key: ValueKey("text${schedule.id}"),
                  bgColor: primary.withValues(alpha: 0.06),
                  colorText: primary,
                  radius: 8.scale,
                  child: TextWidget(
                    key: ValueKey("text${schedule.id}"),
                    text: _getScheduleText(schedule),
                    fontSize: headerFontSize - 4,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                _getDateBox(schedule.scheduleDate ?? ""),
              ],
            ),
            ListView.builder(
              key: ValueKey("list${schedule.id}"),
              itemCount: stockRecords.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final entry = stockRecords[index];
                return Container(
                  key: ValueKey(entry.entryNo),
                  padding: EdgeInsets.all(8.scale),
                  margin: EdgeInsets.only(top: 8.scale),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color.fromARGB(84, 239, 237, 237),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRightAlignedText(
                        entry.itemDescription ?? "",
                        entry.itemNo ?? "",
                      ),
                      ChipWidget(
                        bgColor: success.withValues(alpha: 0.2),
                        colorText: success,
                        radius: 8.scale,
                        vertical: 6.scale,
                        horizontal: 0,
                        label: Helpers.formatNumberLink(
                          entry.quantity,
                          option: FormatType.quantity,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSalekBox(
    List<SalesHeader> salesHeaders,
    List<SalespersonSchedule> schedules,
  ) {
    if (salesHeaders.isEmpty) {
      return _buildEmptyBox();
    }
    final modifiedSchedules = [
      ...schedules,
      SalespersonSchedule("", name: "Non Schedule"),
    ];
    // schedules.add(SalespersonSchedule("", name: "Non Schedule"));

    schedules.add(SalespersonSchedule("", name: "Non Schedule"));

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        if (index + 1 >= modifiedSchedules.length) {
          return const SizedBox.shrink();
        }

        final nextSchedule = modifiedSchedules[index + 1];
        final nextStockRecords = salesHeaders
            .where((e) => e.sourceNo == nextSchedule.id)
            .toList();

        if (nextStockRecords.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          key: ValueKey("seperate${nextSchedule.id}"),
          padding: EdgeInsets.symmetric(vertical: 15.scale),
          child: Hr(
            key: ValueKey("seperate${nextSchedule.id}"),
            height: 1.scale,
            color: grey20,
            width: double.infinity,
          ),
        );
      },
      itemCount: modifiedSchedules.length,
      itemBuilder: (context, index) {
        final schedule = modifiedSchedules[index];

        final saleRecords = salesHeaders
            .where((e) => e.sourceNo == schedule.id)
            .toList();

        if (saleRecords.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          key: ValueKey(schedule.id),
          children: [
            Row(
              spacing: scaleFontSize(appSpace8),
              key: ValueKey("row${schedule.id}"),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChipWidget(
                  key: ValueKey("text${schedule.id}"),
                  bgColor: getScheduleColor(
                    schedule.status ?? "",
                  ).withValues(alpha: 0.08),
                  colorText: getScheduleColor(schedule.status ?? ""),
                  radius: 8.scale,
                  label: _getScheduleText(schedule),
                ),
                Expanded(child: _getDateBox(schedule.scheduleDate ?? "")),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: 15.scale),
              physics: const NeverScrollableScrollPhysics(),
              key: ValueKey("list${schedule.id}"),
              itemCount: saleRecords.length,
              itemBuilder: (context, index) {
                final salesHeader = saleRecords[index];
                final totalSaleAmt = _cubit.state.salesLines
                    .where((line) => line.documentNo == salesHeader.no)
                    .fold<double>(
                      0,
                      (sum, line) =>
                          sum + Helpers.toDouble(line.amountIncludingVatLcy),
                    );
                return Container(
                  key: ValueKey(salesHeader.id),
                  padding: EdgeInsets.all(8.scale),
                  margin: EdgeInsets.only(top: 8.scale),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color.fromARGB(84, 239, 237, 237),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: Helpers.formatNumberLink(
                              totalSaleAmt,
                              option: FormatType.amount,
                            ),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 5.scale),
                          TextWidget(
                            text: "#${salesHeader.no}",
                            fontSize: 14,
                            color: textColor,
                          ),
                        ],
                      ),
                      ChipWidget(
                        bgColor: getStatusColor(
                          salesHeader.documentType ?? "",
                        ).withValues(alpha: 0.1),
                        colorText: getStatusColor(
                          salesHeader.documentType ?? "",
                        ),
                        radius: 8.scale,
                        vertical: 6.scale,
                        horizontal: 0,
                        label: salesHeader.documentType ?? "",
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Color getStatusColor(String documentType) {
    switch (documentType) {
      case kSaleInvoice:
        return success;
      case kSaleOrder:
        return warning;
      default:
        return red;
    }
  }

  Widget _buildCheckPosmAndMerchandisingBox(
    List<SalesPersonScheduleMerchandise> merchandise,
    List<SalespersonSchedule> schedules,
  ) {
    if (merchandise.isEmpty) {
      return _buildEmptyBox();
    }

    return ListView.separated(
      itemCount: schedules.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 15.scale),
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        if (index + 1 >= schedules.length) return const SizedBox.shrink();

        final nextSchedule = schedules[index + 1];
        final nextRecords = merchandise
            .where((e) => "${e.visitNo}" == nextSchedule.id)
            .toList();
        if (nextRecords.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 15.scale),
          child: Hr(height: 1.scale, color: grey20, width: double.infinity),
        );
      },
      itemBuilder: (BuildContext context, int index) {
        final schedule = schedules[index];

        final newRecords = merchandise
            .where((e) => "${e.visitNo}" == schedule.id)
            .toList();
        if (newRecords.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          key: ValueKey(schedule.id),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4.scale,
              key: ValueKey("row${schedule.id}"),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: ChipWidget(
                    key: ValueKey("text${schedule.id}"),
                    bgColor: primary.withValues(alpha: 0.06),
                    colorText: primary,
                    radius: 8.scale,
                    child: TextWidget(
                      key: ValueKey("text${schedule.id}"),
                      text: _getScheduleText(schedule),
                      fontSize: headerFontSize - 4,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                if ((schedule.scheduleDate ?? "").isNotEmpty)
                  _getDateBox(schedule.scheduleDate ?? ""),
              ],
            ),
            ListView.builder(
              key: ValueKey(schedule.id),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: newRecords.length,
              itemBuilder: (context, index) {
                final entry = newRecords[index];
                return Container(
                  key: ValueKey(entry.id),
                  padding: EdgeInsets.all(8.scale),
                  margin: EdgeInsets.only(top: 8.scale),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color.fromARGB(84, 239, 237, 237),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRightAlignedText(
                        entry.description ?? "",
                        entry.competitorNo ?? "",
                      ),
                      ChipWidget(
                        bgColor: success.withValues(alpha: 0.08),
                        colorText: success,
                        radius: 8.scale,
                        vertical: 6.scale,
                        horizontal: 0,
                        label:
                            Helpers.formatNumber(
                              entry.quantity,
                              option: FormatType.quantity,
                            ).isEmpty
                            ? "Out of stock"
                            : Helpers.formatNumberLink(
                                entry.quantity,
                                option: FormatType.quantity,
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildScheduleBox(List<SalespersonSchedule> schedules) {
    if (schedules.isEmpty) {
      return _buildEmptyBox();
    }

    final List<String> grouped = [];
    for (final record in schedules) {
      final dateKey = record.scheduleDate ?? "";
      if (dateKey.isNotEmpty && !grouped.contains(dateKey)) {
        grouped.add(dateKey);
      }
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      separatorBuilder: (_, _) => Padding(
        padding: EdgeInsets.symmetric(vertical: 15.scale),
        child: Hr(height: 1.scale, color: grey20, width: double.infinity),
      ),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final date = grouped[index];
        final newRecords = schedules
            .where((e) => e.scheduleDate == date)
            .toList();

        return Column(
          key: ValueKey(date),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getDateBox(date),
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: newRecords.length,
              itemBuilder: (context, index) {
                final schedule = newRecords[index];
                return Container(
                  key: ValueKey(schedule.id),
                  padding: boxContentPadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: schedule.customerNo ?? "",
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            SizedBox(height: 5.scale),
                            TextWidget(
                              text: schedule.name ?? "",
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 3.scale,
                        children: [
                          ChipWidget(
                            bgColor: getScheduleColor(
                              schedule.status ?? "",
                            ).withValues(alpha: 0.1),
                            radius: 8.scale,
                            vertical: 6.scale,
                            horizontal: 0,
                            label: schedule.status ?? "",
                            colorText: getScheduleColor(schedule.status ?? ""),
                          ),
                          if (schedule.updatedAt != null)
                            TextWidget(
                              text:
                                  "Last sync : ${DateTimeExt.parse(schedule.updatedAt).toTimeString()}",
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompetitorPromotionBox(List<CompetitorPromtionHeader> headers) {
    if (headers.isEmpty) {
      return _buildEmptyBox();
    }

    return _buildEmptyBox(); //TODO
  }

  Widget _buildRedemptionBox(
    List<ItemPrizeRedemptionLineEntry> entries,
    List<SalespersonSchedule> schedules,
  ) {
    if (entries.isEmpty) {
      return _buildEmptyBox();
    }

    final List<String> grouped = [];
    for (final record in schedules) {
      final dateKey = record.scheduleDate ?? "";
      if (dateKey.isNotEmpty && !grouped.contains(dateKey)) {
        grouped.add(dateKey);
      }
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 15.scale),
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        if (index + 1 >= schedules.length) return const SizedBox.shrink();

        final nextSchedule = schedules[index + 1];
        final nextStockRecords = entries
            .where((e) => e.scheduleId == nextSchedule.id)
            .toList();
        if (nextStockRecords.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          key: ValueKey("seperate${nextSchedule.id}"),
          padding: EdgeInsets.symmetric(vertical: 15.scale),
          child: Hr(
            key: ValueKey("seperate${nextSchedule.id}"),
            height: 1.scale,
            color: grey20,
            width: double.infinity,
          ),
        );
      },
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];

        final stockRecords = entries
            .where((e) => e.scheduleId == schedule.id)
            .toList();

        if (stockRecords.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          key: ValueKey(schedule.id),
          children: [
            Row(
              spacing: 4.scale,
              key: ValueKey("row${schedule.id}"),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: ChipWidget(
                    key: ValueKey("text${schedule.id}"),
                    bgColor: primary.withValues(alpha: 0.06),
                    colorText: primary,
                    radius: 8.scale,
                    child: TextWidget(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      key: ValueKey("text${schedule.id}"),
                      text: _getScheduleText(schedule),
                      fontSize: headerFontSize - 4,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                _getDateBox(schedule.scheduleDate ?? ""),
              ],
            ),
            ListView.builder(
              key: ValueKey("list${schedule.id}"),
              itemCount: stockRecords.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final entry = stockRecords[index];
                return Container(
                  key: ValueKey(entry.id),
                  padding: EdgeInsets.all(8.scale),
                  margin: EdgeInsets.only(top: 8.scale),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color.fromARGB(84, 239, 237, 237),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRightAlignedText(
                        entry.description ?? "",
                        "${entry.itemNo} . ${entry.promotionNo}",
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ChipWidget(
                            bgColor: success.withValues(alpha: 0.1),
                            colorText: success,
                            radius: 8.scale,
                            vertical: 6.scale,
                            horizontal: 0,
                            label: Helpers.formatNumberLink(
                              entry.quantity,
                              option: FormatType.quantity,
                            ),
                          ),
                          TextWidget(
                            text: (entry.redemptionType ?? "").toUpperCase(),
                            fontSize: headerFontSize - 4,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Column _buildRightAlignedText(String value1, String value2) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: value1,
          fontSize: headerFontSize - 3,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: 5.scale),
        TextWidget(
          text: value2,
          fontSize: headerFontSize - 4,
          color: Colors.black54,
        ),
      ],
    );
  }

  BoxWidget _buildBox({
    required String title,
    int totalRecords = 0,
    required Widget child,
  }) {
    return BoxWidget(
      color: white,
      margin: EdgeInsets.only(bottom: 10.scale),
      child: Column(
        spacing: 15.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(15.scale),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: grey20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: title,
                  fontSize: headerFontSize,
                  fontWeight: FontWeight.bold,
                ),
                if (totalRecords > 0)
                  ChipWidget(
                    bgColor: red,
                    radius: 8.scale,
                    isCircle: true,
                    horizontal: 0,
                    child: Text(
                      "$totalRecords",
                      style: TextStyle(fontSize: 12.scale, color: white),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.scale),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _getDateBox(String date) {
    return ChipWidget(
      key: ValueKey("date$date"),
      bgColor: primary.withValues(alpha: 0.06),
      colorText: primary,
      radius: 8.scale,
      vertical: 6.scale,
      horizontal: 0,
      child: Row(
        spacing: 4.scale,
        children: [
          Icon(
            Icons.date_range_rounded,
            size: 14.scale,
            color: _dateColor(date),
          ),
          TextWidget(
            fontSize: 12,
            key: ValueKey("date$date"),
            fontWeight: FontWeight.w500,
            text: DateTimeExt.parse(date).toDateNameString(),
            color: _dateColor(date),
          ),
        ],
      ),
    );
  }

  Color _dateColor(String date) {
    if (DateTimeExt.parse(date).isToday) {
      return primary;
    }

    return red;
  }
}
