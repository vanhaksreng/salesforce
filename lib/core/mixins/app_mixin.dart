import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/presentation/widgets/bluetooth_list_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/infrastructure/external_services/bluetooth_printer_service.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:share_plus/share_plus.dart';

mixin AppMixin {
  final _appRepo = getIt<BaseAppRepository>();
  final _moreRepo = getIt<MoreRepository>();

  final _printerService = BluetoothPrinterService();

  Future<bool> isValidApiSession() async {
    try {
      final response = await _appRepo.isValidApiSession();
      return response.fold(
        (failure) => throw GeneralException(failure.message),
        (items) => true,
      );
    } on GeneralException catch (e) {
      Helpers.showMessage(msg: e.message, status: MessageStatus.errors);
      return false;
    } on Exception {
      Helpers.showMessage(msg: errorMessage, status: MessageStatus.errors);
      return false;
    }
  }

  Future<bool> apiSessionStillAlive() async {
    try {
      final response = await _appRepo.isValidApiSession();
      return response.fold(
        (failure) => throw GeneralException(failure.message),
        (items) => true,
      );
    } on Exception {
      return false;
    }
  }

  Future<bool> isConnectedToNetwork() async {
    return _appRepo.isConnectedToNetwork();
  }

  Future<String> getSetting(String settingKey) async {
    return _appRepo.getSetting(settingKey);
  }

  Future<GpsRouteTracking?> getLastGpsRequest() async {
    final response = await _appRepo.getLastGpsRequest();
    return response.fold(
      (failure) => throw GeneralException(failure.message),
      (tracking) => tracking,
    );
  }

  Future<void> shareSaleDocument(
    BuildContext context, {
    required String documentNo,
    required String documenType,
    String size = "l",
  }) async {
    final box = context.findRenderObject() as RenderBox;

    if (!await isConnectedToNetwork()) {
      Helpers.showMessage(
        msg: "No internet connection. Please check your network settings.",
        status: MessageStatus.warning,
      );
      return;
    }

    final isNotExpired = await apiSessionStillAlive();
    if (!isNotExpired) {
      if (!context.mounted) return;
      final password = await Helpers.showSessionLoginDialog(context);
      if (password == null) return;
    }

    if (!context.mounted) return;

    final l = LoadingOverlay.of(context);
    l.show();

    try {
      final html = await _moreRepo
          .getInvoiceHtml(
            param: {"doc_no": documentNo, "doc_type": documenType, size: size},
          )
          .then((r) {
            return r.fold((l) => "", (r) => r);
          });

      if (html.isEmpty) {
        l.hide();
        return;
      }

      final pdfFile = await Helpers.generateToPdfDocument(
        htmlContent: html,
        documentNo: documentNo,
      );

      l.hide();

      if (pdfFile == null) {
        Helpers.showMessage(
          msg: "Failed to generate PDF.",
          status: MessageStatus.warning,
        );
        return;
      }

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(pdfFile.path)],
          // កំណត់ទីតាំងឱ្យផ្ទាំង share បង្ហាញចេញពីប៊ូតុងដែលចុច
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      Helpers.showMessage(
        msg: "An error occurred while sharing the document.",
        status: MessageStatus.errors,
      );
      l.hide();
    }
  }

  Future<List<Map<String, String>>> _loadDevices() async {
    bool hasPerm = await _printerService.requestPermissions();
    if (!hasPerm) {
      return [];
    }

    return await _printerService.getPairedDevices();
  }

  Future<bool> _connectTo(String address) async {
    return await _printerService.connect(address);
  }

  Future<void> printReceipt(
    BuildContext context, {
    required SalesHeader header,
    required List<SalesLine> lines,
  }) async {
    final l = LoadingOverlay.of(context);

    final company = await _appRepo.getCompanyInfo().then((r) {
      return r.fold((l) => null, (record) => record);
    });

    if (company == null) {
      Helpers.showMessage(
        msg: "Company information is missing.",
        status: MessageStatus.errors,
      );
      return;
    }

    l.show(message: 'Checking printer...');

    final result = await _appRepo.getDevicePrinter();
    final connectedDevices = result.fold((l) => [], (record) => record);

    if (connectedDevices.isEmpty) {
      l.updateProgress(0, text: 'Finding printers...');
      final devices = await _loadDevices();
      l.hide();

      if (!context.mounted) return;
      await showSessionLoginDialog(
        context,
        devices: devices,
        header: header,
        lines: lines,
        company: company,
      );
      return;
    }

    final DevicePrinter configMac = connectedDevices.first;
    final macAddress = configMac.macAddress;

    final isReachable = await _printerService.isPrinterReachable(macAddress);

    late bool isConnected = false;
    if (isReachable) {
      isConnected = await _connectTo(macAddress);
    }

    l.updateProgress(0, text: 'Printing receipt...');

    if (isConnected) {
      await _processPrintReceipt(
        header: header,
        lines: lines,
        company: company,
        configMac: configMac,
      );
    } else {
      Helpers.showMessage(
        msg:
            "Failed to connect to printer. Please check the connection and try again.",
        status: MessageStatus.warning,
      );
    }

    debugPrint(
      "passss isReachable: $isReachable, isConnected: $isConnected mac: $macAddress",
    );

    l.hide();
  }

  void openPrintReceiptSetting(
    BuildContext context, {
    SalesHeader? header,
    List<SalesLine> lines = const [],
  }) async {
    // if (_cubit.state.record == null || _cubit.state.comPanyInfo == null) {
    //   showErrorMessage("Sale details or company information is missing.");
    //   return;
    // }

    final l = LoadingOverlay.of(context);
    final company = await _appRepo.getCompanyInfo().then((r) {
      return r.fold((l) => null, (record) => record);
    });

    if (company == null) {
      Helpers.showMessage(
        msg: "Company information is missing.",
        status: MessageStatus.errors,
      );
      return;
    }

    l.show(message: 'Finding printers...');

    final devices = await _loadDevices();

    l.hide();

    if (!context.mounted) return;
    await showSessionLoginDialog(
      context,
      devices: devices,
      header: header,
      lines: lines,
      company: company,
    );
  }

  Future<void> _processPrintReceipt({
    required SalesHeader header,
    required List<SalesLine> lines,
    required CompanyInformation company,
    required DevicePrinter configMac,
  }) async {
    await _printerService.printReceipt(
      company: company,
      invoiceNo: header.no ?? "",
      customer: header.customerName ?? "",
      dateTime: header.orderDate ?? "",
      paymentMethod: header.paymentMethodCode ?? "",
      paperWidth: configMac.paperSize.toInt().toString(),
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
    );
  }

  Future<String?> showSessionLoginDialog(
    BuildContext context, {
    required List<Map<String, String>> devices,
    SalesHeader? header,
    List<SalesLine> lines = const [],
    required CompanyInformation company,
    DevicePrinter? printerConfig,
  }) async {
    // final devices = await _cubit.getPrinterConfig();
    if (!context.mounted) return null;

    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (context, _, _) => BluetoothListWidget(
        devices: devices,
        printerConfig: printerConfig,
        onConfirm: ({required address, required deviceName, required printerSize}) {
              _onConfirmSetupPrinter(
                address: address,
                deviceName: deviceName,
                printerSize: printerSize,
                devices: devices,
                header: header,
                lines: lines,
                company: company,
              );
            },
      ),
    );
  }

  void _onConfirmSetupPrinter({
    required String address,
    required String deviceName,
    required String printerSize,
    List<Map<String, String>> devices = const [],
    SalesHeader? header,
    required List<SalesLine> lines,
    required CompanyInformation company,
  }) async {
    if (devices.every((d) => d['address'] != address)) {
      Helpers.showMessage(
        msg:
            "The configured printer is not available. Please check your printer connection.",
        status: MessageStatus.warning,
      );
      return;
    }

    final device = DevicePrinter(
      deviceName,
      deviceName,
      "Bluetooth",
      deviceName,
      address,
      Helpers.toDouble(printerSize),
    );

    await _appRepo.storeDevicePrinter(device);

    final isConnected = await _connectTo(address);
    if (!isConnected) {
      Helpers.showMessage(
        msg:
            "Failed to connect to printer. Please check the connection and try again.",
        status: MessageStatus.warning,
      );
      return;
    }

    if (header != null) {
      await _processPrintReceipt(
        header: header,
        lines: lines,
        company: company,
        configMac: device,
      );
    }
  }
}
