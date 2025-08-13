class ItemInventoryReportModel {
  final String? no;
  final String? description;
  final String? description2;
  final String? stockUomCode;
  final String? salesUomCode;
  final String? purchaseUomCode;
  final String? inventory;
  final String? beginningQty;
  final String? increaseQty;
  final String? decreaseQty;
  final String? endingQty;
  final String? quantityBase;
  final String? locationCode;

  const ItemInventoryReportModel({
    this.no,
    this.description,
    this.description2,
    this.stockUomCode,
    this.salesUomCode,
    this.purchaseUomCode,
    this.inventory,
    this.beginningQty,
    this.increaseQty,
    this.decreaseQty,
    this.endingQty,
    this.quantityBase,
    this.locationCode,
  });

  factory ItemInventoryReportModel.fromJson(Map<String, dynamic> json) =>
      ItemInventoryReportModel(
        no: json["no"],
        description: json["description"],
        description2: json["description_2"],
        stockUomCode: json["stock_uom_code"],
        salesUomCode: json["sales_uom_code"],
        purchaseUomCode: json["purchase_uom_code"],
        inventory: json["inventory"],
        beginningQty: json["beginning_qty"],
        increaseQty: json["increase_qty"],
        decreaseQty: json["decrease_qty"],
        endingQty: json["ending_qty"],
        quantityBase: json["quantity_base"],
        locationCode: json["location_code"],
      );

  Map<String, dynamic> toJson() => {
        "no": no,
        "description": description,
        "description_2": description2,
        "stock_uom_code": stockUomCode,
        "sales_uom_code": salesUomCode,
        "purchase_uom_code": purchaseUomCode,
        "inventory": inventory,
        "beginning_qty": beginningQty,
        "increase_qty": increaseQty,
        "decrease_qty": decreaseQty,
        "ending_qty": endingQty,
        "quantity_base": quantityBase,
        "location_code": locationCode,
      };
}
