import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/more/presentation/pages/invoice_printer/imin_printer_service.dart';
import 'package:salesforce/features/more/presentation/pages/invoice_printer/invoice_printer_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/invoice_printer/invoice_printer_state.dart';

class InvoicePrinterScreen extends StatefulWidget {
  const InvoicePrinterScreen({super.key});
  static const String routeName = "print_invoice";

  @override
  InvoicePrinterScreenState createState() => InvoicePrinterScreenState();
}

class InvoicePrinterScreenState extends State<InvoicePrinterScreen> with MessageMixin {
  final screenCubit = InvoicePrinterCubit();
  final printer = IminPrinterService();

  @override
  void initState() {
    super.initState();

    onInit();
  }

  onInit() async {
    await printer.initPrinter();
    await printer.getPrinterStatus();
  }

  void printTest() async {
    await printer.printText("Hello iMin Printer");
    await printer.getSerialNumber();
    // await printer.openCashBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invoice Previewee")),
      body: BlocBuilder<InvoicePrinterCubit, InvoicePrinterState>(
        bloc: screenCubit,
        builder: (context, state) {
          // return Column(
          //   children: [
          //     // Receipt(
          //     //   builder: (context) => const Column(children: [
          //     //     const Text('Hello World'),
          //     //   ]),
          //     //   onInitialized: (controller) {
          //     //     this.controller = controller;
          //     //   },
          //     // ),

          //     ElevatedButton(
          //       onPressed: () {
          //         printTest();
          //       },
          //       child: Text('Test Print'),
          //     ),

          //     Expanded(
          //       child: PdfPreview(
          //         build: (format) =>
          //             getInvoice(arg: InvoiceModel(docNo: "okasdfasdf")),
          //       ),
          //     ),
          //   ],
          // );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // const SizedBox(height: 16),
              // PdfPreview(
              //   build: (format) => _generatePdf(format),
              // ),
            ],
          );
        },
      ),
    );
  }
}
