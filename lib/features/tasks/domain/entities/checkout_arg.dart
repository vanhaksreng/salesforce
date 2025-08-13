import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

class CheckoutArg {
  final PosSalesHeader salesHeader;
  final double subtotalAmount;
  final double discountAmount;
  final double vatAmount;
  final double amountDue;
  final String scheduleId;

  const CheckoutArg({
    required this.salesHeader,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.vatAmount,
    required this.amountDue,
    required this.scheduleId,
  });
}

class CheckoutSubmitArg {
  final PosSalesHeader salesHeader;
  final double subtotalAmount;
  final double discountAmount;
  final double vatAmount;
  final double amountDue;
  final double paymentAmount;
  final CustomerAddress shipmentAddress;
  final String requestShipmentDate;
  final Distributor? distributor;
  final String comments;
  final PaymentMethod? paymentMethod;
  final PaymentTerm? paymentTerm;
  final String scheduleId;

  const CheckoutSubmitArg({
    required this.salesHeader,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.vatAmount,
    required this.amountDue,
    required this.shipmentAddress,
    required this.scheduleId,
    this.requestShipmentDate = "",
    this.distributor,
    this.comments = "",
    this.paymentMethod,
    this.paymentTerm,
    this.paymentAmount = 0,
  });
}

class ItemPromotionFormArg {
  final ItemPromotionHeader header;
  final SalespersonSchedule schedule;
  final String documentType;

  const ItemPromotionFormArg({required this.header, required this.schedule, required this.documentType});
}
