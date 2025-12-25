import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/invoice_printer/invoice_printer_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/invoice_printer/invoice_printer_state.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class InvoicePrinterScreen extends StatefulWidget {
  const InvoicePrinterScreen({
    super.key,
    required this.detail,
    required this.companyInfo,
  });

  final SaleDetail detail;
  final CompanyInformation companyInfo;
  static const String routeName = "print_invoice";

  @override
  InvoicePrinterScreenState createState() => InvoicePrinterScreenState();
}

class InvoicePrinterScreenState extends State<InvoicePrinterScreen>
    with MessageMixin {
  final screenCubit = InvoicePrinterCubit();
  @override
  void initState() {
    super.initState();
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
