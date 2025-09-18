import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_helpers.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_mm80.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class ReceiptPreviewDialog extends StatelessWidget {
  final ReceiptPreview? preview;
  final VoidCallback onPrint;

  const ReceiptPreviewDialog({super.key, this.preview, required this.onPrint});

  @override
  Widget build(BuildContext context) {
    final Uint8List imageBytes = Uint8List.fromList(
      img.encodePng(preview!.image!),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 10,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade50, Colors.white],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: preview?.image == null
            ? SizedBox(
                height: scaleFontSize(200),
                child: Center(child: LoadingPageWidget()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  _buildReceiptImage(context, imageBytes),
                  Helpers.gapH(20),
                  _buildActionButtons(context),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: .1),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          const TextWidget(
            text: 'Receipt Preview',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            wordSpacing: 0.5,
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close_rounded, color: Colors.grey.shade600),
            splashRadius: 20,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptImage(BuildContext context, Uint8List imageBytes) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(scaleFontSize(8)),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Image.memory(
                imageBytes,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: BtnWidget(
              onPressed: () => Navigator.of(context).pop(),
              title: greeting('Cancel'),
              bgColor: red,
            ),
          ),
          Helpers.gapW(16),
          Expanded(
            child: BtnWidget(
              bgColor: success,
              icon: Icon(Icons.print_rounded, size: scaleFontSize(20)),
              onPressed: () {
                onPrint();
                Navigator.of(context).pop();
              },
              title: greeting("Print Receipt"),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> show(
    BuildContext context,
    ReceiptPreview preview,
    VoidCallback onPrint,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          ReceiptPreviewDialog(preview: preview, onPrint: onPrint),
    );
  }
}
