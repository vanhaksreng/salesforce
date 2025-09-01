import 'package:flutter/material.dart';

final kAppNavigatorKey = GlobalKey<NavigatorState>();
final kAppScaffoldMsgKey = GlobalKey<ScaffoldMessengerState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

const String kStatusNo = "No";
const String kStatusYes = "Yes";

const String kStatusCheckIn = "Checked In";
const String kStatusScheduled = "Scheduled";
const String kStatusCheckOut = "Checked Out";
const String kStatusNew = "New";
const String kStatusOpen = "Open";
const String kStatusPosted = "Posted";
const String kStatusApprove = "Approved";
const String kStatusClose = "Closed";
const String kStatusPending = "Pending";
const String kStatusSubmit = "Submitted";

const String kSaleOrder = "Order";
const String kSaleInvoice = "Invoice";
const String kSaleCreditMemo = "Credit Memo";
// const String kUseSaleOrder = "use_sales_order";
// const String kUseSaleInvoice = "use_sales_invoice";
// const String kUseSaleCreditMemo = "use_sales_credit_memo";
// const String kUseSaleItemRedemption = "use_item_prize_redemption";

const String kPromotionTypeStd = "STD";

const String kSourceTypeVisit = "Visit";
const String kTypeItem = "Item";

const String kPOSM = "POSM";
const String kMerchandize = "Merchandize";
const String kCompetitor = "Competitor";
const String kActive = "Active";
const String kInActive = "Inactive";
const String kInStock = "In stock";
const String kOutOfStock = "Out of stock";
const String kBalance = "Balance";
const String kNoOfInvoice = "No of Invoices";
const String kNoCredit = "No Credit";
const String kOffline = "Offline";
const String kOnline = "Online";
