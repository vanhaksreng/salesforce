import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class MyScheduleState {
  final bool isLoading;
  final String? isLoadingId;
  final List<SalespersonSchedule> schedules;
  final UserSetup? userSetup;
  final List<CustomerItemLedgerEntry> checkItemStockRecords;
  final List<CompetitorItemLedgerEntry> checkCompetitorItemStockRecords;
  final List<SalesPersonScheduleMerchandise> checkPosmRecords;
  final List<SalesPersonScheduleMerchandise> checkMerchandiseRecords;
  final List<SalesLine> saleLines;
  final int countCheckStock;
  final int countSaleOrder;
  final int countSaleInvoice;
  final int countSaleCreditMemo;
  final int countCollection;
  final int countCompetitorPromotion;
  final int countMerchandising;
  final int countPosm;
  final int countItemPrizeRedeption;
  final SalespersonSchedule? schedule;
  final int totalVisit;
  final int countCheckOut;
  final double totalSales;
  final double totalSalesBySchedule;
  final bool isSortDistance;
  final String selectedStatus;

  const MyScheduleState({
    this.isLoading = false,
    this.schedules = const [],
    this.saleLines = const [],
    this.isLoadingId,
    this.userSetup,
    this.countCheckStock = 0,
    this.countSaleOrder = 0,
    this.countSaleInvoice = 0,
    this.countSaleCreditMemo = 0,
    this.countCollection = 0,
    this.countCompetitorPromotion = 0,
    this.countMerchandising = 0,
    this.countPosm = 0,
    this.countItemPrizeRedeption = 0,
    this.schedule,
    this.checkItemStockRecords = const [],
    this.checkCompetitorItemStockRecords = const [],
    this.checkPosmRecords = const [],
    this.checkMerchandiseRecords = const [],
    this.totalVisit = 0,
    this.countCheckOut = 0,
    this.totalSales = 0,
    this.totalSalesBySchedule = 0,
    this.isSortDistance = false,
    this.selectedStatus = "All",
  });

  MyScheduleState copyWith({
    bool? isLoading,
    String? isLoadingId,
    List<SalespersonSchedule>? schedules,
    UserSetup? userSetup,
    List<SalesLine>? saleLines,
    List<Customer>? customers,
    int? countCheckStock,
    int? countSaleOrder,
    int? countSaleInvoice,
    int? countSaleCreditMemo,
    int? countCollection,
    int? countCompetitorPromotion,
    int? countMerchandising,
    int? countPosm,
    int? countItemPrizeRedeption,
    SalespersonSchedule? schedule,
    List<CustomerItemLedgerEntry>? checkItemStockRecords,
    List<CompetitorItemLedgerEntry>? checkCompetitorItemStockRecords,
    List<SalesPersonScheduleMerchandise>? checkPosmRecords,
    List<SalesPersonScheduleMerchandise>? checkMerchandiseRecords,
    int? totalVisit,
    int? countCheckOut,
    double? totalSales,
    double? totalSalesBySchedule,
    bool? isSortDistance,
    String? selectedStatus,
  }) {
    return MyScheduleState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingId: isLoadingId ?? this.isLoadingId,
      schedules: schedules ?? this.schedules,
      userSetup: userSetup ?? this.userSetup,
      saleLines: saleLines ?? this.saleLines,
      countCheckStock: countCheckStock ?? this.countCheckStock,
      countSaleOrder: countSaleOrder ?? this.countSaleOrder,
      countSaleInvoice: countSaleInvoice ?? this.countSaleInvoice,
      countSaleCreditMemo: countSaleCreditMemo ?? this.countSaleCreditMemo,
      countCollection: countCollection ?? this.countCollection,
      countCompetitorPromotion: countCompetitorPromotion ?? this.countCompetitorPromotion,
      countMerchandising: countMerchandising ?? this.countMerchandising,
      countPosm: countPosm ?? this.countPosm,
      countItemPrizeRedeption: countItemPrizeRedeption ?? this.countItemPrizeRedeption,
      schedule: schedule ?? this.schedule,
      checkItemStockRecords: checkItemStockRecords ?? this.checkItemStockRecords,
      checkCompetitorItemStockRecords: checkCompetitorItemStockRecords ?? this.checkCompetitorItemStockRecords,
      checkPosmRecords: checkPosmRecords ?? this.checkPosmRecords,
      checkMerchandiseRecords: checkMerchandiseRecords ?? this.checkMerchandiseRecords,
      totalVisit: totalVisit ?? this.totalVisit,
      countCheckOut: countCheckOut ?? this.countCheckOut,
      totalSales: totalSales ?? this.totalSales,
      totalSalesBySchedule: totalSalesBySchedule ?? this.totalSalesBySchedule,
      isSortDistance: isSortDistance ?? this.isSortDistance,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}
