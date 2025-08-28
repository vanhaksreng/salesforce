import 'package:image_picker/image_picker.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/features/tasks/domain/entities/sale_form_input.dart';
import 'package:salesforce/features/tasks/domain/entities/process_dtos.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class CheckInArg {
  final double latitude;
  final double longitude;
  final String comment;
  final XFile? imagePath;
  final bool isCloseShop;

  CheckInArg({
    required this.latitude,
    required this.longitude,
    required this.comment,
    this.isCloseShop = false,
    this.imagePath,
  });
}

abstract class CheckStockArg {
  final double stockQty;
  final String plannedQuantity;
  final String plannedQuantityReturn;
  final String quantityBuyFromOther;
  final String expirationDate;
  final String lotNo;
  final String serialNo;
  final String remark;
  final bool updateOnlyQty;

  final SalespersonSchedule schedule;

  CheckStockArg({
    required this.stockQty,
    required this.schedule,
    this.plannedQuantity = "0",
    this.plannedQuantityReturn = "0",
    this.quantityBuyFromOther = "0",
    this.expirationDate = "",
    this.lotNo = "",
    this.serialNo = "",
    this.remark = "",
    this.updateOnlyQty = false,
  });
}

class CheckItemStockArg extends CheckStockArg {
  final Item item;

  CheckItemStockArg({
    required this.item,
    required super.stockQty,
    required super.schedule,
    super.plannedQuantity = "0",
    super.plannedQuantityReturn = "0",
    super.quantityBuyFromOther = "0",
    super.expirationDate = "",
    super.lotNo = "",
    super.serialNo = "",
    super.remark = "",
    super.updateOnlyQty = false,
  });
}

class CheckCompititorItemStockArg extends CheckStockArg {
  final CompetitorItem item;
  final String status;
  final double unitPrice;
  final double unitCost;
  final double volumSale;

  CheckCompititorItemStockArg({
    required this.item,
    required super.stockQty,
    required super.schedule,
    super.plannedQuantity = "0",
    super.plannedQuantityReturn = "0",
    super.quantityBuyFromOther = "0",
    super.expirationDate = "",
    super.lotNo = "",
    super.serialNo = "",
    super.remark = "",
    this.status = "",
    this.unitCost = 0,
    this.unitPrice = 0,
    this.volumSale = 0,
    super.updateOnlyQty = false,
  });
}

class CheckStockArgs extends ProcessArgs {
  final SalespersonSchedule schedule;
  final String customerNo;
  CheckStockArgs({required this.schedule, required this.customerNo});
}

class SaleItemArgs extends ProcessArgs {
  final SalespersonSchedule schedule;
  final String documentType;
  final String customerNo;

  SaleItemArgs({
    required this.schedule,
    required this.documentType,
    required this.customerNo,
  });
}

class PosmAndMerchandingCompetitorArg extends ProcessArgs {
  final PosmMerchandingType posmMerchandingType;
  final SalespersonSchedule schedule;
  PosmAndMerchandingCompetitorArg({
    required this.posmMerchandingType,
    required this.schedule,
  });
}

class SaleFormArg {
  final Item item;
  final String documentType;
  final SalespersonSchedule schedule;

  SaleFormArg({
    required this.item,
    required this.schedule,
    required this.documentType,
  });
}

class SaleArg {
  final Item item;
  final SalespersonSchedule schedule;
  final List<SaleFormInput> inputs;
  final double? discountAmount;
  final double? discountPercentage;
  final double? manualPrice;
  final String remark;
  final String documentType;
  final double itemUnitPrice;

  const SaleArg({
    required this.item,
    required this.schedule,
    required this.inputs,
    required this.documentType,
    this.discountAmount,
    this.discountPercentage,
    this.manualPrice,
    this.remark = '',
    this.itemUnitPrice = 0,
  });
}

class ItemPosmAndMerchandise {
  final double qtyStock;
  final String status;
  final String description;
  final String description2;
  final Function(double value)? onUpdateQty;
  final Function()? onEditScreen;

  ItemPosmAndMerchandise({
    required this.qtyStock,
    required this.status,
    this.description = "",
    this.description2 = "",
    required this.onUpdateQty,
    this.onEditScreen,
  });
}

class ItemPosmAndMerchandiseArg {
  final SalespersonSchedule schedule;
  final PointOfSalesMaterial? posm;
  final Merchandise? merchandis;
  final Competitor? competitor;
  final bool isUpdateData;
  final double qty;
  final PosmMerchandingType posmMerchandType;

  ItemPosmAndMerchandiseArg({
    required this.schedule,
    this.posm,
    this.merchandis,
    this.isUpdateData = false,
    this.competitor,
    this.qty = 0,
    this.posmMerchandType = PosmMerchandingType.psom,
  });
}

class GroupFilterArgs {
  List<String> groupCodes;
  String status;
  GroupFilterArgs({required this.groupCodes, this.status = ""});
}

class CollectionsArg extends ProcessArgs {
  final SalespersonSchedule schedule;

  CollectionsArg({required this.schedule});
}

class PaymentArg {
  final PaymentMethod paymentMethod;
  final CustomerLedgerEntry customerLedgerEntry;
  final SalespersonSchedule schedule;
  final double amount;

  PaymentArg({
    required this.customerLedgerEntry,
    required this.schedule,
    required this.paymentMethod,
    required this.amount,
  });
}

class DefaultProcessArgs extends ProcessArgs {
  final SalespersonSchedule schedule;

  DefaultProcessArgs({required this.schedule});
}
