import 'dart:typed_data';

import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/thermal_printer.dart';

enum ReceiptCommandType { text, image, feedPaper, cutPaper }

// Receipt command model
class ReceiptCommand {
  final ReceiptCommandType type;
  final Map<String, dynamic> params;

  ReceiptCommand(this.type, this.params);
}

// Receipt builder to collect commands
class ReceiptBuilder {
  final List<ReceiptCommand> _commands = [];

  List<ReceiptCommand> get commands => List.unmodifiable(_commands);

  void addText(
    String text, {
    int fontSize = 24,
    int maxCharPerLine = 32,
    bool bold = false,
    AlignStyle align = AlignStyle.left,
  }) {
    _commands.add(
      ReceiptCommand(ReceiptCommandType.text, {
        'text': text,
        'fontSize': fontSize,
        'bold': bold,
        'maxCharsPerLine': maxCharPerLine,
        'align': align.value,
      }),
    );
  }

  void addImage(Uint8List imageBytes, {int width = 384}) {
    _commands.add(
      ReceiptCommand(ReceiptCommandType.image, {
        'imageBytes': imageBytes,
        'width': width,
      }),
    );
  }

  void feedPaper(int lines) {
    _commands.add(
      ReceiptCommand(ReceiptCommandType.feedPaper, {'lines': lines}),
    );
  }

  void cutPaper() {
    _commands.add(ReceiptCommand(ReceiptCommandType.cutPaper, {}));
  }

  void clear() {
    _commands.clear();
  }
}
