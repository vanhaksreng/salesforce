import 'package:salesforce/core/utils/helpers.dart';

class SoOutstandingReportModel {
  final String? documentNo;
  final String? no;
  final String? description;
  final double? outStandingQuantity;
  final String? customerNo;
  final String? customerName;
  final String? status;
  final String? uom;
  final double? totalQty;
  final double? shipQty;
  final double? outstandingInvQuantity;
  final double? quantityInvoice;

  SoOutstandingReportModel({
    this.documentNo,
    this.no,
    this.description,
    this.outStandingQuantity,
    this.customerNo,
    this.customerName,
    this.status,
    this.totalQty,
    this.uom,
    this.shipQty,
    this.outstandingInvQuantity,
    this.quantityInvoice,
  });

  static SoOutstandingReportModel fromMap(Map<String, dynamic> json) {
    return SoOutstandingReportModel(
      documentNo: json["document_no"],
      no: json["no"],
      description: json["description"],
      outStandingQuantity: Helpers.toDouble(json["outstanding_quantity"]),
      customerNo: json["customer_no"],
      customerName: json["customer_name"],
      status: json["status"],
      uom: json["unit_of_measure"],
      totalQty: Helpers.toDouble(json["quantity"]),
      shipQty: Helpers.toDouble(json["quantity_shipped"]),
      outstandingInvQuantity: Helpers.toDouble(
        json["outstanding_inv_quantity"],
      ),
      quantityInvoice: Helpers.toDouble(json["quantity_invoiced"]),
    );
  }
}
