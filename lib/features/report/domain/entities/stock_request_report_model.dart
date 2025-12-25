class StockRequestReportModel {
  final StockRequestReportHeader? header;
  final List<StockRequestReportLine>? lines;

  const StockRequestReportModel({
    this.header,
    this.lines,
  });

  factory StockRequestReportModel.fromJson(Map<String, dynamic> json) {
    return StockRequestReportModel(
      header: json['header'] != null
          ? StockRequestReportHeader.fromJson(json['header'])
          : null,
      lines: (json['lines'] as List<dynamic>?)
          ?.map((e) => StockRequestReportLine.fromJson(e))
          .toList(),
    );
  }

  String get toEJson => '''
    {
      "header": ${header?.toEJson},
      "lines": ${lines?.map((e) => e.toEJson).toList()}
    }
  ''';
}

class StockRequestReportHeader {
  final String? title;
  final String? status;
  final String? documentDate;
  final String? postingDate;

  const StockRequestReportHeader({
    this.title,
    this.status,
    this.documentDate,
    this.postingDate,
  });

  factory StockRequestReportHeader.fromJson(Map<String, dynamic> json) {
    return StockRequestReportHeader(
      title: json['title'],
      status: json['status'],
      documentDate: json['document_date'],
      postingDate: json['posting_date'],
    );
  }

  String get toEJson => '''
    {
      "title": "$title",
      "status": "$status",
      "document_date": "$documentDate",
      "posting_date": "$postingDate"
    }
  ''';
}

class StockRequestReportLine {
  final String? itemNo;
  final String? description;
  final String? unitOfMeasure;
  final String? quantity;
  final String? requestQuantity;
  final String? quantityShipped;
  final String? quantityReceived;

  const StockRequestReportLine({
    this.itemNo,
    this.description,
    this.unitOfMeasure,
    this.quantity,
    this.requestQuantity,
    this.quantityShipped,
    this.quantityReceived,
  });

  factory StockRequestReportLine.fromJson(Map<String, dynamic> json) {
    return StockRequestReportLine(
      itemNo: json['item_no'],
      description: json['description'],
      unitOfMeasure: json['unit_of_measure'],
      quantity: json['quantity'],
      requestQuantity: json['request_quantity'],
      quantityShipped: json['quantity_shipped'],
      quantityReceived: json['quantity_received'],
    );
  }

  String get toEJson => '''
    {
      "item_no": "$itemNo",
      "description": "$description",
      "unit_of_measure": "$unitOfMeasure",
      "quantity": "$quantity",
      "request_quantity": "$requestQuantity",
      "quantity_shipped": "$quantityShipped",
      "quantity_received": "$quantityReceived"
    }
  ''';
}
