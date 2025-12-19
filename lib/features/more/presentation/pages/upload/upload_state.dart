import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class UploadState {
  final bool isLoading;
  final bool isconnect;
  final List<CustomerItemLedgerEntry> customerItemLedgerEntries;
  final List<CompetitorItemLedgerEntry> competitorItemLedgerEntries;
  final List<SalesHeader> salesHeaders;
  final List<SalesLine> salesLines;
  final List<CashReceiptJournals> cashReceiptJournals;
  final List<SalespersonSchedule> salespersonSchedules;
  final List<SalesPersonScheduleMerchandise> merchandiseSchedules;
  final List<CompetitorPromtionHeader> compitorPromotionHeaders;
  final List<CompetitorPromotionLine> compitorPromotionLines;
  final List<ItemPrizeRedemptionLineEntry> redemptions;

  const UploadState({
    this.isLoading = false,
    this.isconnect = true,
    this.customerItemLedgerEntries = const [],
    this.salesHeaders = const [],
    this.salesLines = const [],
    this.cashReceiptJournals = const [],
    this.salespersonSchedules = const [],
    this.competitorItemLedgerEntries = const [],
    this.merchandiseSchedules = const [],
    this.compitorPromotionHeaders = const [],
    this.compitorPromotionLines = const [],
    this.redemptions = const [],
  });

  UploadState copyWith({
    bool? isLoading,
    bool? isconnect,
    List<CustomerItemLedgerEntry>? customerItemLedgerEntries,
    List<SalesHeader>? salesHeaders,
    List<SalesLine>? salesLines,
    List<CashReceiptJournals>? cashReceiptJournals,
    List<SalespersonSchedule>? salespersonSchedules,
    List<CompetitorItemLedgerEntry>? competitorItemLedgerEntries,
    List<SalesPersonScheduleMerchandise>? merchandiseSchedules,
    List<CompetitorPromtionHeader>? compitorPromotionHeaders,
    List<CompetitorPromotionLine>? compitorPromotionLines,
    List<ItemPrizeRedemptionLineEntry>? redemptions,
  }) {
    return UploadState(
      isLoading: isLoading ?? this.isLoading,
      isconnect: isconnect ?? this.isconnect,
      customerItemLedgerEntries:
          customerItemLedgerEntries ?? this.customerItemLedgerEntries,
      salesHeaders: salesHeaders ?? this.salesHeaders,
      salesLines: salesLines ?? this.salesLines,
      cashReceiptJournals: cashReceiptJournals ?? this.cashReceiptJournals,
      salespersonSchedules: salespersonSchedules ?? this.salespersonSchedules,
      competitorItemLedgerEntries:
          competitorItemLedgerEntries ?? this.competitorItemLedgerEntries,
      merchandiseSchedules: merchandiseSchedules ?? this.merchandiseSchedules,
      compitorPromotionHeaders:
          compitorPromotionHeaders ?? this.compitorPromotionHeaders,
      compitorPromotionLines:
          compitorPromotionLines ?? this.compitorPromotionLines,
      redemptions: redemptions ?? this.redemptions,
    );
  }
}
