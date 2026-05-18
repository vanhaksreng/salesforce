import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/infrastructure/external_services/bluetooth_printer_service.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class PrintReceipt {

  final _printerService = BluetoothPrinterService();

  void print(SaleDetail inv, CompanyInformation company) async {
    
    final List<SalesLine> lines = inv.lines;

    await _printerService.printReceipt(
      company: company,
      invoiceNo: inv.header.no ?? "",
      customer: inv.header.customerName ?? "",
      dateTime: inv.header.orderDate ?? "",
      vatAmount: lines.fold(0, (sum, e) => sum + Helpers.toDouble(e.vatAmount)),
      amountDue: lines.fold(
        0,
        (sum, e) => sum + Helpers.toDouble(e.amountIncludingVat),
      ),
      discountAmount: lines.fold(0, (sum, e) {
        return sum +
            ((Helpers.toDouble(e.unitPrice) * Helpers.toDouble(e.quantity)) -
                Helpers.toDouble(e.amount));
      }),
      items: lines.map((line) {
        return InvoiceItem(
          name: line.description ?? "",
          qty: (line.quantity ?? 0).toInt(),
          price: line.unitPrice ?? 0,
          amount: line.amount ?? 0,
          discount: line.discountPercentage ?? 0,
        );
      }).toList(),
      paymentMethod: inv.header.paymentMethodCode ?? "",
    );
  }
}

// storeDevicePrinter
