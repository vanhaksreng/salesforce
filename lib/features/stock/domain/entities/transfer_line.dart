import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';

class TransferLine {
  final String documentNo;
  final String lineNo;
  final String itemNo;
  final String uomCode;
  final double quantity;
  final double quantityToShip;
  final double quantityToReceive;
  final double quantityShipped;
  final double quantityReceived;

  const TransferLine({
    required this.documentNo,
    required this.lineNo,
    required this.itemNo,
    required this.uomCode,
    required this.quantity,
    required this.quantityToShip,
    required this.quantityToReceive,
    required this.quantityShipped,
    required this.quantityReceived,
  });

  factory TransferLine.fromMap(Map<String, dynamic> json) {
    return TransferLine(
      documentNo: json["document_no"],
      lineNo: Helpers.toStrings(json["line_no"]),
      itemNo: Helpers.toStrings(json["no"]),
      uomCode: Helpers.toStrings(json["unit_of_measure"]),
      quantity: Helpers.formatNumberDb(json["quantity"], option: FormatType.quantity),
      quantityToShip: Helpers.formatNumberDb(json["quantity_to_ship"], option: FormatType.quantity),
      quantityToReceive: Helpers.formatNumberDb(json["quantity_to_receive"], option: FormatType.quantity),
      quantityShipped: Helpers.formatNumberDb(json["quantity_shipped"], option: FormatType.quantity),
      quantityReceived: Helpers.formatNumberDb(json["quantity_received"], option: FormatType.quantity),
    );
  }
}
